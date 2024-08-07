    .code64

file_load_va:
    .byte  0x7f, 'E', 'L', 'F'

    .byte  2  # EI_CLASS = ELFCLASS64
    .byte  1  # EI_DATA = ELFDATA2LSB (little-endian)
    .byte  1  # EI_VERSION = EV_CURRENT
    .byte  0  # EI_OSABI = ELFOSABI_NONE
    .8byte 0  # EI_ABIVERSION = 0 (unspecified)

    .2byte 2  # e_type = ET_EXEC
    .2byte 62 # e_machine = EM_X86_64
    .4byte 1  # e_version = EV_CURRENT

    .8byte entry_point                          # e_entry
    .8byte program_headers_start - file_load_va # e_phoff
    .8byte 0                                    # e_shoff

    .4byte 0  # e_flags = 0
    .2byte 64 # e_ehsize = 64
    .2byte 56 # e_phentsize = 56
    .2byte 1  # e_pnum = 1
    .2byte 64 # e_shentsize = 64
    .2byte 0  # e_shnum = 0
    .2byte 0  # e_shstrndx = 0

program_headers_start:
    .4byte 1                       # p_type = PT_LOAD
    .4byte 5                       # p_flags = PF_R+PF_X
    .8byte 0                       # p_offset = 0
    .8byte file_load_va            # p_vaddr = file_load_va

    # value of p_paddr for ET_EXEC is "unspecified", so stuff code here
noop:
    ret

restorer:
    # rt_sigreturn()
    mov $0x0f, %al
    syscall

    .org noop + 8

    .8byte file_end - file_load_va # p_filesz = file_end
    .8byte file_end - file_load_va # p_memsz = file_end
    .8byte 0x200000                # p_align = 0x200000

entry_point:
    # rt_sigaction(SIGHUP, ignore_sigaction, 0, 8)
    mov $0x0d, %al
    inc %edi
    mov $ignore_sigaction, %esi
    mov $8, %r10b
    syscall

    # rt_sigaction(SIGINT, noop_sigaction, 0, 8)
    mov $0x0d, %al
    inc %edi
    sub $(ignore_sigaction - noop_sigaction), %esi
    syscall

    # rt_sigaction(SIGTERM, noop_sigaction, 0, 8)
    mov $0x0d, %al
    mov $15, %dil
    syscall

    # pause()
    mov $0x22, %al
    syscall

    # exit(0)
    xchg %ebx, %eax
    mov $0x3c, %al
    xor %edi, %edi
    syscall

noop_sigaction:
    .8byte noop       # sa_handler = noop
    .8byte 0x04000000 # sa_flags = SA_RESTORER
    .8byte restorer   # sa_restorer = restorer
    .8byte 0          # sa_mask = 0

ignore_sigaction:
    .byte  1          # sa_handler = SIG_IGN

file_end:
