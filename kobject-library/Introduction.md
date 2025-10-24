

kobjects provide the following functionalities

1. create and manage DAG hierarchy
2. show up as directories in the sysfs virtual filesystem
3. track state variables and reference count, and calling a cleanup function when reference count reaches 0.


Thus, we have the following members in `struct kobject`


```c
struct kobject {                                      
  // for sysfs directory name
  const char    *name;                                

  // ampho12: for managing DAG heirachy
  struct list_head  entry;                            
  struct kobject    *parent;                          
  struct kset   *kset;                                

  // ampho12: type of kobject / use case specific stuff
  const struct kobj_type  *ktype;                     

  // ampho12: sysfs directory entry
  struct kernfs_node  *sd; /* sysfs directory entry */


  // reference counting and state variables
  struct kref   kref;                                 
#ifdef CONFIG_DEBUG_KOBJECT_RELEASE                   
  struct delayed_work release;                        
#endif                                                
  unsigned int state_initialized:1;                   
  unsigned int state_in_sysfs:1;                      
  unsigned int state_add_uevent_sent:1;               
  unsigned int state_remove_uevent_sent:1;            
  unsigned int uevent_suppress:1;                     
};                                                    
```


# Lifetime of the kobject

## Stages


### Allocation
1. Static
2. on the heap

### Initialization

* hierarchy
    1. init `list_head entry` for addition to lists
    2. (optional) set `struct kset *kset`
    3. (optional) set `*parent`
* sysfs
* state and behavior
    1. init `struct kref` for reference counting
    2. init state flags
    3. set `struct kobj_type *ktype` 

### Addition 

* hierarchy
    1. set `parent` to explicitly provided parent kobject or `kobj->kset->kobj` if no parent explicitly provided
    2. increment `parent`'s refcount
    3. if `kobj->kset` is set, adds `kobj` to `kobj->kset`
* sysfs
    1. set `const char *name`
    2. create directory
* state and behavior
    1. set `state_in_sysfs` flag

Add uevent to be sent by consumer of the api

### Usage
Can move kobject and other operations


### Removal

Remove the entire subtree under the kobject from the DAG hierachy.

* hierarchy
    1. leave the kset (if in one)
    2. decrement parent refcount and set `kobj->parent` to NULL.
* sysfs
    1. remove kobject and associated files (groups in ktype) from sysfs
* state and behavior
    1. clear `state_in_sysfs` flag

Send remove uevent if add uevent was sent

### Termination
Frees resources held by kobject. 

* hierarchy
* sysfs
    1. deallocated `name` if it was allocated on non-read only memory.
* state and behavior
    1. calls `kobj->ktype->release` for dellocation

### Deallocation

`kobj->ktype->release` is called on the kobject to free memory used for kobject itself.



## Consumer API 

1. `kobject_init`
    1. 









