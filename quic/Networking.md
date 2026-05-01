


# Path Maximum Transmission Unit / Datagram Size

The PMTU is the larget packet that can travel end-to-end on a path without getting fragmented by the routers.

Every link has an MTU. (common Ethrnet MTU is 1500 bytes). The path MTU is the smallest MTU that can go without being split across all hops. If we send a packet bigger than MTU, then something has to split it.

The ideas is to make packets as large as possible without fragmentation. Fragmentation means increase the chance of dropping the fragment. Fragmentation is expensive and fragile.

DF bit is the dont' forget bit. it is a flag in IPv4 header which says that if this packet is too big and must be fragmented, drop it instead. Modern transports prefer dropping so the sender learns the right PMTU.


DF is used in PMTU discovery as follows:

1. Sender transmits with a DF set
2. IF a hop can't forward (packet too big), it drops and sends ICMP `frag needed` back to the sender.
3. Sender reduces packet size.








# Kernel and NIC

UDP has no built in flow control -- kernel needs big buffers. If buffer fills up, new packets are simply dropped causing "pacing" issues.

To detect if packet is being dropped
```
netstat -su
```

When quic sees loss, it will back off. 

for GBE we need tens of MB


Then we need to set the app buffer using `SO_SNDBUF` and `SO_RCVBUF` `sockopt` calls.

For this, we need to make sure net.core.rmem_max and wmem_max are set correctly.

## Batching

WIthout batching, CPU bound and way below line rate.

## GSO Support

TCP gets TSO/GSO for free. TSO is a TCP only Segmentation Offload. Kernel can take a large buffer, say 64KB directly to nic. This "Super packet" is sent to the NIC and NIC packetizes into tcp segements directly. 


GSO is generic segmentation offload. It is the generalized version of TSO and can apply to both GSO and TSO. Without this, quic will send many small UDP packets.

We need to turen on UDP GSO if avaibable and nic supports.

It leds app hand big chunks to NIC and have them segmented efficiently.


# QUIC flow control

## Credit Based Flow Control

The receiver tells the sender: "you must send up to N bytes before you must wait". This "N" is the flow control window. There are two types of windows:

(QUIC has two windows compared to one huge auto tuned window).

### Connection Flow Control Window

The maximum number of bytes in flight across all streams before receiver grants more credit.

### Stream Flow Control Window
This is the per stream window.

The windows expand dynamically. in RTT sized steps. Setting big windows helps keep this large enough.







# Control channel negotiation
  There's no negotiation — it's a convention. The client always opens the first bidi stream (stream ID 0 in QUIC), and the server accepts it as the control channel. That's it.

  Client opens stream 0 (bidi)
  Server sees stream 0 become readable → "this is the control stream"

  Both sides write length-prefixed messages on it: [u32 len][payload bytes]. The receiver buffers until it has a full message, then decodes.

  No handshake, no "please be my control stream" message. Stream 0 from the client = control channel, by convention.