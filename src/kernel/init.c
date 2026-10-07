#include <kernel/bootinfo.h>
#include <kernel/heap.h>
#include <kernel/paging.h>
#include <lib/string.h>
#include <kernel/cpuid.h>
#include <stdint.h>

#define no_cache           (1 << 4)
#define huge_page          (1 << 7)
#define pwt_enable         (1 << 3)
#define user_page          (1 << 2)
#define page_writable      (1 << 1)
#define page_present          1
#define global_page        (1 << 8)

#define kernel_pagedir     (2 << 8)
#define sysmisc_pagedir    (3 << 8)
#define prog_pagedir       (4 << 8)
#define progalloc_pagedir  (5 << 8)
#define progstack_pagedir  (6 << 8)
#define multiple_pagedir   (7 << 8)
#define full_pagedir       (1 << 6)
#define osattr_maskdir     (15 << 8)

#define kernel_pagetble    (2 << 9)
#define sysmisc_pagetble   (3 << 9)
#define prog_pagetble      (4 << 9)
#define progalloc_pagetble (5 << 9)
#define progstack_pagetble (6 << 9)
#define osattr_masktble    (7 << 9)


#define physvirtdiff (0xFFFFFFFF80000000ULL - 0x200000ULL)
#define kerneldirectdiff (physvirtdiff - 0xFFFF800000000000ULL)
extern char bss_start;
extern char bss_end;
extern char ldheap_start[];

uint64_t pml4pg[512] __attribute__((aligned(4096)));

uint64_t directpml3pg[1024] __attribute__((aligned(4096)));
uint64_t directpml2pg[32768] __attribute__((aligned(4096)));

uint64_t heappml3pg[512] __attribute__((aligned(4096)));
uint64_t heappml2pg[512] __attribute((aligned(4096)));

uint64_t kpml3pg[512] __attribute__((aligned(4096)));
uint64_t kpml2pg[1024] __attribute__((aligned(4096)));


uint64_t traminbytes;
uint64_t uraminbytes;
uint64_t traminpages;
uint8_t* heap_start;
uint64_t heap_size;
uint64_t heap_sizepg;
uint64_t heap_sizebits;
uint64_t kernel_size;
uint64_t kernel_sizepg;
extern char stack_topld[];
uint64_t stack_top;
uint64_t physheapstart;

struct bootl_info binfo;

void configurebinfo(struct boot32_info* bbinfo) {
    binfo.vbe_info = (void*)(uint64_t)bbinfo->vbe_info;
    binfo.partaddr = (void*)(uint64_t)bbinfo->partaddr;
    binfo.drive = bbinfo->drive;
    binfo.smaps = (void*)(uint64_t)bbinfo->smaps;
    binfo.total_smaps = bbinfo->total_smaps;
    binfo.rdsp_table = (void*)(uint64_t)bbinfo->rdsp_table;
}
void clear_bss() {
    uint8_t *p = (uint8_t*)&bss_start;
    for (uintptr_t i = 0; i < (uintptr_t)&bss_end - (uintptr_t)&bss_start; i++) {
        p[i] = 0;
    }
}
void calculateram() {
    for (int i = 0; i < binfo.total_smaps;i++) {
        traminbytes += binfo.smaps[i].length;
        if (binfo.smaps[i].type == 1) {
            uraminbytes += binfo.smaps[i].length;
        }
    }
}
void init_heap_pt1() {
    heap_start = (uint8_t*)ldheap_start;
    traminpages = traminbytes >> 12;
    heap_size = (traminpages+7) >> 3;
    heap_sizepg = (heap_size + 4095) >> 12;
    kernel_size = (uintptr_t)heap_start - 0xFFFFFFFF80000000 + 4095;
    kernel_sizepg = (kernel_size + 4095) >> 12;
    physheapstart = (uintptr_t)heap_start - physvirtdiff;
}
void initmap_page(void* addr, uint64_t flags, uintptr_t pages, uintptr_t firstphys) {
    uintptr_t* pointer = addr;
    for (uintptr_t i = 0; i < pages;i++) {
        pointer[i] = ((firstphys+i) << 12) | flags;
    }
}
void hugeinitmap_page(void* addr, uint64_t flags, uintptr_t pages, uintptr_t firstphys, uintptr_t hugepagesizeinpg) {
    uintptr_t* pointer = addr;
    for (uintptr_t i = 0; i < pages;i++) {
        pointer[i] = ((firstphys+(i*hugepagesizeinpg)) << 12) | flags;
    }
}
void config_paging() {
    initmap_page(pml4pg+0x1ff, page_present | page_writable | kernel_pagedir,  1, ((uintptr_t)&kpml3pg - physvirtdiff) >> 12);
    initmap_page(pml4pg+0x100, page_present | page_writable | sysmisc_pagedir, 2, ((uintptr_t)&directpml3pg - physvirtdiff) >> 12);
    //initmap_page(pml4pg+0x120, page_present | page_writable | sysmisc_pagedir, 1, ((uintptr_t)&heappml3pg - physvirtdiff) >> 12);

    initmap_page(kpml3pg+0x1fe,page_present | page_writable | kernel_pagedir,  2, ((uintptr_t)&kpml2pg - physvirtdiff) >> 12);
    hugeinitmap_page(kpml2pg,  page_present | page_writable | kernel_pagetble | huge_page | global_page, 1024, 0x200, 0x200);
    struct cpuid_result a = cpuid(0x80000001, 0);
    if (a.edx & CPUID_EDX_1GBPAGE) {
        hugeinitmap_page(directpml3pg, page_present | page_writable | sysmisc_pagetble | huge_page | global_page, 1024, 0x0, 0x40000);
        //hugeinitmap_page(heappml3pg,   page_present | page_writable | sysmisc_pagetble | huge_page | global_page, 512,  physheapstart >> 12, 0x40000);
    } else {
        initmap_page(directpml3pg,     page_present | page_writable | sysmisc_pagedir, 64, ((uintptr_t)&directpml2pg - physvirtdiff) >> 12);
        hugeinitmap_page(directpml2pg, page_present | page_writable | sysmisc_pagetble | huge_page | global_page, 32768, 0x0, 0x200);

        //initmap_page(heappml3pg,       page_present | page_writable | sysmisc_pagedir, 1, ((uintptr_t)&heappml2pg - physvirtdiff) >> 12);
        //hugeinitmap_page(heappml2pg,   page_present | page_writable | sysmisc_pagetble | huge_page | global_page, 512, physheapstart >> 12, 0x200);
    }
    heap_start -= kerneldirectdiff;
    uint64_t pml4physaddr = (uintptr_t)&pml4pg - physvirtdiff;
    asm volatile ("mov %0, %%cr3" :: "r"(pml4physaddr) : "cc", "memory");
}
void after_longmode(struct boot32_info* bbinfo) {
    configurebinfo(bbinfo);
    calculateram();
    init_heap_pt1();
    config_paging();
    clear_bss();
    stack_top = (uintptr_t)stack_topld;
}
volatile char* tvideo = (volatile char*) 0xFFFF8000000B8000;

int cursor = 0;
int cursorc = 0;

void printchar(char c, uint8_t color) {
    if (cursor >= 4000) {
        cursor = 0;
    }
    tvideo[cursor++] = c;
    tvideo[cursor++] = color;
    cursorc++;
}
void print(const char* str, uint8_t color) {
    while (*str) {
        
        printchar(*str++, color);
    }
}
// now that kernel is totally mapped, you can init another things :)
#include <kernel/gdt.h>
#include <kernel/gs.h>
#include <kernel/idt.h>
#include <kernel/apic.h>
#include <drivers/ata.h>
void after_paging() {
    config_gdt();
    uint8_t* ptr1 = phys_to_virt(binfo.partaddr);
    set_partstart(ptr1);

    ptr1 = phys_to_virt(binfo.smaps);
    init_heap((struct smap*)ptr1, binfo.total_smaps);

    init_gs();
    remap_oldpic(0x20, 0x28);
    config_idt();
    print("Hello in long mode! :D", 0x07);
}