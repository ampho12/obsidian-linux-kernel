

## Linux Camera Graph

Linux with the media controller model treats imaging HARDWARE as a directed graph of blocks. Each block does on tranform or transport

1. Blocks = entities (subdevs): this is the hardware
    1. Sensor (e.g. IMX477)
    2. CSI receiver
    3. DMA 
    4. CODEC
    5. ISP stage
    6. Scaler
2. Edges = links
    1. Who can feed who
3. Endpoints
    1. Video nodes where electrical signals can be read / written as bytes.


### Entities

Come in two flavors
1. Subdevice entities: (`/dev/v4l-subdev*`) configurable hardware blocks
2. Video entities (`/dev/video*`) these are the endpoints where electrical signals turn digitital
    1. DMA in/out. (usually lower numbered `/dev/videoX` devices)
    2. ISP in/out (usually higher numbered `/dev/videoX` devices)
    
### Pads

Pad is a PORT on an Entity

1. SINK pad: ingress
2. SOURCE pad: egress

Pads are not software they are just labelled connectors on the blocks. A camera sensor has a pad (perhaps more)

Why pads matter: formats and routing are set per pad.
You don’t say “camera is 1080p Bayer”; you say “sensor source pad outputs SRGGB12 4056×3040.”
### Links

A link connects SOURCE <-> SINK pads.

Links can be
1. enabled or disabled (i.e routing)
2. immutable (hardwared and cannot change).

This is like a switch board.



## Cheatsheet

- Entity: a hardware block (node in graph)
- Pad: an input/output port on an entity
- Link: a connection between pads (edge in graph)
- Video node (/dev/videoX): DMA endpoint to/from memory 
- Subdev node (/dev/v4l-subdevX): configurable internal block 
- Front end / back end: early vs late positions in the stream 
- ISP/DMA/CSI: common hardware blocks implementing standard roles
- Pipeline: a chosen route + compatible formats + buffers


## Worked Example

Say we connect a camera over the raspberry pi csi port

```
imx477 (sensor[entity])
   |
   v
csi2 receiver [entity]
  | \
  |  \
  |   -> pisp-fe -> pispbe -> /dev/video20+
  |
   -> rp1-cfe-csi2_ch* -> /dev/video0-7
```

We can see the `media-ctl` output to inspect the video graph. An example is below. We don't need to understand all of it.

```
[root@nixos-sd-card:~]# media-ctl -d /dev/media0 -p
Media controller API version 6.12.47

Media device information
------------------------
driver          rp1-cfe
model           rp1-cfe
serial
bus info        platform:1f00110000.csi
hw revision     0x114666
driver version  6.12.47

Device topology
- entity 1: csi2 (8 pads, 9 links, 0 routes)
            type V4L2 subdev subtype Unknown flags 0
            device node name /dev/v4l-subdev0
        pad0: SINK
                [stream:0 fmt:SRGGB10_1X10/640x480 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]
                <- "imx477 10-001a":0 [ENABLED,IMMUTABLE]
        pad1: SINK
                [stream:0 fmt:unknown/16384x1 field:none]
                <- "imx477 10-001a":1 [ENABLED,IMMUTABLE]
        pad2: SINK
                [stream:0 fmt:SRGGB10_1X10/640x480 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]
        pad3: SINK
                [stream:0 fmt:SRGGB10_1X10/640x480 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]
        pad4: SOURCE
                [stream:0 fmt:SRGGB10_1X10/640x480 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]
                -> "rp1-cfe-csi2_ch0":0 []
                -> "pisp-fe":0 []
        pad5: SOURCE
                [stream:0 fmt:unknown/16384x1 field:none]
                -> "rp1-cfe-embedded":0 []
        pad6: SOURCE
                [stream:0 fmt:SRGGB10_1X10/640x480 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]
                -> "rp1-cfe-csi2_ch2":0 []
                -> "pisp-fe":0 []
        pad7: SOURCE
                [stream:0 fmt:SRGGB10_1X10/640x480 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]
                -> "rp1-cfe-csi2_ch3":0 []
                -> "pisp-fe":0 []

- entity 10: pisp-fe (5 pads, 7 links, 0 routes)
             type V4L2 subdev subtype Unknown flags 0
             device node name /dev/v4l-subdev1
        pad0: SINK,MUST_CONNECT
                [stream:0 fmt:SRGGB16_1X16/640x480 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]
                <- "csi2":4 []
                <- "csi2":6 []
                <- "csi2":7 []
        pad1: SINK
                [stream:0 fmt:FIXED/16384x1 field:none]
                <- "rp1-cfe-fe_config":0 []
        pad2: SOURCE
                [stream:0 fmt:SRGGB16_1X16/640x480 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]
                -> "rp1-cfe-fe_image0":0 []
        pad3: SOURCE
                [stream:0 fmt:SRGGB16_1X16/640x480 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]
                -> "rp1-cfe-fe_image1":0 []
        pad4: SOURCE
                [stream:0 fmt:FIXED/16384x1 field:none]
                -> "rp1-cfe-fe_stats":0 []

- entity 16: imx477 10-001a (2 pads, 2 links, 0 routes)
             type V4L2 subdev subtype Sensor flags 0
             device node name /dev/v4l-subdev2
        pad0: SOURCE
                [stream:0 fmt:SRGGB12_1X12/4056x3040 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range
                 crop.bounds:(8,16)/4056x3040
                 crop:(8,16)/4056x3040]
                -> "csi2":0 [ENABLED,IMMUTABLE]
        pad1: SOURCE
                [stream:0 fmt:unknown/16384x1 field:none
                 crop.bounds:(8,16)/4056x3040
                 crop:(8,16)/4056x3040]
                -> "csi2":1 [ENABLED,IMMUTABLE]
```


Notice that entity1 is the csi port and only pad0 and pad1 are enabled. This does NOT mean they are the only one connected, just enabled. The connections are seen in the `->` and `<-` arrows. 

They are also what eneity 16 source pads are 


```
- entity 16: imx477 10-001a (2 pads, 2 links, 0 routes)
             type V4L2 subdev subtype Sensor flags 0
             device node name /dev/v4l-subdev2
        pad0: SOURCE
                [stream:0 fmt:SRGGB12_1X12/4056x3040 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range
                 crop.bounds:(8,16)/4056x3040
                 crop:(8,16)/4056x3040]
                -> "csi2":0 [ENABLED,IMMUTABLE] --------- connection to entity1
        pad1: SOURCE
                [stream:0 fmt:unknown/16384x1 field:none
                 crop.bounds:(8,16)/4056x3040
                 crop:(8,16)/4056x3040]
                -> "csi2":1 [ENABLED,IMMUTABLE] --------- connection to entity1
```

and we see these on entity1


```
- entity 1: csi2 (8 pads, 9 links, 0 routes)
            type V4L2 subdev subtype Unknown flags 0
            device node name /dev/v4l-subdev0
        pad0: SINK
                [stream:0 fmt:SRGGB10_1X10/640x480 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]
                <- "imx477 10-001a":0 [ENABLED,IMMUTABLE]
        pad1: SINK
                [stream:0 fmt:unknown/16384x1 field:none]
                <- "imx477 10-001a":1 [ENABLED,IMMUTABLE]
```

Similarly, check `/dev/video0` or 

(`/dev/media0`) is just luck, try all 4 `media{0-3}`

```
[root@nixos-sd-card:~]# media-ctl -d /dev/media0 -p | grep video0 -B2 -A3
- entity 19: rp1-cfe-csi2_ch0 (1 pad, 1 link)
             type Node subtype V4L flags 0
             device node name /dev/video0
        pad0: SINK,MUST_CONNECT
                <- "csi2":4 []
```

We see that it is connected to csi2 pad 4 but not enabled

```
- entity 1: csi2 (8 pads, 9 links, 0 routes)
        ... other pads ....
        
        pad4: SOURCE
                [stream:0 fmt:SRGGB10_1X10/640x480 field:none colorspace:raw xfer:none ycbcr:601 quantization:full-range]
                -> "rp1-cfe-csi2_ch0":0 []
                -> "pisp-fe":0 []
                
        ... other pads

```

# CSI

A CSI camera pipeline has the following conceptual blocks


1. Sensor: produces a CSI-2 stream that is sent over the CSI cable
2. CSI PHY: D-PHY that terminates the CSI lanes (clocks +data)
3. CSI Receiver / Host / CSI-RX / CSI2-Host: Decodes the CSI2 packets into pixels / lines.
4. VI / VIN / CSI-CAP / ISP FE (Video Input): DMA/capture engine that feeds memory/ISP

Vendors may not model them directly as 4 blocks. These are purely conceptual


# `camera_cma_reserved`

1. A reserved dma pool for the camera buffers

```dts
		camera_cma_reserved:linux,camera_cma {
			compatible = "shared-dma-pool";
			reusable;
			status = "okay";
			size = <0x0 0xB000000>;
			alignment = <0x0 0x400000>;
			alloc-ranges = <0x0 0x0 0x0 0xe0000000>;
		};

```






# `csiphy`


This is a CSI-2 D-PHY receiver on the SoC. 

It terminates the clock lane and N data lanes coming from the camera sensor.

## `Ports` and `Endpoints`


Each hardware block exposes one or more `ports`

Each port contains an `endpoint`. An endpoint connects to another endopint. We always have a two way link. To illustrate:

```
ep1: endpoint {
    remote_endpoint = <&ep2>;
};

ep2: endpoint {
    remote_endpoint = <&ep1>;
};
```

> So `port` and `endpoint` have a one-to-one mapping 

Two endpoints can be connected with a `remote-endpoint`. This is called **graph bindings** and is used by the linux media driver.

Here is a concrete example  

```dts
&csiphy0 {
	ports {
		port@0 {
			csiphy0_ep_2: endpoint {
				reg = <0>;
				status = "okay";
				clock-lanes = <4>;
				data-lanes = <0 1 2 3>;
				remote-endpoint = <&amlsens_0_ep>;
			};
		};
		port@1 {
			csiphy0_ep_4: endpoint {
				reg = <1>;
				status = "disabled";
				clock-lanes = <4>;
				data-lanes = <0 1 2 3>;
				remote-endpoint = <&amlsens_1_ep>;
			};
		};
	};
};
```


# Sensor

This exists on the physical camera and not the SoC but we make a dt entry to talk to it (e.g. over i2c).

```dts

&i2c2 {
	status = "okay";
	pinctrl-names = "default";//, "sleep"
	pinctrl-0 = <&i2c2_pins3>;
	//pinctrl-1 = <&i2c2_sleep_pins2>;
	clock-frequency = <100000>; /* default 100k */

	amlsens_0: sensor0@36 {
		compatible = "amlogic, sensor";
		status = "okay";
		index = <0>;
		reg = <0x36>;
		reg-addr-type = <2>;
		reg-data-type = <1>;

		clocks = <&clkc CLKID_MCLK_0>,
				<&clkc CLKID_MCLK_0_SEL>,
				<&clkc CLKID_MCLK_0_PRE>,
				<&clkc CLKID_MCLK_PLL>,
				<&xtal>;
		clock-names = "mclk","mclk_sel","mclk_pre","mclk_p","mclk_x";
		reset-gpios = <&gpio GPIOM_5 GPIO_ACTIVE_HIGH>;
		ircut-gpios = <&gpio GPIOM_11 GPIO_ACTIVE_HIGH>;
		port
		 {
			amlsens_0_ep: endpoint {
				data-lanes = <0 1 2 3>;
				link-frequencies = /bits/ 64 <1440000000>;
				remote-endpoint = <&csiphy0_ep_2>;
			};
		};
	};

	amlsens_1: sensor1@1a {
		compatible = "amlogic, sensor";
		status = "disabled";
		index = <0>;
		reg = <0x1a>;
		reg-addr-type = <2>;
		reg-data-type = <1>;

		lens-focus = <&dw9714>;
		clocks = <&clkc CLKID_MCLK_0>,
				<&clkc CLKID_MCLK_0_SEL>,
				<&clkc CLKID_MCLK_0_PRE>,
				<&clkc CLKID_MCLK_PLL>,
				<&xtal>;
		clock-names = "mclk","mclk_sel","mclk_pre","mclk_p","mclk_x";
		pwdn-gpios = <&gpio GPIOM_5 GPIO_ACTIVE_HIGH>;
		reset-gpios = <&gpio GPIOM_11 GPIO_ACTIVE_HIGH>;
		port@0 {
			amlsens_1_ep: endpoint {
				reg = <0>;
				data-lanes = <0 1 2 3>;
				link-frequencies = /bits/ 64 <1440000000>;
				remote-endpoint = <&csiphy0_ep_4>;
			};
		};
	};
};
```


# CSI - RX / VI

These could be purely in software driver







## VIM4 Bringup


# Compiling the kernel


```
# On an x86_64 Ubuntu machine (or natively on the VIM4 if you prefer)
git clone https://github.com/khadas/fenix.git
cd fenix
source env/setenv.sh        # pick: BOARD=VIM4, Linux 5.15 (or 5.4 if that’s your image), distro, etc.

# Use the readme to download the docker and setup for build

make kernel-config          # opens menuconfig
# Navigate: Device Drivers → Multimedia support → Camera sensor devices → OmniVision OV5647
# Set to <M> (module) or <*> (built-in). I recommend <M> first.

make kernel
make kernel-deb             # creates .deb packages

```

To change options

```
make kernel-config
make kernel-saveconfig
```

then for any git related prompts, press enter

This is the defconfig used by kvim

```
Iarch/arm64/configs/kvims_defconfig
```

`vdin-v4l`, ...,  `video70`, `video80` are Amlogic video in devices.


```
make kernel
```

builds the actual


There is a `cam_prober.c` file in the `common_drivers` repo from khadas.

```
#ifdef CONFIG_AMLOGIC_VIDEO_CAPTURE_OV5647
	{
		.addr = 0x36, /* really value should be 0x6c  */
		.name = "ov5647", .pwdn = 1, .max_cap_size = SIZE_2592X1944,
		.probe_func = ov5647_v4l2_probe,
	},
#endif

```
# ov5647

Is a 2 lane camera


# Kernel 


Camera setup woes

```
❯ cat drivers/media/platform/raspberrypi/hevc_dec/Kconfig
# SPDX-License-Identifier: GPL-2.0

config VIDEO_RPI_HEVC_DEC
        tristate "Rasperry Pi HEVC decoder"
        depends on VIDEO_DEV && VIDEO_DEV
        depends on OF
        select MEDIA_CONTROLLER
        select MEDIA_CONTROLLER_REQUEST_API
        select VIDEOBUF2_DMA_CONTIG
        select V4L2_MEM2MEM_DEV
        help
          Support for the Raspberry Pi HEVC / H265 H/W decoder as a stateless
          V4L2 decoder device.

          To compile this driver as a module, choose M here: the module
          will be called rpi-hevc-dec.
```

This should be enabled (?)

ALso make sure CMA_SIZE_MBYTES = 256 and not 5 (otherwise camera won't start with EINVAL)



RPI CAMERA connection


i2c@88000 is on csi0 (closer to the usb part) -> cam1

i2c@80000 is on cs1 (farther from the usb port) -> cam2


# IMX477 Camera Pixel Formats

## Format Notation
`(32x32)-(4056x3040)/(+2,+2)` means:
- **Min resolution**: 32×32 pixels
- **Max resolution**: 4056×3040 pixels (full IMX477 sensor)
- **Alignment**: +2,+2 (width/height must be even numbers)

---

## **RAW BAYER FORMATS** (Sensor Native - Unprocessed)
Direct from sensor, requires ISP processing (demosaicing) to view.

| Format | Bits/pixel | Description |
|--------|-----------|-------------|
| `SRGGB8/10/12/14/16` | 8-16 | Raw Bayer RGGB pattern |
| `SGBRG8/10/12/14/16` | 8-16 | Raw Bayer GBRG pattern |
| `SGRBG8/10/12/14/16` | 8-16 | Raw Bayer GRBG pattern |
| `SBGGR8/10/12/14/16` | 8-16 | Raw Bayer BGGR pattern |
| `*_PISP_COMP1` | Compressed | PiSP-compressed Bayer (Pi 5 specific) |

**Use case**: Computer vision, HDR, maximum quality control

---

## **YUV FORMATS** (Best for Video/Streaming)

| Format | Layout | Bits/pixel | Bandwidth | Best for |
|--------|--------|-----------|-----------|----------|
| **`YUV420`** | Planar | 12 | **~9 MB/s** | **Streaming** ✅ |
| **`NV12`** | Semi-planar | 12 | **~9 MB/s** | **Streaming** ✅ |
| `NV21` | Semi-planar | 12 | ~9 MB/s | Streaming |
| `YVU420` | Planar | 12 | ~9 MB/s | Streaming |
| `YUV422` | Planar | 16 | ~12 MB/s | Better quality |
| `YUYV/UYVY/YVYU/VYUY` | Packed | 16 | ~12 MB/s | Compatibility |
| `YUV444` | Planar | 24 | ~18 MB/s | Full chroma |

**Recommended: `YUV420` or `NV12`** - 50% smaller than RGB, perfect for network streaming

---

## **RGB FORMATS** (Display/Processing)

| Format | Bits/pixel | Bandwidth | Description |
|--------|-----------|-----------|-------------|
| **`RGB888`** | 24 | **27.6 MB/s** | What you're using now |
| `BGR888` | 24 | 27.6 MB/s | Byte-swapped RGB |
| `XRGB8888` | 32 | 36.9 MB/s | RGB + 8 padding bits |
| `XBGR8888` | 32 | 36.9 MB/s | BGR + 8 padding bits |
| `RGB161616` | 48 | 55.3 MB/s | 16-bit per channel (HDR) |
| `BGR161616` | 48 | 55.3 MB/s | 16-bit per channel (HDR) |

---

## **MONOCHROME FORMATS**

| Format | Bits/pixel | Description |
|--------|-----------|-------------|
| `R8` | 8 | 8-bit grayscale |
| `R16` | 16 | 16-bit grayscale |
| `MONO_PISP_COMP1` | Compressed | PiSP-compressed mono |

---

## **Recommendations for Your Use Case**

**Current**: `RGB888` (24 bpp, 27.6 MB/s)
**Switch to**: `YUV420` or `NV12` (12 bpp, **9 MB/s**) ← **50% bandwidth reduction** ✅

Both YUV420 and NV12 are identical quality, just different memory layout. NV12 is slightly more common in modern systems.

---

## **Bandwidth Comparison @ 640×480×30fps**

| Format | Bytes/pixel | MB/sec | % of RGB888 |
|--------|-------------|--------|-------------|
| RGB888 | 3.0 | 27.6 | 100% |
| YUV444 | 3.0 | 27.6 | 100% |
| YUV422/YUYV | 2.0 | 18.4 | 67% |
| **YUV420/NV12** | **1.5** | **13.8** | **50%** |
| Raw Bayer 10-bit | 1.25 | 11.5 | 42% |

---

## **How to Switch Formats in libcamera**

### In C++ code:
```cpp
// Change from RGB888 to YUV420
stream_config.pixelFormat = PixelFormat::fromString("YUV420");
// or
stream_config.pixelFormat = PixelFormat::fromString("NV12");
```

### Using cam utility:
```bash
# Test YUV420
cam --camera 1 --capture=10 --stream pixelformat=YUV420,width=640,height=480

# Test NV12
cam --camera 1 --capture=10 --stream pixelformat=NV12,width=640,height=480
```
