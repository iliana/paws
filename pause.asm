; vim:ft=nasm

; derived from https://nathanotterness.com/2021/10/tiny_elf_modernized.html

[bits 64]

file_load_va: equ 4096 * 40

db 0x7f, 'E', 'L', 'F'
db 2  ; EI_CLASS = ELFCLASS64
db 1  ; EI_DATA = ELFDATA2LSB (little-endian)
db 1  ; EI_VERSION = EV_CURRENT
db 0  ; EI_OSABI = ELFOSABI_NONE
dq 0  ; EI_ABIVERSION = 0 (unspecified)

dw 2  ; e_type = ET_EXEC
dw 62 ; e_machine = EM_X86_64
dd 1  ; e_version = EV_CURRENT

dq entry_point + file_load_va ; e_entry
dq program_headers_start      ; e_phoff
dq 0                          ; e_shoff

dd 0  ; e_flags = 0
dw 64 ; e_ehsize = 64
dw 56 ; e_phentsize = 56
dw 1  ; e_pnum = 1
dw 64 ; e_shentsize = 64
dw 0  ; e_shnum = 0
dw 0  ; e_shstrndx = 0

program_headers_start:
dd 1            ; p_type = PT_LOAD
dd 5            ; p_flags = PF_R+PF_X
dq 0            ; p_offset = 0
dq file_load_va ; p_vaddr = file_load_va
dq file_load_va ; p_paddr = file_load_va
dq file_end     ; p_filesz = file_end
dq file_end     ; p_memsz = file_end
dq 0x200000     ; p_align = 0x200000

entry_point:
    ; rt_sigaction(SIGHUP, ignore_sigaction, 0, 8)
    mov al, 0x0d
    inc edi
    mov esi, file_load_va + ignore_sigaction
    mov r10b, 8
    syscall

    ; rt_sigaction(SIGINT, noop_sigaction, 0, 8)
    mov al, 0x0d
    inc edi
    sub esi, ignore_sigaction - noop_sigaction
    syscall

    ; rt_sigaction(SIGTERM, noop_sigaction, 0, 8)
    mov al, 0x0d
    mov dil, 15
    syscall

    ; pause()
    mov al, 0x22
    syscall

    ; exit(0)
    xchg eax, ebx
    mov al, 0x3c
    xor edi, edi
    syscall

noop:
    ret

restorer:
    ; rt_sigreturn()
    mov rax, 0x0f
    syscall

noop_sigaction:
dq file_load_va + noop     ; sa_handler = noop
dq 0x04000000              ; sa_flags = SA_RESTORER
dq file_load_va + restorer ; sa_restorer = restorer
dq 0                       ; sa_mask = 0

ignore_sigaction:
db 1                       ; sa_handler = SIG_IGN

file_end:
