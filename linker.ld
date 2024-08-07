SECTIONS {
    . = 0x28000;
    .text : { *(.text) }
    .shstrtab : { *(.shstrtab) }
    /DISCARD/ : { *(.*) }
}
