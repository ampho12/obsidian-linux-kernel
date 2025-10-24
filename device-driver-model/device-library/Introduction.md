

Device library provides the following functionality:
1. create a hierarchy of devices using the kobject library



# Lifetime of the Device Object


## Stages

### Allocation
1. Statically allocated
2. Dynamically allocated

### Initialization

* hierarchy
    1. set `dev->kobj.kset = devices_kset` and init `dev->kobj` with `device_ktype`
    2. init `dev->mutex`
    3. bunch of other inits
    4. (optional) init `dev.init_name`
    5. (optional) set `dev.parent`

### Addition
1. set name to `dev.init_name` if set, else create default name
2. increment refcount of parent's kobject 
3. set `dev->kobj.parent` to `dev->parent.kobj` (if `dev->parent != NULL`)
4. Add `dev->kobj` to the kobject system
5. 

### Usage

### Removal
### Termination
### Deallocation



