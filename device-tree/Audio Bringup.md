

We have 

1. Codec: responsible for decoding and encoding data on the wire (between digital and analog signals). This is connected to the cpu using i2c (usually) for configuration.
2. The Codec is connected the the cpu via another link called the digital audio link (`DAI`) . Usually, dai is i2s.
3. 