#include "kernel/atufs.h"
#include "drivers/ata.h"
#include "lib/string.h"
struct atufs_info atufsinfo;
uint16_t blockinsec = 1;

void init_atufs() {
    read_sector_part(0, (uint16_t*)&atufsinfo, 1);
    blockinsec = atufsinfo.block_size / 512;
}

uint64_t read_filedata(struct file* file1, uint8_t* buffer) {
    uint8_t* start_buffer = buffer;
    if (file1->attributes & 0b10000000) {
        for (uint64_t i = 0; i < 61; i++) {
            struct extent e = file1->extents[i];
            uint64_t totalcsectors = e.manyclusters*blockinsec;
            if (e.manyclusters < 1) {
                break;
            }
            llread_sector_part(atufsinfo.cluster0+(e.startcluster*blockinsec), (uint16_t*)buffer, totalcsectors);
            buffer += totalcsectors * 512;
        }
    } else {
        memcpy(buffer, file1->data, file1->size);
    }
    start_buffer[file1->size] = '\0';
    return file1->size;
}

uintptr_t find_file(const char* name, uint8_t* buffer, uint64_t buffer_size, struct file* f) {
    uint64_t offset = 0;
    while (offset < buffer_size) {
        struct entry* fentry = (struct entry*)(buffer+offset);
        if (fentry->entry_size == 0) break;
        if (cmpstr_limit((char*)fentry->name, name, fentry->namesize)) {
            read_sector_part(atufsinfo.file0+(fentry->file), (uint16_t*)f, 1);
            return fentry->file;
        }
        offset += fentry->entry_size;
    };
    return 0;
}