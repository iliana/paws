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
dq section_headers_start      ; e_shoff

dd 0  ; e_flags = 0
dw 64 ; e_ehsize = 64
dw 56 ; e_phentsize = 56
dw 1  ; e_pnum = 1
dw 64 ; e_shentsize = 64
dw 3  ; e_shnum = 3
dw 2  ; e_shstrndx = 2

program_headers_start:
dd 1            ; p_type = PT_LOAD
dd 5            ; p_flags = PF_R+PF_X
dq 0            ; p_offset = 0
dq file_load_va ; p_vaddr = file_load_va
dq file_load_va ; p_paddr = file_load_va
dq string_table ; p_filesz = string_table
dq string_table ; p_memsz = string_table
dq 0x200000     ; p_align = 0x200000

section_headers_start:
; index 0 (null section header)
times 0x40 db 0

dd text_section_name - string_table ; sh_name = ".text"
dd 1                                ; sh_type = SHT_PROGBITS
dq 6                                ; sh_flags = SHF_WRITE+SHF_ALLOC+SHF_EXECINSTR
dq file_load_va                     ; sh_addr = file_load_va
dq 0                                ; sh_offset = 0
dq file_end                         ; sh_size = file_end
dd 0                                ; sh_link = 0
dd 0                                ; sh_info = 0
dq 16                               ; sh_addralign = 16
dq 0                                ; sh_entsize = 0

dd string_table_name - string_table ; sh_name = ".shstrtab"
dd 3                                ; sh_type = SHT_STRTAB
dq 0                                ; sh_flags = 0
dq file_load_va + string_table      ; sh_addr = file_load_va + string_table
dq string_table                     ; sh_offset = string_table
dq string_table_end - string_table  ; sh_size = string_table_end - string_table
dd 0                                ; sh_link = 0
dd 0                                ; sh_info = 0
dq 1                                ; sh_addralign = 1
dq 0                                ; sh_entsize = 0

entry_point:
    ; rt_sigaction(SIGINT, noop_sigaction, 0, 8)
    mov rax, 0x0d
    mov rdi, 2
    mov rsi, file_load_va + noop_sigaction
    mov rdx, 0
    mov r10, 8
    syscall

    ; rt_sigaction(SIGTERM, noop_sigaction, 0, 8)
    mov rax, 0x0d
    mov rdi, 15
    syscall

    ; rt_sigaction(SIGHUP, ignore_sigaction, 0, 8)
    mov rax, 0x0d
    mov rdi, 1
    mov rsi, file_load_va + ignore_sigaction
    syscall

    ; pause()
    mov rax, 0x22
    syscall

    ; exit(0)
    mov rax, 0x3c
    mov rdi, 0
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
dq 1                       ; sa_handler = SIG_IGN
dq 0                       ; sa_flags = 0
dq 0                       ; sa_restorer = 0
dq 0                       ; sa_mask = 0

string_table:
db 0
text_section_name:
db ".text\0"
string_table_name:
db ".shstrtab\0"
string_table_end:

file_end:
