

Iceoryx2 creates nodes and services under a directory which can be configured like this

```rust
pub fn setup_test_environment() -> anyhow::Result<Config> {
    
    use iceoryx2::prelude::Path;
    let mut prefix = FileName::new(b"test_prefix_").unwrap();
    prefix
        .push_bytes(
            b"unique_prefix_"
        )
        .unwrap();

    let mut config = Config::default();
    config.global.set_root_path(&Path::try_from("/tmp/iox2")?);
    config.global.prefix = prefix;

    Ok(config)
}
```

This tells iceoryx2 to use `/tmp/iox2` for coordination between nodes. This directory has to be common to all nodes trying to talk to each other.

Services can be created like so

```rust
let service1 = node.service_builder(&"service1".try_into().unwrap())
    .publish_subscribe::<u32>()
    .open_or_create()
    .unwrap();

let service2 = node.service_builder(&"service2".try_into().unwrap())
    .publish_subscribe::<u32>()
    .open_or_create()
    .unwrap();

let pubr1 = service1.publisher_builder().create().unwrap();
let subr2 = service2.subscriber_builder().create().unwrap();
```

Creating a publisher or a subscriber doesn't change anything, things still stay read only. No new files are created.
## Directory Structure

Iceoryx2 coordinates things using the common directory as shown above. It creates to subdirectories

```
├── nodes
│   ├── 14452078715246899539501196187
│   │   ├── test_374466749d8f04c5484c4c8b9fd7b414e5be7d142d1c71f.service_tag
│   │   ├── test_3744667d1fdca088f3d33e83582991ef43283e7293f4dab.service_tag
│   │   └── test_3744667node.details
│   ├── 15691263467035392578202029366
│   │   ├── test_359147849d8f04c5484c4c8b9fd7b414e5be7d142d1c71f.service_tag
│   │   └── test_3591478node.details
│   ├── test_359147815691263467035392578202029366.node_monitor
│   ├── test_359147815691263467035392578202029366.node_monitor_owner_lock
│   ├── test_374466714452078715246899539501196187.node_monitor
│   └── test_374466714452078715246899539501196187.node_monitor_owner_lock

└── services
    ├── test_359147849d8f04c5484c4c8b9fd7b414e5be7d142d1c71f.service
    ├── test_374466749d8f04c5484c4c8b9fd7b414e5be7d142d1c71f.service
    └── test_3744667d1fdca088f3d33e83582991ef43283e7293f4dab.service
```

We see that every node has the `<service_name>.service_tag` and for each service name we have a `<service_name>.service` file

1. the `node.details` files tell us details about nodes
2. the `.service` files contain details about services
3. the `node_monitor` files are for monitor the service like a heartbeet, and the `node_monitor_owner_lock` files are use with a unix "file lock" with the `flock(...)` syscall. Other files can try lock this file to check if this is held. Together, these files give three cases for a service
    1. present and alive (`node_monitor` file exists, `owner` file locked)
    2. present and dead (`node_monitor` file exists, `owner` file unlocked)
    3. not present (`node monitor` file does not exist)



### Node Detail Files
```toml
# cat test_prefix_unique_prefix_node.details
executable = "setup_teardown_tests"
name = "test_node"

[config.global]
root-path = "/tmp/iox2"
prefix = "test_prefix_unique_prefix_"

[config.global.service]
directory = "services"
data-segment-suffix = ".data"
static-config-storage-suffix = ".service"
dynamic-config-storage-suffix = ".dynamic"
connection-suffix = ".connection"
event-connection-suffix = ".event"
blackboard-mgmt-suffix = ".blackboard_mgmt"
blackboard-data-suffix = ".blackboard_data"

[config.global.service.creation-timeout]
secs = 0
nanos = 500000000

[config.global.node]
directory = "nodes"
monitor-suffix = ".node_monitor"
static-config-suffix = ".details"
service-tag-suffix = ".service_tag"
cleanup-dead-nodes-on-creation = true
cleanup-dead-nodes-on-destruction = true

[config.defaults.publish-subscribe]
max-subscribers = 8
max-publishers = 2
max-nodes = 20
subscriber-max-buffer-size = 2
subscriber-max-borrowed-samples = 2
publisher-max-loaned-samples = 2
publisher-history-size = 0
enable-safe-overflow = true
unable-to-deliver-strategy = "Block"
subscriber-expired-connection-buffer = 128

[config.defaults.event]
max-listeners = 16
max-notifiers = 16
max-nodes = 36
event-id-max-value = 255

[config.defaults.request-response]
enable-safe-overflow-for-requests = true
enable-safe-overflow-for-responses = true
max-active-requests-per-client = 4
max-response-buffer-size = 2
max-servers = 2
max-clients = 8
max-nodes = 20
max-borrowed-responses-per-pending-response = 2
max-loaned-requests = 2
server-max-loaned-responses-per-request = 2
client-unable-to-deliver-strategy = "Block"
server-unable-to-deliver-strategy = "Block"
client-expired-connection-buffer = 128
enable-fire-and-forget-requests = true
server-expired-connection-buffer = 128

[config.defaults.blackboard]
max-readers = 8
max-nodes = 20
```

### Service Detail File
```toml
❯ cat test_306457649d8f04c5484c4c8b9fd7b414e5be7d142d1c71f.service
service_id = "49d8f04c5484c4c8b9fd7b414e5be7d142d1c71f"
service_name = "service1"
attributes = []

[messaging_pattern.PublishSubscribe]
max_subscribers = 8
max_publishers = 2
max_nodes = 20
history_size = 0
subscriber_max_buffer_size = 2
subscriber_max_borrowed_samples = 2
enable_safe_overflow = true

[messaging_pattern.PublishSubscribe.message_type_details.header]
variant = "FixedSize"
type_name = "iceoryx2::service::header::publish_subscribe::Header"
size = 40
alignment = 8

[messaging_pattern.PublishSubscribe.message_type_details.user_header]
variant = "FixedSize"
type_name = "()"
size = 0
alignment = 1

[messaging_pattern.PublishSubscribe.message_type_details.payload]
variant = "FixedSize"
type_name = "u32"
size = 4
alignment = 4
```



## Synchronization


Synchronization is done using the `update_connections` functions.




### Implicit Behaviors

Receiving delegates to `receive_imple` which calls `self.update_connections()` in the hot loop.


```rust
fn receive_impl(&self) -> Result<Option<(ChunkDetails, Chunk)>, ReceiveError> {
    fail!(from self, when self.update_connections(),
            "Some samples are not being received since not all connections to publishers could be established.");

    self.subscriber_shared_state
        .lock()
        .receiver
        .receive(ChannelId::new(0))
}
```


A similar pattern is seen in send

```rust
pub(crate) fn send_sample(
    &self,
    offset: PointerOffset,
    sample_size: usize,
) -> Result<usize, SendError> {
    let msg = "Unable to send sample";
    if !self.is_active.load(Ordering::Relaxed) {
        fail!(from self, with SendError::ConnectionBrokenSinceSenderNoLongerExists,
            "{} since the corresponding publisher is already disconnected.", msg);
    }

    fail!(from self, when self.update_connections(),
        "{} since the connections could not be updated.", msg);

    self.add_sample_to_history(offset, sample_size);
    self.sender
        .deliver_offset(offset, sample_size, ChannelId::new(0))
}
```


Iceoryx2 performs live synchronization using the above filesystem.

1. When a node starts, it will create the `node_monitor` and `node_monitor_lock_owner` files.
2. When a publisher starts up, it will create the relevant service files. 
```
├── nodes
│   ├── 15691263467035392578202029366
│   │   ├── test_359147849d8f04c5484c4c8b9fd7b414e5be7d142d1c71f.service_tag*
│   │   └── test_3591478node.details
│   ├── test_359147815691263467035392578202029366.node_monitor*
│   ├── test_359147815691263467035392578202029366.node_monitor_owner_lock*

└── services
    ├── test_359147849d8f04c5484c4c8b9fd7b414e5be7d142d1c71f.service
```
3. A subscriber scans the this directory as follows
    1. Check the services directory files for the right service.
    2. Use the hash and check if any node has published it
        1. If yes, we connect and receive data
        2. If no, we don't connect and need to re-scan
4. When the publisher dies:
    1. *CLEANLY*
        1. It releases the lock
        2. deletes the file
    2. *UNCLEAN* (.e.g kill -9)
        1. kernel will release the lock on process cleanup
        2. When the directory is scanned again (e.g by a new subscriber). It will delete the heartbeat and lock files.

This leads to some interesting race conditions

#### Case 1 

> If a publisher starts up, sends a message but there is no subscriber
    1. Message is lost forever. Even future subscribers don't see the message

Consider this sequence
1. subscriber starts, but no pub yet: delegate connection (i.e need rescan)
2. publisher starts, sends message. No subscriber so no one receives the message
3. subscriber starts, connects, and doesn't  see the message


#### Case 2
> If a publisher starts up, sends a message and dies
    1. Message is lost forever but the service is also lost forever. No subscriber will ever see this service

Consider this sequence
1. subscriber starts, but no pub yet: delegate connection (i.e need rescan)
2. publisher starts, sends message. No subscriber so no one receives the message
3. publisher dies, cleans up the directory
4. subscriber starts, and doesn't  see the service, fails to connect


### Tips

We can ask subscribers to try connect again (i.e rescan the directory)

```rust
subr2.update_connections();
```



# DATA


## Experiment

Sub
Pub
write
read
drop(Pub)

works

```
write(1, "Press enter to receive values\n", 30Press enter to receive values
) = 30
read(0
, "\n", 8192)                     = 1
openat(AT_FDCWD, "/dev/shm/iox2_b9fc73e5c1f646968758453273c6c65cb372831b_169200532055247216953722010950_97131538944052651912143174982.connection", O_RDWR|O_NOFOLLOW|O_CLOEXEC) = 10
fcntl(10, F_GETFD)                      = 0x1 (flags FD_CLOEXEC)
fstat(10, {st_mode=S_IFREG|0700, st_size=342, ...}) = 0
mmap(NULL, 342, PROT_READ|PROT_WRITE, MAP_SHARED, 10, 0) = 0x7fae92f2a000
openat(AT_FDCWD, "/dev/shm/iox2_0354a209029e7d094a819e2d4030ea331e6caaf0_169200532055247216953722010950.data", O_RDWR|O_NOFOLLOW|O_CLOEXEC) = 11
fcntl(11, F_GETFD)                      = 0x1 (flags FD_CLOEXEC)
fstat(11, {st_mode=S_IFREG|0700, st_size=2198, ...}) = 0
mmap(NULL, 2198, PROT_READ|PROT_WRITE, MAP_SHARED, 11, 0) = 0x7fae92f29000
write(1, "Received: 42\n", 13Received: 42
)          = 13
munmap(0x7fae92f2c000, 2198)            = 0
```


```
write(1, "Press enter to create sub\n", 26Press enter to create sub
) = 26
read(0
, "\n", 8192)                     = 1
getpid()                                = 655787
mmap(NULL, 405504, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fe31aeb5000
openat(AT_FDCWD, "/dev/shm/iox2_b9fc73e5c1f646968758453273c6c65cb372831b_85822574609576621859251290539_163335176016140939635634864555.connection", O_RDWR|O_NOFOLLOW|O_CLOEXEC) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/dev/shm/iox2_b9fc73e5c1f646968758453273c6c65cb372831b_85822574609576621859251290539_163335176016140939635634864555.connection", O_RDWR|O_CREAT|O_EXCL|O_NOFOLLOW|O_CLOEXEC, 0200) = 9
fcntl(9, F_GETFD)                       = 0x1 (flags FD_CLOEXEC)
ftruncate(9, 342)                       = 0
mmap(NULL, 342, PROT_READ|PROT_WRITE, MAP_SHARED, 9, 0) = 0x7fe31b544000
fstat(9, {st_mode=S_IFREG|0200, st_size=342, ...}) = 0
fchmod(9, 0700)                         = 0
openat(AT_FDCWD, "/dev/shm/iox2_0354a209029e7d094a819e2d4030ea331e6caaf0_85822574609576621859251290539.data", O_RDWR|O_NOFOLLOW|O_CLOEXEC) = 10
fcntl(10, F_GETFD)                      = 0x1 (flags FD_CLOEXEC)
fstat(10, {st_mode=S_IFREG|0700, st_size=2198, ...}) = 0
mmap(NULL, 2198, PROT_READ|PROT_WRITE, MAP_SHARED, 10, 0) = 0x7fe31b543000
write(1, "Press enter to send samples\n", 28Press enter to send samples
) = 28
read(0
```