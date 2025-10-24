
Setup steps are common

1. build dpdk natively on jetson with meson/ninja
2. enable hugepages
3. bind external nic to vfio



Install deps

```
sudo apt install -y build-essential meson ninja-build pkg-config \
  python3-pip python3-pyelftools libnuma-dev
```


Build

```
cd ~/Documents/dpdk
rm -rf build
meson setup build -Dexamples=helloworld \
  -Denable_drivers=net/e1000
ninja -C build
```



Reserve 512 hugepages, reduce if memory is low

1 hugepage is 2MB, 512 Hugepages = 1 GB

```
echo 512 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
```

Run to test 
```
sudo ./build/examples/dpdk-helloworld
```

Should output
```
nv1@nv1-desktop:~/Documents/dpdk$ sudo ./build/examples/dpdk-helloworld
EAL: Detected CPU lcores: 6
EAL: Detected NUMA nodes: 1
EAL: Detected static linkage of DPDK
EAL: Multi-process socket /var/run/dpdk/rte/mp_socket
EAL: Selected IOVA mode 'VA'
EAL: VFIO support initialized
hello from core 1
hello from core 2
hello from core 3
hello from core 4
hello from core 5
hello from core 0
```


Now we will try bind the i350 nic to dpdk

```
nv1@nv1-desktop:~/Documents/dpdk$ sudo ./usertools/dpdk-devbind.py --status

Network devices using kernel driver
===================================
0001:01:00.0 'RTL8822CE 802.11ac PCIe Wireless Network Adapter c822' if=wlP1p1s0 drv=rtl88x2ce unused=rtl8822ce,vfio-pci *Active*
0004:01:00.0 'I350 Gigabit Network Connection 1521' if=enP4p1s0f0 drv=igb unused=vfio-pci
0004:01:00.1 'I350 Gigabit Network Connection 1521' if=enP4p1s0f1 drv=igb unused=vfio-pci
0004:01:00.2 'I350 Gigabit Network Connection 1521' if=enP4p1s0f2 drv=igb unused=vfio-pci
0004:01:00.3 'I350 Gigabit Network Connection 1521' if=enP4p1s0f3 drv=igb unused=vfio-pci
0008:01:00.0 'RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller 8168' if=enP8p1s0 drv=r8168 unused=vfio-pci

No 'Baseband' devices detected
==============================

No 'Crypto' devices detected
============================

No 'DMA' devices detected
=========================

No 'Eventdev' devices detected
==============================

No 'Mempool' devices detected
=============================

No 'Compress' devices detected
==============================

No 'Misc (rawdev)' devices detected
===================================

No 'Regex' devices detected
===========================

No 'ML' devices detected
========================
```


We will now bind dpdk to the nic. From the status we see devices are

```
0004:01:00.0
0004:01:00.1
0004:01:00.2
0004:01:00.3
```

we wil bind them to vfio-pci using helper scripts. Vfio-pci allows user space access to dma buffers.

```
sudo modprobe vfio-pci

sudo dpdk-devbind.py -b vfio-pci 0004:01:00.{0,1,2,3}

```

verify that devices were bound to the driver

```
ip l show # should not show the 4 links of the nic
```

```
nv1@nv1-desktop:~/Documents/dpdk$ sudo ./usertools/dpdk-devbind.py --status

Network devices using DPDK-compatible driver
============================================
0004:01:00.0 'I350 Gigabit Network Connection 1521' drv=vfio-pci unused=
0004:01:00.1 'I350 Gigabit Network Connection 1521' drv=vfio-pci unused=
0004:01:00.2 'I350 Gigabit Network Connection 1521' drv=vfio-pci unused=
0004:01:00.3 'I350 Gigabit Network Connection 1521' drv=vfio-pci unused=
```


This would not work


# Use the UIO driver

```
git clone https://github.com/daynix/dpdk-kmods.git
cd dpdk-kmods/linux/igb_uio
make
sudo modprobe uio
sudo insmod ./igb_uio.ko

# bind all 4 ports
sudo ~/Documents/dpdk/usertools/dpdk-devbind.py -b igb_uio 0004:01:00.{0,1,2,3}
sudo ~/Documents/dpdk/usertools/dpdk-devbind.py --status   # should show drv=igb_uio


# Runs testpmd in interactive mode
sudo ~/Documents/dpdk/build/app/dpdk-testpmd -l 1-5 -n 2 --iova-mode=pa \
  -a 0004:01:00.0 -a 0004:01:00.1 -a 0004:01:00.2 -a 0004:01:00.3 -- --i

```
# Things to Learn

1. VFIO
    1. IOMMU groups and requires all devices in the bridge to be bound to pcie devices
    2. SMMU
2. EAL 
3. UIO_PCI_GENERIC
4. --iova-mode=pa

