# syntax=docker/dockerfile:1.9
# check=error=true

FROM alpine AS builder

ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ] || [ "$TARGETPLATFORM" = "linux/arm64" ]; \
    then apk add --no-cache clang lld; \
    else apk add --no-cache gcc git linux-headers musl-dev; \
    fi

ADD ./x86_64.s /x86_64.s
ADD ./arm64.s /arm64.s
ADD ./linker.ld /linker.ld
ADD ./fallback.c /fallback.c

RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; \
    then clang x86_64.s -static -nostdlib -fuse-ld=lld -Wl,-T,linker.ld -Wl,--oformat=binary -o pause; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; \
    then clang arm64.s -static -nostdlib -fuse-ld=lld -Wl,-T,linker.ld -Wl,--oformat=binary -o pause; \
    else gcc -static -o pause fallback.c && strip pause; \
    fi

FROM scratch
COPY --from=builder /pause /pause
USER 65535:65535
ENTRYPOINT ["/pause"]
