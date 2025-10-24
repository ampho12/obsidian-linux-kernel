

Each node in a device tree
- has a register space that is defined within the parent address space
- has its own address space and defines a mapping from parent address space to its own address space (base + offset mapping)


pin-ctrl in linux cna be used to see which device owns a pin eg pin 28 (GPIOX_8): device fe330000.audiobus:tdm@0 function tdm group tdm_d0

means tdm@0 owns it