

# Building as a deb

can be installed using apt



checks if a config option is set

```
dpkg-deb -c ./linux-image-amlogic-5.15_1.7.4_arm64.deb | grep -i ov5647
```


this will unpackage and put the whole thing into the specified directory
```
dpkg-deb -x ./linux-image-amlogic-*.deb /tmp/kimg
```