#ifndef GDT_H
#define GDT_H
#include <stdint.h>
#include <stdbool.h>
#define kernelcode_seg 0x08
#define kerneldata_seg 0x10

#define usercode_seg 0x18
#define userdata_seg 0x20

#define tss_seg      0x28
extern void set_gdt(uintptr_t gp_ptr);
extern void set_tss();

struct gdt_entry {
    uint16_t limit_low;
    uint16_t base_low;
    uint8_t  base_middle;
    uint8_t  access;
    uint8_t  granularity;
    uint8_t  base_high;
} __attribute__((packed));

struct gdt_ptr {
    uint16_t limit;
    uint64_t base;
} __attribute__((packed));

struct gdt_tss_entry {
    uint16_t limit_low;
    uint16_t base_low;
    uint8_t  base_middle;
    uint8_t  access;
    uint8_t  granularity;
    uint8_t  base_high;


    uint32_t base_upper;
    uint32_t reserved;
} __attribute__((packed));


struct tss {
    uint32_t reserved;

    uint64_t rsp0;
    uint64_t rsp1;
    uint64_t rsp2;

    uint64_t reserved1;
    uint64_t ist1;
    uint64_t ist2;
    uint64_t ist3;
    uint64_t ist4;
    uint64_t ist5;
    uint64_t ist6;
    uint64_t ist7;

    uint64_t reserved2;
    uint16_t reserved3;

    uint16_t iopb;
} __attribute__((packed));

extern struct gdt_entry gdt[8];
extern struct gdt_ptr gp;
extern struct tss ktss;

void gdt_set_entry(int seg, uint32_t base, uint32_t limit, uint8_t access, uint8_t gran);
void config_gdt();

#endif