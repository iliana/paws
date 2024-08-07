# syntax=docker/dockerfile:1.9
# check=error=true

FROM alpine AS builder
RUN apk add --no-cache clang binutils
ADD ./x86_64.s /x86_64.s
ADD ./linker.ld /linker.ld
RUN clang x86_64.s -nostdlib -Wl,-T,linker.ld -o pause

FROM scratch
COPY --from=builder /pause /pause
USER 65535:65535
ENTRYPOINT ["/pause"]
