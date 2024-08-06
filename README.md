# a simple pause container 🐾

I found myself needing a pause container while working in a Docker Compose stack for... reasons. A pause container runs a process that is solely used to hold onto namespace/container resources and, ideally, does nothing as efficiently as possible; this is usually done by calling the [pause(2) syscall](https://man7.org/linux/man-pages/man2/pause.2.html). For bonus points, it should handle SIGINT and SIGTERM by exiting normally.

(Another way of implementing this is running `sleep infinity` in your favorite container of choice; I initially misremembered this concept as a "sleep container". However, this doesn't handle SIGINT/SIGTERM, so you might find yourself reaching for `sh -c 'trap : TERM INT; sleep infinity & wait'`.)

[Pause containers are a normal, everyday occurrence in Kubernetes](https://www.ianlewis.org/en/almighty-pause-container), but the ones I could find seem to be a whole megabyte for reasons I cannot fathom, and don't make it clear what source code they were built from.

So here's mine. It's called **paws**, and you can pull it from `ghcr.io/iliana/paws`. It is [pause.c from void-runit](https://github.com/void-linux/void-runit/blob/20231124/pause.c) statically compiled with the musl libc. The binary is 13 KiB. It's quite possible the OCI image overhead is larger than the compressed binary.
