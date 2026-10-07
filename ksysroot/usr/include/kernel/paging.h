#ifndef PAGING_H
#define PAGING_H
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include "lib/tuple.h"
#define no_cache           (1 << 4)
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

extern uintptr_t page_directory[1024];
extern uint64_t directmap[131072];

struct malloc_header {
  uint64_t total_pages;
  uint64_t total_bytes;
  uint64_t phys_page;
  uint64_t virt_page;
} __attribute__((packed));

#define physvirtdiff (0xFFFFFFFF80000000ULL - 0x200000ULL)
#define kerneldirectdiff (physvirtdiff - 0xFFFF800000000000ULL)
#define pgmask 0xfffff000
#define directmap_start 0xFFFF800000000000
void *phys_to_virt(void* addr);

uintptr_t get_pag();

void map_page(uint64_t* pdaddr, uint64_t physpage, uint64_t virtpage, uint64_t pages, uint64_t tflags, uint64_t dflags);
void unmap_page(uint64_t* pdaddr, uint64_t first, uint64_t pages);

uintptr_t vpalloc(uint64_t pages);
tuple palloc_virt_and_phys(uintptr_t pages, uint64_t tflags, uint64_t dflags);
void *palloc(uintptr_t pages, uint64_t tflags, uint64_t dflags);

tuple lpalloc_virt_and_phys(uintptr_t pages, uint64_t tflags, uint64_t dflags);
void *lpalloc(uintptr_t pages, uint64_t tflags, uint64_t dflags);

static inline void invlpg(void *addr) {
    asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
}
static inline void invlpgs(void *start_addr, size_t num_pages) {
    char *ptr = (char *)start_addr;
    for (size_t i = 0; i < num_pages; i++) {
        invlpg(ptr);
        ptr += 4096;
    }
}

#endif