

When a device is discovered via device tree or ACPI, its probe function is called. The matching is done using the match_table.


## Probe Function

```c
static int mydev_probe(struct platform_device *pdev)
{
    // pdev contains all information passed by the device tree / ACPI table
    // we specialize by using the *priv pointer in pdev
    
    struct net_device *ndev;
    struct mydev_priv *priv;
    int ret;

    /* Allocate a net_device with private data */
    ndev = alloc_etherdev(sizeof(*priv));
    /* Get a pointer to the private section */
    priv = netdev_priv(ndev);
    /* setup priv */
    priv->dev = ndev;
    /* let platform dev's drvdata point to priv*/
    platform_set_drvdata(pdev, priv);

    /* Map hardware registers, get IRQ, clocks, etc. */
    priv->ioaddr = devm_platform_ioremap_resource(pdev, 0);
    priv->irq    = platform_get_irq(pdev, 0);
    /* …clocks, resets… */

    /* Fill in callbacks */
    ndev->netdev_ops       = &mydev_netdev_ops;
    ndev->ethtool_ops      = &mydev_ethtool_ops;
    ndev->watchdog_timeo   = STMMAC_TIMEOUT;

    /* Register with the networking core */
    ret = register_netdev(ndev);
    if (ret)
        goto err_free;
    return 0;
err_free:
    free_netdev(ndev);
    return ret;

}
```

We setup a self referential structure for the netdevice, and set the platform_device's driver data to point to the `mydev_priv`


```


ndev        +--------------+ <--+
            |              |    |
            |              |    |
            |              |    |
            |              |    |
mydev_priv  +--------------+    |
            | dev  --------|----+ (points to start of ndev (self-referential))
            |              |
            +--------------+
```

and `pdev.dev.driver_data` holds `stmmac_priv` (i.e pointer to the start of the private section of the netdev)


## Bringing the interface up / down

- **`ndo_open`** (e.g. `mydev_open`): Gets called when we do `ip link up ...`
    
    - Enable clocks, de-assert resets.
        
    - Allocate/fill DMA Rx and Tx descriptors.
        
    - Register interrupt handlers.
        
    - Enable NAPI and tell the hardware to start.
        
- **`ndo_stop`** (e.g. `mydev_stop`):  gets called when `ip link down ...`
    
    - Disable interrupts, stop DMA.
        
    - Disable NAPI, free descriptors.
        
    - Gate clocks.





## Receiving

The NIC needs a set of buffers on standby so it can DMA the packets as soon as they arrive.

The buffers are allocated by the kernel as socket buffers or `sk_buff`. These are mapped into dma engine.

A descriptor contains more metadata information about each buffer.


```c
struct sk_buff  *rx_skbuff[]; // socket buffers
dma_address_t    rx_skbuff_dma[]; // dma addresses
struct dma_desc  rx_desc[]; // rx descriptors for dma
```


these three arrays are linked by a single index `rx_cons` that is incremented and wraps around.

The setup is done during `ndo_open`


```c
for (i = 0; i < ring_size; i++) {
    skb = netdev_alloc_skb(ndev, RX_BUF_SIZE);
    priv->rx_skbuff[i]     = skb;
    priv->rx_skbuff_dma[i] = dma_map_single(
                                  ndev->dev.parent,
                                  skb->data,
                                  RX_BUF_SIZE,
                                  DMA_FROM_DEVICE);
    desc = &priv->rx_desc[i];
    desc->addr = priv->rx_skbuff_dma[i];
    desc->ctrl = DESC_OWNED_BY_DMA;
}
```


When a dma completion interrupt arrives, the interrupt handler unsets `DESC_OWNED_BY_DMA` in the `desc->ctrl` field.

In the `napi's poll()` method, we will loop over the `rx_desc` ring, and for all descriptors that are no longer 