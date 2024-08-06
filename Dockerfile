# syntax=docker/dockerfile:1.9
# check=error=true

FROM alpine AS builder
RUN apk add --no-cache nasm
ADD ./pause.asm /pause.asm
RUN nasm -f bin -o pause pause.asm
RUN chmod a+x pause

FROM scratch
COPY --from=builder /pause /pause
USER 65535:65535
ENTRYPOINT ["/pause"]
