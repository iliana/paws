# syntax=docker/dockerfile:1.9
# check=error=true

FROM alpine AS builder
RUN apk add --no-cache gcc git linux-headers musl-dev
ADD https://github.com/void-linux/void-runit.git#20231124 /void-runit
RUN gcc -static -o pause void-runit/pause.c
RUN strip pause

FROM scratch
COPY --from=builder /pause /pause
USER 65535:65535
ENTRYPOINT ["/pause"]
