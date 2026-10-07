#ifndef IDT_H
#define IDT_H
#include <stdint.h>
#include <stdbool.h>

extern void set_idt(uint64_t itr);
struct idt_entry {
    uint16_t low_offset;
    uint16_t selector;
    uint8_t istoffset;
    uint8_t attributes;
    uint16_t middle_offset;
    uint32_t high_offset;
    uint32_t reserved;
} __attribute__((packed));
struct idt_ptr {
    uint16_t limit;
    uint64_t base;
} __attribute__((packed));



// exceptions
extern void int0();
extern void int1();
extern void int2();
extern void int3();
extern void int4();
extern void int5();
extern void int6();
extern void int7();
extern void int8();
extern void int10();
extern void int11();
extern void int12();
extern void int13();
extern void int14();
extern void int16();
extern void int17();
extern void int18();
extern void int19();
extern void int20();
extern void int21();

// irqs
extern void irq0();
extern void irq1();
extern void irq5();
extern void irq12();

// label
extern void irqmaslabel();
extern void irqslavelabel();
extern void intlabel();
extern void errlabel();

// syscall
extern void syscallint();

struct int_stack {
    uintptr_t r15;
    uintptr_t r14;
    uintptr_t r13;
    uintptr_t r12;
    uintptr_t r11;
    uintptr_t r10;
    uintptr_t r9;
    uintptr_t r8;

    void* rdi;
    void* rsi;

    uintptr_t rdx;
    uintptr_t rcx;
    uintptr_t rbx;
    uintptr_t rax;

    uintptr_t num;
    uintptr_t err;

    void* rip;
    uint16_t cs;

    uintptr_t rflags;
    void* rsp;
    uint16_t ss;
} __attribute__((aligned));

extern struct idt_entry idt[256];
extern struct idt_ptr itr;
void set_interrupt_idt(int i, uintptr_t offset, uint8_t attributes, uint16_t selector) ;
void config_idt();

#endif