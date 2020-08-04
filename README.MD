# docker-upx

Dockerized static UPX which allows easy copy and usage of UPX.

## Usage

### Direct

Run it directly on a mapped volume
```bash
docker run --rm -v "$PWD/foo:/foo" upx:master --ultra-brute -o /foo/bar.upx /foo/bar
```

### Docker multistage

Use it to minify binaries in a multistage Docker build
```
FROM upx:master AS upx
FROM your/baseimage
COPY --from=upx /usr/bin/upx /usr/bin/upx
RUN upx --ultra-brute --ultra-brute --best -o /foo/bar.upx /foo/bar
```

## Help

Run the image without a command to see the UPX help
```bash
docker run --rm  upx:master
```

For more information about UPX see [upx/upx](https://github.com/upx/upx) and their [documentation](https://github.com/upx/upx/blob/master/doc/upx.pod)

## Building

The image accepts a build-arg that sets the UPX version to build. This arg gets passed to `git clone --branch <arg>`, so everything --branch supports will work (branches & tags)
```bash
docker build . -t upx:devel --build-arg VERSION=devel
```