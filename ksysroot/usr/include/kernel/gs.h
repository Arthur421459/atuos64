#ifndef GSS_H
#define GSS_H
#include <stdint.h>
struct cpu_info {
    uint32_t thread_id;
    uint32_t pid;
    uint8_t apic_id;
    uint8_t padding1;
    uint16_t padding2;
    uint64_t kernel_stack;
} __attribute__((aligned));

void init_gs();
#endif