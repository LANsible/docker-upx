# Inspired by: https://github.com/0xdevalias/docker-upx/blob/master/Dockerfile
FROM alpine:3.8 AS builder

LABEL maintainer="Wilmar den Ouden" \
    description="UPX UPX'ed in a convenient container"

ARG VERSION=master

# Install build deps
RUN apk add --no-cache \
    build-base \
    ucl-dev \
    zlib-dev \
    git

# Clone specific branch or tag based of build-arg, --recursive since upx uses a submodule
RUN git clone --depth 1 --recursive --branch "${VERSION}" https://github.com/upx/upx.git /upx

# Compile static, CHECK_WHITESPACE is needed, throws bash not found otherwise
RUN cd /upx/src && \
    LDFLAGS=-static make -j2 upx.out CHECK_WHITESPACE=

# Self minify upx
RUN /upx/src/upx.out --ultra-brute --overlay=strip -o /usr/bin/upx /upx/src/upx.out

# Final image
FROM scratch
COPY --from=builder /usr/bin/upx /usr/bin/upx
ENTRYPOINT ["/usr/bin/upx"]
CMD ["--help"]