OUTPUT_FORMAT(binary)

SECTIONS {
    . = 0x28000;
    .text : {
        *(.*)
    }
}
