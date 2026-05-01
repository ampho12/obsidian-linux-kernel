

Let's look at a path

```
DEVPATH=/devices/
  pci0000:00/                ← PCI root bus
    0000:00:14.0/            ← USB host controller at PCI slot 14.0
      usb3/                  ← “USB bus number 3” on that controller
        3-2/                 ← port 2 on that bus
          3-2:1.0/           ← interface 1 (the “functional” USB interface)
            net/can0         ← the network‐device node the driver registered

```




# General Path

 A general usb path looks like this in `sysfs`

```
<path-to-usb-bus-host-controller>/
    <path-to-physical-port>/
        <path-to-interface-altsetting
            ...
```

Let's take the following example

```
/sys/devices/pci0000:00/0000:00:14.0/usb3/3-2/3-2:1.0/net/can0/
```

## Path to Bus Host Controller

In our example this is 

```
/sys/devices/pci1000:00/0000:00:14.0/usb3
```

This is where the usb host controller for the bus is located.
## Path to Physical Port

The usb topology in the physical world looks like this

```
BUS
1. HUB
    1. DEVICE0
    2. HUB
        1. DEVICE1
2. DEVICE2
```


To capture this, we need 

1. A way to specify root port
2. A way to distinguish between ports on current HUB and ports on child HUB
3. A way to separate device from port (this will be in the next section).

Let's label each final port with some letter
```
BUS
1. HUB - A
    1. DEVICE0 - B
    2. HUB - C
        1. DEVICE1 - D
2. DEVICE2 - E
```


1. The bus is identified by the bus number, which is 3
2. Every port on the root bus is separated with a hypehen `-` . Therefore, we have
    1. A: `3-1`
    2. E: `3-2`
3. If a port is connected to a hub, we separate the the current port and child port with a period `.`
    1. B: `3-1.1`
    2. C: `3-1.2`
    3. D `3-1.2.1`
4. Finally to indicate the device at a port, we separate a the port and device using `:`
    1. E: `3-2:1.0` (device is `1.0`, with `1` being interface of that device, `0` being the altsetting)
    2. B: `3-1.1:2.1` 
    3. D `3-1.2:1.3`
    
therefore a path to a physical port looks like this

```
<root-port>[.<port>[.<port>…]]
```

That is, ports chained together with a period `.`

## Path to Interface and Altsetting

Each device is separated from the bus using `:` 



# Rules of Thumb

    A dash (-) separates the bus from the first port.

    A dot (.) chains additional hub‐ports.

    A colon (:) precedes the interface number.

    A final dot (.) precedes the alternate setting.

That’s the canonical sysfs naming for USB devices and their functions.



# UDEV

Reload rules

```
sudo udevadm control --reload-rules
```

Re-apply rules against existing devices

```
sudo udevadm trigger
```

watch for events (kernel + udev)

```
udevadm monitor
```

watch for udev events only

```
udevadm monitor --udev
```

query information

```
devadm info --query=property -p /sys/class/net/can0
```


