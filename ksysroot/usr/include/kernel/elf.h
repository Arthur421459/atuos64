#ifndef ELF_H
#define ELF_H
#include <stdint.h>
#include <stdbool.h>
#include "lib/tuple.h"
struct elf_header {
    uint8_t magic;
    uint8_t elf_ascii[3];
    uint8_t bits;
    uint8_t endian;
    uint8_t elfh_ver;
    uint8_t os_abi;
    uint64_t reserved1;
    uint16_t type;
    uint16_t arch;
    uint32_t elf_ver;
    uint64_t pentry_ofs;
    uint64_t pheader_ofs;
    uint64_t sheader_ofs;
    uint32_t flags;
    uint16_t header_size;
    uint16_t entrysize_ph;
    uint16_t entrynum_ph;
    uint16_t entrysize_sh;
    uint16_t entrynum_sh;
    uint16_t strtable_scindex;
} __attribute__((packed));

struct ph_entry {
    uint32_t seg_type;
    uint32_t flags_rwx;
    uint64_t p_offset;
    uint64_t p_vaddr;
    uint64_t p_paddr;
    uint64_t p_filesz;
    uint64_t p_memsz;
    uint64_t alligment_pow2;
} __attribute__((packed));

bool is_elf(uint8_t* buffer);
bool is_compatible(uint8_t* buffer);
#endif