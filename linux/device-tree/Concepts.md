

Modules in linux may not call probe when loaded e.g. `insmod` but will call probe when match + probe runs on the platform device initcalls.

So insmod is not always same as loading it via match + probe.



A device tree is a tree of nodes.


# Node
A node contains properties on the basis of which it can be a 
1. provider
2. consumer
3. both

Node properties are just data. They are given meaning by the 

1. the open firmware device tree core parser
2. existing kernel constructs on parsing and registering functions




Let's walk through an example first and then we can understant what's going on in more detail


Let's work with


```dts
gpio@220000 {
    interrupt-controller;
    #interrupt-cells = <2>; /* This is also just an ascii string */
}
```

```dts
mydev@... {
    interrupt-parent = <&gpio> 
    interrupts = <0x94 0x08 0x95 0x8>
}
```


When the device is booted, the gpio's irqchip driver probes it 


```c
static int tegra_gpio_probe(struct platform_device *pdev)
{
    struct device_node *np = pdev->dev.of_node;

    // Create an irqdomain anchored at this DT node
    domain = irq_domain_add_linear(np, num_irqs,
                                   &tegra_gpio_domain_ops, data);

    // Also register irqchip methods (mask/unmask/ack/set_type, etc.)
    // ... set up parent irq, chained handler, etc.

    return 0;
}
```


We have registered an irq_domain and irq_chip methods on `np` which is the the platform device -> device struct -> of_node pointer.

When the child of node is probed, the OF core will resolve all pointers to their address of the of node in the kernel memory. Then the probe has the following shape

```c
int virq1 = platform_get_irq(pdev, 0) // line 0x94, flags 0x8
int virq2 = platform_get_irq(pdev, 1) // line 0x95, flags 0x8
request_threaded_irq(virq1, handler1, thread_fn1, flags1, "mydev1", dev);
request_threaded_irq(virq2, handler2, thread_fn2, flags2, "mydev2", dev);
```

```c
int platform_get_irq(struct platform_device *pdev, unsigned int num)
{
    return of_irq_get(pdev->dev.of_node, num);
}

int of_irq_get(struct device_node *dev, int index)
{
    struct of_phandle_args oirq;

    // Parse the (index'th) interrupt specifier out of DT
    if (of_irq_parse_one(dev, index, &oirq))
        return -EINVAL;

    // Turn that DT specifier into a Linux IRQ number
    return irq_create_of_mapping(&oirq);
}
```


Let's look at both functions `of_irq_parse_one` and `irq_create_of_mapping`.



Conceptually `of_irq_parse_one` does this


1. find the interrupt controller either by using `interrupt-parent` or walking up the parents until it finds an ancestor node with the `interrupt-controller;` property.
2. Read that provider's `#interrupt-cells`
3. Split the consumers `interrupts` property accordingly
4. Return a struct like `{ provider_of_node, args [], args_count`

```c
int of_irq_parse_one(struct device_node *dev, int index,
                     struct of_phandle_args *out)
{
    struct device_node *ip = resolve_interrupt_parent(dev); // phandle -> node*
    int cells = of_property_read_u32(ip, "#interrupt-cells");

    out->np = ip;                 // provider node (device_node*)
    out->args_count = cells;
    out->args = read_nth_specifier(dev, index, cells); // from "interrupts"
    return 0;
}
```


Once this is done, we do

```c
unsigned int irq_create_of_mapping(struct of_phandle_args *oirq)
{
    // Find irq_domain associated with provider node oirq->np
    struct irq_domain *d = irq_find_host(oirq->np);

    // Ask that domain to translate the specifier (provider-specific)
    irq_hw_number_t hwirq;
    unsigned int type;
    d->ops->xlate(d, oirq->np, oirq->args, oirq->args_count, &hwirq, &type);

    // Allocate or look up a Linux IRQ for (domain,hwirq)
    unsigned int virq = irq_create_mapping(d, hwirq);

    // Apply trigger type/polarity if needed
    irq_set_type(virq, type);

    return virq;
}
```


The xlate callback is what finally translates the numbers into irq
eg.
```c
static int tegra_gpio_xlate(struct irq_domain *d,
                            struct device_node *ctrlr,
                            const u32 *intspec, unsigned int intsize,
                            unsigned long *out_hwirq,
                            unsigned int *out_type)
{
    // intspec[0] -> which GPIO line
    // intspec[1] -> flags (edge/level, polarity)
    *out_hwirq = decode_line(intspec[0]);
    *out_type  = decode_flags(intspec[1]);
    return 0;
}
```


Finally, the consumer probe would do something like


## Provider Nodes

Providers advertise that they can be references and what arguments they expect

1. GPIO provider has `gpio-controller;` and `#gpio-cells = <...>`
2. Interrupt provider has `interrupt-controller;` and `#interrupt-cells = <...>;`
3. Clock provider has `#clock-cells = <...>;` , often plus `clock-output-names`
4. Regulator provider has `regulator-name`, `regulator-min-microvolt` etc and is referenced  via `*-supply`
5. Bus provider has `#address-cells` and `#size-cells`.


Each node in a device tree
- has a register space that is defined within the parent address space
- has its own address space and defines a mapping from parent address space to its own address space (base + offset mapping)


pin-ctrl in linux cna be used to see which device owns a pin eg pin 28 (GPIOX_8): device fe330000.audiobus:tdm@0 function tdm group tdm_d0

means tdm@0 owns it





## Cross Referencing

Think of  a device tree as a large `C struct` that nests many small `C struct`.

1. A node in a device tree is like an instantiation of a struct describing some hardware block
2. Any reference like `field = <&node2>`, `field1 = <&{/path/to/node3}>` or `field2 = <0xfeedbeef>` is a logical pointer to another node in the graph. For the `0xfeedbeef` syntax, the pointee node needs to have a field called `phandle = <0xfeedbeef>`. 
3. Often this is like a pointer + arguments, like `reset-gpios = <&gpio 12 GPIO_ACTIVE_LOW>`