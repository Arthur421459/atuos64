[bits 64]

section .text

global int0
global int1
global int2
global int3
global int4
global int5
global int6
global int7
global int8
global int10
global int11
global int12
global int13
global int14
global int16
global int17
global int18
global int19
global int20
global int21

global irqmaslabel
global irqslavelabel
global intlabel

global syscallint

extern int_handler
int0:
    push qword 0
    push qword 0
    jmp int_common

int1:
    push qword 0
    push qword 1
    jmp int_common

int2:
    push qword 0
    push qword 2
    jmp int_common

int3:
    push qword 0
    push qword 3
    jmp int_common

int4:
    push qword 0
    push qword 4
    jmp int_common

int5:
    push qword 0
    push qword 5
    jmp int_common

int6:
    push qword 0
    push qword 6
    jmp int_common

int7:
    push qword 0
    push qword 7
    jmp int_common

int8:
    pop rax
    mov rbx, 0xABCDEF
    cli
    hlt

int10:
    push qword 10
    jmp int_common

int11:
    push qword 11
    jmp int_common

int12:
    push qword 12
    jmp int_common

int13:
    push qword 13
    jmp int_common

int14:
    push qword 14
    jmp int_common

int16:
    push qword 0
    push qword 16
    jmp int_common
int17:
    push qword 17
    jmp int_common

int18:
    push qword 0
    push qword 18
    jmp int_common

int19:
    push qword 0
    push qword 19
    jmp int_common

int20:
    push qword 0
    push qword 20
    jmp int_common

int21:
    push qword 21
    jmp int_common

int_common:
    test byte [rsp + 24], 3
    jz .a
    swapgs
    .a:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov rdi, rsp
    call int_handler

    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    test byte [rsp + 24], 3
    jz .b
    swapgs
    .b:
iretq
irqmaslabel:
    push rax
    xor rax, rax
    mov al, 0x20
    out 0x20, al
    pop rax
iretq
irqslavelabel:
    push rax
    xor rax, rax
    mov al, 0x20
    out 0xA0, al
    out 0x20, al
    pop rax
iretq
intlabel:
iretq