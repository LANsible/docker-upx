# docker-upx
[![Build Status](https://github.com/LANsible/docker-upx/actions/workflows/docker.yml/badge.svg)](https://github.com/LANsible/docker-upx/actions/workflows/docker.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/lansible/upx.svg)](https://hub.docker.com/r/lansible/upx)
[![Docker Version](https://img.shields.io/docker/v/lansible/upx.svg?sort=semver)](https://hub.docker.com/r/lansible/upx)
[![Docker Size/Layers](https://img.shields.io/docker/image-size/lansible/upx.svg?sort=semver)](https://hub.docker.com/r/lansible/upx)

Dockerized static UPX which allows easy copy and usage of UPX.
Since the arm64 builds of UPX seem non existing for Alpine I needed this :)

## Usage

### Direct

Run it directly on a mapped volume
```bash
docker run --rm -v "$PWD/foo:/foo" lansible/upx --ultra-brute -o /foo/bar.upx /foo/bar
```

### Docker multistage

Use it to minify binaries in a multistage Docker build
```
FROM your/baseimage
COPY --from=lansible/upx /usr/bin/upx /usr/bin/upx
RUN upx --ultra-brute --ultra-brute --best -o /foo/bar.upx /foo/bar
```

## Help

Run the image without a command to see the UPX help
```bash
docker run --rm lansible/upx
```

For more information about UPX see [upx/upx](https://github.com/upx/upx) and their [documentation](https://github.com/upx/upx/blob/master/doc/upx.pod)

## Building

The image accepts a build-arg that sets the UPX version to build. This arg gets passed to `git clone --branch <arg>`, so everything --branch supports will work (branches & tags)
Also it uses the [multiarch/alpine](https://hub.docker.com/r/multiarch/alpine) image for easy QEMU emulation. To be able to cross-compile register the binaries first:
```console
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```
Then pass the `ARCHITECTURE` build-arg to cross-compile for arm64 for example.
```console
docker build . -t upx:devel --build-arg VERSION=devel --build-arg ARCHITECTURE=amd64
```