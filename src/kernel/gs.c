#include <kernel/apic.h>
#include <kernel/gs.h>
#include <kernel/msr.h>
#include <stdint.h>
struct cpu_info cpuinfo;
extern uintptr_t stack_top;
void init_gs() {
    cpuinfo.apic_id = get_apicid();
    cpuinfo.kernel_stack = stack_top;
    wrmsr(IA32_GS_BASE, (uint64_t)&stack_top);
    wrmsr(IA32_KERNEL_GS_BASE, (uint64_t)&stack_top);
    
}