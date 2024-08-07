# syntax=docker/dockerfile:1.9
# check=error=true

FROM alpine AS builder

ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; \
    then apk add --no-cache clang binutils; \
    else apk add --no-cache gcc git linux-headers musl-dev; \
    fi

ADD ./x86_64.s /x86_64.s
ADD ./linker.ld /linker.ld
ADD ./fallback.c /fallback.c

RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; \
    then clang x86_64.s -nostdlib -Wl,-T,linker.ld -o pause; \
    else gcc -static -o pause fallback.c && strip pause; \
    fi

FROM scratch
COPY --from=builder /pause /pause
USER 65535:65535
ENTRYPOINT ["/pause"]
