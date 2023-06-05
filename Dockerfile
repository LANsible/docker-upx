FROM alpine:3.18 as builder

LABEL org.label-schema.description="UPX UPX'ed in a convenient container"

# https://github.com/upx/upx/releases
ENV VERSION=v4.0.2

# Install build deps
RUN apk add --no-cache \
    build-base \
    ucl-dev \
    zlib-dev \
    zlib-static \
    git \
    cmake

# Clone specific branch or tag based of build-arg, --recursive since upx uses a submodule
RUN git clone --depth 1 --recursive --branch "${VERSION}" https://github.com/upx/upx.git /upx

WORKDIR /upx
# remove the git directory to avoid parsing the git tag (v4.0.1) and using that as the version
# must use the version in the src/version.h without the v prefix
# for example pyinstaller parses this and it breaks with the prefix
RUN CORES=$(grep -c '^processor' /proc/cpuinfo); \
    export MAKEFLAGS="-j$((CORES+1)) -l${CORES}"; \
    rm -rf .git && \
    make \
      CFLAGS="-O3 -static" \
      LDFLAGS="-static"

# Self minify upx
RUN ./build/release/upx --best -o /usr/bin/upx ./build/release/upx && \
    upx -t /usr/bin/upx


# Final image
FROM scratch
COPY --from=builder /usr/bin/upx /usr/bin/upx
ENTRYPOINT ["/usr/bin/upx"]
CMD ["--help"]
