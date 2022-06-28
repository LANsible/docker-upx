FROM alpine:3.16 as builder

LABEL org.label-schema.description="UPX UPX'ed in a convenient container"

# Need devel until this is tagged
# https://github.com/upx/upx/issues/441
ARG VERSION=devel

# Install build deps
RUN apk add --no-cache \
    build-base \
    ucl-dev \
    zlib-dev \
    zlib-static \
    git

# Clone specific branch or tag based of build-arg, --recursive since upx uses a submodule
RUN git clone --depth 1 --recursive --branch "${VERSION}" https://github.com/upx/upx.git /upx

WORKDIR /upx/src
# CHECK_WHITESPACE is needed, throws bash not found otherwise
RUN CORES=$(grep -c '^processor' /proc/cpuinfo); \
    export MAKEFLAGS="-j$((CORES+1)) -l${CORES}"; \
    make \
        LDFLAGS=-static \
        CHECK_WHITESPACE= \
        upx.out

# Self minify upx
RUN ./upx.out --best -o /usr/bin/upx /upx/src/upx.out && \
    upx -t /usr/bin/upx

# Final image
FROM scratch
COPY --from=builder /usr/bin/upx /usr/bin/upx
ENTRYPOINT ["/usr/bin/upx"]
CMD ["--help"]
