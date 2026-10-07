#ifndef HEAP_H
#define HEAP_H
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include "kernel/bootinfo.h"
#include "lib/tuple.h"
extern uint64_t uraminbytes;
extern uint64_t traminbytes;
extern uint64_t traminpages;


void mark_used(uint64_t first_page, uint64_t total);
void mark_free(uint64_t first_page, uint64_t total);

uintptr_t ppalloc(uint64_t pages);
tuple we_ppalloc(uint64_t pages);

void init_heap(struct smap* smaps, int total_smaps);

void *malloc(size_t bytes, uint16_t tflags, uint16_t dflags);
void *amalloc(size_t bytes, uint16_t tflags, uint16_t dflags);

void *lmalloc(size_t bytes, uint16_t tflags, uint16_t dflags);
void *lamalloc(size_t bytes, uint16_t tflags, uint16_t dflags);

void free(void* ptr);
#endif