# 交叉编译 arm64 架构的 libyaml

```bash
wget https://github.com/yaml/libyaml/archive/refs/tags/0.2.5.tar.gz
tar xzf 0.2.5.tar.gz
cd libyaml-0.2.5
autoreconf -fiv
./configure --host=aarch64-linux-gnu --prefix=/path/to/arm64/lib
make
make install
```

# 编译 dtc 

```bash
➜  dtc git:(v1.7.1) make CC=aarch64-linux-gnu-gcc \
     AR=aarch64-linux-gnu-ar \
     RANLIB=aarch64-linux-gnu-gcc-ranlib \
     CFLAGS="-I/path/to/arm64/lib/include" \
     LDFLAGS="-L/path/to/arm64/lib/lib -Wl,-rpath,/path/to/arm64/lib/lib" \
     LIBS="-lyaml"
```
