#include <kernel/idt.h>
#include <kernel/io.h>
extern volatile char* tvideo;
extern uintptr_t stack_top;

void set_cursor_pos(uint16_t pos) {
    outb(0x3d4, 0x0F); // set reg
    outb(0x3d5, (uint8_t) pos & 0xff); // change reg
    outb(0x3d4, 0x0e);
    outb(0x3d5, (uint8_t) ((pos >> 8) & 0xFF));
}
int set_cursor_pos_xy(int x, int y) {
    int abspos = y * 80 + x;
    set_cursor_pos(abspos);
    return abspos;
}
void printchar_wpos(char c, int color, int pos) {
    if (pos >= 4000) {
        return;
    }
    pos *= 2;
    tvideo[pos++] = c;
    tvideo[pos++] = color;
}
void printchar_wposxy(char c, int color, int x, int y) {
    printchar_wpos(c, color, (80*y)+x);
}

void print_wpos(const char* str, int color, int pos) {
    while (*str) {
        printchar_wpos(*str++, color, pos++);
    }
}
void print_wposxy(const char* str, int color, int x, int y) {
    print_wpos(str, color, (80*y)+x);
}
