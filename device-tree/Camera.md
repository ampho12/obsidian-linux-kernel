
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