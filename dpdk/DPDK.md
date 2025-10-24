

# Packet Processing In DPDK

1. Incoming packets go into a ring buffer. Applications periodically check this buffer
2. If the buffer contains new packet descriptors, the application will refer to the DPDK packet buffers in the specially allocated memory pool using the pointers in the packet descriptors.
3. If the ring buffer does not contain any packets, the application will queue the network devices under the DPDK and then refer to the ring again.

## Environment Abstraction Layer (EAL)

EAL is set of programming tools that let DPDK work in a specific hardware environment and under a specific operating system.

## DPDK Extended Statistics (xstats)

DPDK xstats provide detailed per-port statistics for monitoring network interface performance and health. These statistics are accessible via `rte_eth_xstats_get()` API or testpmd's `show port xstats` command.

| Statistic Name | Category | Description |
|----------------|----------|-------------|
| `rx_good_packets` | RX Basic | Successfully received packets without errors |
| `tx_good_packets` | TX Basic | Successfully transmitted packets without errors |
| `rx_good_bytes` | RX Basic | Total bytes in successfully received packets |
| `tx_good_bytes` | TX Basic | Total bytes in successfully transmitted packets |
| `rx_missed_errors` | RX Errors | Packets dropped due to lack of receive buffers |
| `rx_errors` | RX Errors | General receive errors (CRC, alignment, etc.) |
| `tx_errors` | TX Errors | General transmission errors |
| `rx_mbuf_allocation_errors` | RX Errors | Failed mbuf allocations for received packets |
| `rx_crc_errors` | RX Errors | Packets with CRC (checksum) errors |
| `rx_align_errors` | RX Errors | Packets with alignment errors |
| `rx_symbol_errors` | RX Errors | Physical layer symbol errors |
| `rx_missed_packets` | RX Errors | Packets missed due to hardware buffer overflow |
| `tx_single_collision_packets` | TX Ethernet | Packets with exactly one collision before success |
| `tx_multiple_collision_packets` | TX Ethernet | Packets with multiple collisions before success |
| `tx_excessive_collision_packets` | TX Ethernet | Packets dropped due to too many collisions |
| `tx_late_collisions` | TX Ethernet | Late collision errors during transmission |
| `tx_total_collisions` | TX Ethernet | Total number of collision events |
| `tx_deferred_packets` | TX Ethernet | Packets deferred due to medium busy |
| `tx_no_carrier_sense_packets` | TX Ethernet | Transmissions without carrier sense |
| `rx_carrier_ext_errors` | RX Ethernet | Carrier extension errors |
| `rx_length_errors` | RX Errors | Packets with invalid length field |
| `rx_xon_packets` | Flow Control | XON (resume transmission) packets received |
| `tx_xon_packets` | Flow Control | XON packets transmitted |
| `rx_xoff_packets` | Flow Control | XOFF (pause transmission) packets received |
| `tx_xoff_packets` | Flow Control | XOFF packets transmitted |
| `rx_flow_control_unsupported_packets` | Flow Control | Unsupported flow control packets |
| `rx_size_64_packets` | RX Size Distribution | Packets of exactly 64 bytes |
| `rx_size_65_to_127_packets` | RX Size Distribution | Packets between 65-127 bytes |
| `rx_size_128_to_255_packets` | RX Size Distribution | Packets between 128-255 bytes |
| `rx_size_256_to_511_packets` | RX Size Distribution | Packets between 256-511 bytes |
| `rx_size_512_to_1023_packets` | RX Size Distribution | Packets between 512-1023 bytes |
| `rx_size_1024_to_max_packets` | RX Size Distribution | Packets between 1024-MTU size |
| `tx_size_64_packets` | TX Size Distribution | 64-byte packets transmitted |
| `tx_size_65_to_127_packets` | TX Size Distribution | 65-127 byte packets transmitted |
| `tx_size_128_to_255_packets` | TX Size Distribution | 128-255 byte packets transmitted |
| `tx_size_256_to_511_packets` | TX Size Distribution | 256-511 byte packets transmitted |
| `tx_size_512_to_1023_packets` | TX Size Distribution | 512-1023 byte packets transmitted |
| `tx_size_1024_to_max_packets` | TX Size Distribution | 1024+ byte packets transmitted |
| `rx_broadcast_packets` | RX Traffic Type | Broadcast packets received |
| `rx_multicast_packets` | RX Traffic Type | Multicast packets received |
| `tx_broadcast_packets` | TX Traffic Type | Broadcast packets transmitted |
| `tx_multicast_packets` | TX Traffic Type | Multicast packets transmitted |
| `rx_undersize_errors` | RX Errors | Packets smaller than minimum frame size |
| `rx_fragment_errors` | RX Errors | Fragment packets received |
| `rx_oversize_errors` | RX Errors | Packets larger than maximum frame size |
| `rx_jabber_errors` | RX Errors | Jabber condition packets |
| `rx_management_packets` | Management | Management protocol packets received |
| `rx_management_dropped` | Management | Management packets dropped |
| `tx_management_packets` | Management | Management protocol packets sent |
| `rx_total_packets` | RX Totals | All packets received (including errors) |
| `tx_total_packets` | TX Totals | All packets transmitted (including errors) |
| `rx_total_bytes` | RX Totals | All bytes received (including error packets) |
| `tx_total_bytes` | TX Totals | All bytes transmitted (including error packets) |
| `tx_tso_packets` | Offload | TCP Segmentation Offload packets |
| `tx_tso_errors` | Offload | TSO processing errors |
| `rx_sent_to_host_packets` | SR-IOV | Packets forwarded to host (VF context) |
| `tx_sent_by_host_packets` | SR-IOV | Packets sent by host (VF context) |
| `rx_code_violation_packets` | Physical Layer | Code violation errors |
| `interrupt_assert_count` | Hardware | Number of interrupt assertions |

### Key Performance Indicators

- **Packet Loss**: `rx_missed_errors` and `rx_missed_packets` indicate buffer overflow
- **Error Rate**: Compare `rx_errors` vs `rx_good_packets` for error percentage
- **Flow Control**: High `rx_xoff_packets`/`tx_xoff_packets` may indicate congestion
- **Size Distribution**: Shows traffic patterns and optimization opportunities
- **Hardware Health**: Non-zero collision counters may indicate duplex mismatch

### Usage

```c
// Get xstats count
int len = rte_eth_xstats_get_names(port_id, NULL, 0);

// Get xstats names and values
struct rte_eth_xstat_name *xstats_names = malloc(len * sizeof(*xstats_names));
struct rte_eth_xstat *xstats = malloc(len * sizeof(*xstats));
rte_eth_xstats_get_names(port_id, xstats_names, len);
rte_eth_xstats_get(port_id, xstats, len);
```

