file_load_va:
    .byte  0x7f, 'E', 'L', 'F'

    .byte  2  /* EI_CLASS = ELFCLASS64 */
    .byte  1  /* EI_DATA = ELFDATA2LSB (little-endian) */
    .byte  1  /* EI_VERSION = EV_CURRENT */
    .byte  0  /* EI_OSABI = ELFOSABI_NONE */
    .8byte 0  /* EI_ABIVERSION = 0 (unspecified) */

    .2byte 2   /* e_type = ET_EXEC */
    .2byte 183 /* e_machine = EM_AARCH64 */
    .4byte 1   /* e_version = EV_CURRENT */

    .8byte entry_point                          /* e_entry */
    .8byte program_headers_start - file_load_va /* e_phoff */
    .8byte 0                                    /* e_shoff */

    .4byte 0  /* e_flags = 0 */
    .2byte 64 /* e_ehsize = 64 */
    .2byte 56 /* e_phentsize = 56 */
    .2byte 1  /* e_pnum = 1 */
    .2byte 64 /* e_shentsize = 64 */
    .2byte 0  /* e_shnum = 0 */
    .2byte 0  /* e_shstrndx = 0 */

program_headers_start:
    .4byte 1                       /* p_type = PT_LOAD */
    .4byte 5                       /* p_flags = PF_R+PF_X */
    .8byte 0                       /* p_offset = 0 */
    .8byte file_load_va            /* p_vaddr = file_load_va */

    /* value of p_paddr for ET_EXEC is "unspecified", so stuff a constant here */
sigset:
    .8byte 16387

    .8byte file_end - file_load_va /* p_filesz = file_end */
    .8byte file_end - file_load_va /* p_memsz = file_end */
    .8byte 0x200000                /* p_align = 0x200000 */

entry_point:
    adrp x9, sigset

    /* rt_sigprocmask(SIG_BLOCK, &sigset, 0) */
    mov x8, #0x87
    add x1, x9, #:lo12:sigset
    mov x3, #8
    svc #0

    /* rt_sigtimedwait(&sigset, 0, 0) */
    mov x8, #0x89
    mov x1, xzr
wait:
    add x0, x9, #:lo12:sigset
    svc #0
    cmp x0, #1
    b.le wait

    /* exit(0) */
    mov x8, #0x5d
    mov x0, xzr
    svc #0

file_end:
