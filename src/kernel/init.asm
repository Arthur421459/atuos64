[bits 32]

section .kinit
global _init

CPUID_EXTENSIONS equ 0x80000000 ; returns the maximum extended requests for cpuid
CPUID_EXT_FEATURES equ 0x80000001 ; returns flags containing long mode support among other things
CPUID_EDX_EXT_FEAT_LM equ 1 << 29

EFER_MSR equ 0xC0000080
EFER_LM_ENABLE equ 1 << 8
CR4_PAE equ 1 << 5

_init:
    cld
    mov esp, kinit_stacktop ; no stack, no os
    mov edi, esi ; bootloader things

    mov eax, cr4
    or eax, CR4_PAE
    mov cr4, eax

    call has_longmode
    call configurepg
    call finish_cmpmode

    ; almost done!
    jmp finish_longmode

error:
    cli
    hlt

finish_cmpmode:
    mov ecx, EFER_MSR
    rdmsr
    or eax, EFER_LM_ENABLE
    wrmsr

    mov eax, cr0
    or eax, 0x80000001 ; protected mode and paging
    mov cr0, eax
ret
finish_longmode:
    lgdt [sgdt_desc]
    jmp 0x08:longmode_entry

has_longmode:
    mov eax, CPUID_EXTENSIONS
    cpuid
    cmp eax, CPUID_EXT_FEATURES
    jb error

    mov eax, CPUID_EXT_FEATURES
    cpuid
    test edx, CPUID_EDX_EXT_FEAT_LM
    jz error
    ; long mode! :D
ret
changepml:
    shl ebx, 3 ; go to real addr
    add ebx, esi
    or eax, 3 ; write and present
    .lp:
        mov [ebx], eax
        add ebx, 8
        add eax, edx
        loop .lp
        ret

configurepg:
    xor edx, edx

    mov eax, pml3tble
    mov ebx, 0x1ff
    mov esi, pml4tble
    mov ecx, 1
    call changepml

    mov eax, idpml3tble
    mov ebx, 0x0
    mov esi, pml4tble
    mov ecx, 1
    call changepml

    mov eax, pml2tble
    mov ebx, 0x1fe
    mov esi, pml3tble
    mov ecx, 1
    call changepml

    mov eax, idpml2tble
    mov ebx, 0x0
    mov esi, idpml3tble
    mov ecx, 1
    call changepml

    mov eax, 0x200080
    mov ebx, 0
    mov esi, pml2tble
    mov ecx, 512
    mov edx, 0x200000
    call changepml

    mov eax, 1 << 7
    mov ebx, 0
    mov esi, idpml2tble
    mov ecx, 512
    mov edx, 0x200000
    call changepml

    mov eax, pml4tble
    mov cr3, eax ; loaded!
ret
kinit_stackdown:
kinit_stack times 4096 db 0
kinit_stacktop:

align 4096
pml4tble: times 512 dq 0
pml3tble: times 512 dq 0
pml2tble: times 512 dq 0

idpml3tble: times 512 dq 0
idpml2tble: times 512 dq 0
sgdt:
    dq 0 ; null entry
.code_seg:
    dw 0xFFFF ; limit low
    dw 0 ; base low
    db 0 ; base mid
    db 0x9A ; access
    db 0xAF ; granularity + limit high + long mode
    db 0x00 ; base high
.data_seg:
    dw 0xFFFF ; limit low
    dw 0 ; base low
    db 0 ; base mid
    db 0x92 ; access
    db 0xCF ; granularity + limit high + long mode
    db 0x00 ; base high
sgdt_end:

sgdt_desc:
    dw sgdt_end - sgdt - 1
    dd sgdt

[bits 64]

longmode_entry:
    cli
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rax, longmode_done
    jmp rax

section .text
extern after_longmode
extern after_paging
extern stack_top

global set_gdt
global set_idt
global set_tss
%define offsetk (0xFFFFFFFF80000000 - 0x200000)
longmode_done:
    mov rax, offsetk
    add rax, rsp
    mov rsp, rax ; set stack to higher half

    call after_longmode
    mov rsp, [stack_top]

    call after_paging
    .a:
        hlt
        jmp .a

set_gdt:
    lgdt [rdi] ; OMG gdt loaded lol

    push 0x08               
    
    mov rax, .end
    push rax                
    
    retfq  
.end:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    ret

set_tss:
    mov ax, 0x28
    ltr ax
ret
set_idt:
    lidt [rdi] ; OMG idt loaded lol
    sti ; olá interrupções!!!!! (sem bios.........)
    ret