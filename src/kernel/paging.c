#include <kernel/paging.h>
#include <stdint.h>
void *phys_to_virt(void* addr) {
    uint8_t* adr = addr+directmap_start;
    return (void*)adr;
}

void map_page(uint64_t* pdaddr, uint64_t physpage, uint64_t virtpage, uint64_t pages, uint64_t tflags, uint64_t dflags) {
    uint64_t alocated = 0;
    
}