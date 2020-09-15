ARG ARCHITECTURE
FROM multiarch/alpine:${ARCHITECTURE}-v3.12 as builder

LABEL maintainer="Wilmar den Ouden" \
    description="UPX UPX'ed in a convenient container"

ARG VERSION=v3.96

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
# Compile static, CHECK_WHITESPACE is needed, throws bash not found otherwise
RUN CORES=$(grep -c '^processor' /proc/cpuinfo); \
    export MAKEFLAGS="-j$((CORES+1)) -l${CORES}"; \
    export LDFLAGS=-static; \
    make upx.out CHECK_WHITESPACE=

# Self minify upx
RUN ./upx.out --best -o /usr/bin/upx /upx/src/upx.out && \
    upx -t /usr/bin/upx

# Final image
FROM scratch
COPY --from=builder /usr/bin/upx /usr/bin/upx
ENTRYPOINT ["/usr/bin/upx"]
CMD ["--help"]
