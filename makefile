# ============================================================
# CONFIGURATION
# ============================================================

BUILD_DIR = build
TOOLS_DIR = tools

SYSROOT = sysroot
SYSROOT_INC = $(SYSROOT)/usr/include
SYSROOT_LIB = $(SYSROOT)/usr/lib

KSYSROOT = ksysroot
KSYSROOT_INC = $(KSYSROOT)/usr/include


# ============================================================
# COMPILE TOOLS
# ============================================================

ASM = nasm

CC = x86_64-elf-gcc
CC32 = i686-elf-gcc

LD = x86_64-elf-ld
LD32 = i686-elf-ld

AR = x86_64-elf-ar

# Pode converter ELF32 -> binary.
# Se você tiver i686-elf-objcopy, pode trocar para ele.
OBJCOPY = x86_64-elf-objcopy

GDB = x86_64-elf-gdb

TOOLS_CC = gcc

QM = qemu-system-x86_64


# ============================================================
# FLAGS
# ============================================================

ASM_FLAGS = -f elf64
ASM32_FLAGS = -f elf32

LD_FLAGS = \
	-m elf_x86_64 \
	--gc-sections

LD32_FLAGS = \
	-m elf_i386 \
	--gc-sections

QM_FLAGS = \
	-m 512M \
	-audiodev pa,id=snd0 \
	-drive file=hd.img,format=raw,index=0,media=disk

APP_LD_FLAGS = \
	--sysroot=$(SYSROOT) \
	-nostdlib \
	-Wl,--gc-sections


# ============================================================
# SOURCE FILES
# ============================================================

C_KERNEL_SRC = $(wildcard src/kernel/*.c)
ASM_KERNEL_SRC = $(wildcard src/kernel/*.asm)

C_BOOT2_SRC = $(wildcard src/boot2/*.c)
ASM_BOOT2_SRC = $(wildcard src/boot2/*.asm)

ASM_BOOT1_SRC = $(wildcard src/boot1/*.asm)

C_DRIVER_SRC = $(wildcard src/drivers/*.c)
C_LIB_SRC = $(wildcard src/lib/*.c)

C_APPS_SRC = $(wildcard src/apps/*.c)

C_ABI_ATU_SRC = $(wildcard src/abi/atu/*.c)
ASM_ABI_ATU_SRC = $(wildcard src/abi/atu/*.asm)

C_ABIO_SRC = $(wildcard src/abio/*.c)
ASM_ABIO_SRC = $(wildcard src/abio/*.asm)

C_STDC_SRC = $(wildcard src/abi/stdc/*.c)
ASM_STDC_SRC = $(wildcard src/abi/stdc/*.asm)

C_TOOLS_SRC = $(wildcard src/tools/*.c)


# ============================================================
# SYSTEM OBJECTS
# ============================================================

SRC_SYS_C = \
	$(C_DRIVER_SRC) \
	$(C_LIB_SRC)

OBJ_SYS_C = $(patsubst \
	src/%.c,$(BUILD_DIR)/c/%.o,$(SRC_SYS_C))

OBJ_KERNEL_C = $(patsubst \
	src/%.c,$(BUILD_DIR)/c/%.o,$(C_KERNEL_SRC))

OBJ_KERNEL_ASM = $(patsubst \
	src/%.asm,$(BUILD_DIR)/asm/%.o,$(ASM_KERNEL_SRC))


# ============================================================
# BOOT2 OBJECTS — 32 BIT
# ============================================================

OBJ_BOOT2_C = $(patsubst \
	src/boot2/%.c,$(BUILD_DIR)/c/boot2/%.o,$(C_BOOT2_SRC))

OBJ_BOOT2_ASM = $(patsubst \
	src/boot2/%.asm,$(BUILD_DIR)/asm/boot2/%.o,$(ASM_BOOT2_SRC))


# ============================================================
# BOOT1
# ============================================================

OBJ_BOOT1_ASM = $(patsubst \
	src/boot1/%.asm,$(BUILD_DIR)/%.bin,$(ASM_BOOT1_SRC))


# ============================================================
# ABI: ATU
# ============================================================

OBJ_ABI_ATU = \
	$(patsubst \
		src/abi/atu/%.c,$(BUILD_DIR)/abi/atu/%.o,$(C_ABI_ATU_SRC)) \
	$(patsubst \
		src/abi/atu/%.asm,$(BUILD_DIR)/abi/atu/%.o,$(ASM_ABI_ATU_SRC))

ABI_ATU_LIB = $(SYSROOT_LIB)/libatu.a


# ============================================================
# ABI: ABIO
# ============================================================

OBJ_ABIO_C = $(patsubst \
	src/abio/%.c,$(BUILD_DIR)/abio/%.o,$(C_ABIO_SRC))

OBJ_ABIO_ASM = $(patsubst \
	src/abio/%.asm,$(BUILD_DIR)/abio/%.o,$(ASM_ABIO_SRC))

OBJ_ABIO = \
	$(OBJ_ABIO_C) \
	$(OBJ_ABIO_ASM)


# ============================================================
# ABI: STDC
# ============================================================

OBJ_STDC = \
	$(patsubst \
		src/abi/stdc/%.c,$(BUILD_DIR)/abi/stdc/%.o,$(C_STDC_SRC)) \
	$(patsubst \
		src/abi/stdc/%.asm,$(BUILD_DIR)/abi/stdc/%.o,$(ASM_STDC_SRC))

STDC_LIB = $(SYSROOT_LIB)/libstdc.a


# ============================================================
# APPS
# ============================================================

OBJ_APPS_C = $(patsubst \
	src/apps/%.c,$(BUILD_DIR)/c/apps/%.o,$(C_APPS_SRC))

ELF_APPS_C = $(patsubst \
	$(BUILD_DIR)/c/apps/%.o,rootfs/%,$(OBJ_APPS_C))


# ============================================================
# TOOLS
# ============================================================

OBJ_TOOLS_C = $(patsubst \
	src/tools/%.c,$(TOOLS_DIR)/%,$(C_TOOLS_SRC))


# ============================================================
# CFLAGS — SYSTEM / KERNEL
# ============================================================

SYSTEM_CFLAGS = \
	-std=gnu99 \
	-ffreestanding \
	-ffunction-sections \
	-fdata-sections \
	-O0 \
	-Wall \
	-Wextra \
	-mno-sse \
	-mno-sse2 \
	-mno-mmx \
	--sysroot=$(KSYSROOT) \
	-I$(KSYSROOT_INC) \
	-fno-stack-protector \
	-fno-pic \
	-fno-pie \
	-fno-builtin \
	-g


# ============================================================
# CFLAGS — BOOT2 / i386
# ============================================================

BOOT2_CFLAGS = \
	-std=gnu99 \
	-ffreestanding \
	-ffunction-sections \
	-fdata-sections \
	-O0 \
	-Wall \
	-Wextra \
	-m32 \
	-mno-sse \
	-mno-sse2 \
	-mno-mmx \
	--sysroot=$(KSYSROOT) \
	-I$(KSYSROOT_INC) \
	-fno-stack-protector \
	-fno-pic \
	-fno-pie \
	-fno-builtin \
	-g


# ============================================================
# CFLAGS — APPLICATIONS
# ============================================================

APP_CFLAGS = \
	-std=gnu99 \
	-ffreestanding \
	-ffunction-sections \
	-fdata-sections \
	-O0 \
	-Wall \
	-Wextra \
	-mno-sse \
	-mno-sse2 \
	-mno-mmx \
	--sysroot=$(SYSROOT) \
	-I$(SYSROOT_INC) \
	-fno-stack-protector \
	-fno-pic \
	-fno-pie \
	-fno-builtin \
	-g


# ============================================================
# DEFAULT TARGET
# ============================================================

all: hd.img


# ============================================================
# C COMPILATION — 64 BIT
# ============================================================

$(BUILD_DIR)/c/%.o: src/%.c
	@mkdir -p $(dir $@)
	$(CC) $(SYSTEM_CFLAGS) -c $< -o $@


# ============================================================
# BOOT2 C COMPILATION — 32 BIT
# ============================================================

$(BUILD_DIR)/c/boot2/%.o: src/boot2/%.c
	@mkdir -p $(dir $@)
	$(CC32) $(BOOT2_CFLAGS) -c $< -o $@


# ============================================================
# APPLICATION C COMPILATION — 64 BIT
# ============================================================

$(BUILD_DIR)/c/apps/%.o: src/apps/%.c
	@mkdir -p $(dir $@)
	$(CC) $(APP_CFLAGS) -c $< -o $@


# ============================================================
# ABI: ATU C
# ============================================================

$(BUILD_DIR)/abi/atu/%.o: src/abi/atu/%.c
	@mkdir -p $(dir $@)
	$(CC) $(APP_CFLAGS) -c $< -o $@


# ============================================================
# ABI: ABIO C
# ============================================================

$(BUILD_DIR)/abio/%.o: src/abio/%.c
	@mkdir -p $(dir $@)
	$(CC) $(APP_CFLAGS) -c $< -o $@


# ============================================================
# ABI: STDC C
# ============================================================

$(BUILD_DIR)/abi/stdc/%.o: src/abi/stdc/%.c
	@mkdir -p $(dir $@)
	$(CC) $(APP_CFLAGS) -c $< -o $@


# ============================================================
# ASM COMPILATION — 64 BIT
# ============================================================

$(BUILD_DIR)/asm/%.o: src/%.asm
	@mkdir -p $(dir $@)
	$(ASM) $(ASM_FLAGS) $< -o $@


# ============================================================
# BOOT2 ASM COMPILATION — 32 BIT
# ============================================================

$(BUILD_DIR)/asm/boot2/%.o: src/boot2/%.asm
	@mkdir -p $(dir $@)
	$(ASM) $(ASM32_FLAGS) $< -o $@


# ============================================================
# ABI: ATU ASM
# ============================================================

$(BUILD_DIR)/abi/atu/%.o: src/abi/atu/%.asm
	@mkdir -p $(dir $@)
	$(ASM) $(ASM_FLAGS) $< -o $@


# ============================================================
# ABI: ABIO ASM
# ============================================================

$(BUILD_DIR)/abio/%.o: src/abio/%.asm
	@mkdir -p $(dir $@)
	$(ASM) $(ASM_FLAGS) $< -o $@


# ============================================================
# ABI: STDC ASM
# ============================================================

$(BUILD_DIR)/abi/stdc/%.o: src/abi/stdc/%.asm
	@mkdir -p $(dir $@)
	$(ASM) $(ASM_FLAGS) $< -o $@


# ============================================================
# ABI LIBRARIES
# ============================================================

$(ABI_ATU_LIB): $(OBJ_ABI_ATU)
	@mkdir -p $(dir $@)
	$(AR) rcs $@ $^


$(STDC_LIB): $(OBJ_STDC)
	@mkdir -p $(dir $@)
	$(AR) rcs $@ $^


# ============================================================
# KERNEL — x86_64
# ============================================================

kernel.bin: \
	$(OBJ_SYS_C) \
	$(OBJ_KERNEL_C) \
	$(OBJ_KERNEL_ASM) \
	linker/kernel.ld

	$(LD) $(LD_FLAGS) \
		-T linker/kernel.ld \
		$(OBJ_SYS_C) \
		$(OBJ_KERNEL_C) \
		$(OBJ_KERNEL_ASM) \
		-o $@


# ============================================================
# BOOT2 — i386 / 32 BIT
#
# IMPORTANTE:
# OBJ_SYS_C NÃO está aqui.
#
# Portanto:
#   drivers/ não entra
#   lib/ não entra
#
# Somente os fontes existentes em src/boot2/
# são compilados e linkados.
# ============================================================

$(BUILD_DIR)/boot2.elf: \
	$(OBJ_BOOT2_C) \
	$(OBJ_BOOT2_ASM) \
	linker/boot2.ld

	$(LD32) $(LD32_FLAGS) \
		-T linker/boot2.ld \
		$(OBJ_BOOT2_C) \
		$(OBJ_BOOT2_ASM) \
		-o $@


$(BUILD_DIR)/boot2.bin: $(BUILD_DIR)/boot2.elf

	$(OBJCOPY) \
		-O binary \
		$< \
		$@


# ============================================================
# BOOT1
# ============================================================

$(BUILD_DIR)/%.bin: src/boot1/%.asm
	@mkdir -p $(dir $@)
	$(ASM) -f bin $< -o $@


# ============================================================
# APPLICATIONS
# ============================================================

rootfs/%: \
	$(BUILD_DIR)/c/apps/%.o \
	$(ABI_ATU_LIB) \
	$(STDC_LIB) \
	$(OBJ_ABIO)

	@mkdir -p $(dir $@)

	$(CC) \
		$(APP_LD_FLAGS) \
		-T linker/prog.ld \
		$(OBJ_ABIO) \
		$< \
		-L$(SYSROOT_LIB) \
		-latu \
		-lstdc \
		-o $@


# ============================================================
# HOST TOOLS
# ============================================================

$(TOOLS_DIR)/%: src/tools/%.c
	@mkdir -p $(dir $@)
	$(TOOLS_CC) -g $< -o $@


# ============================================================
# DISK IMAGE
# ============================================================

hd.img: \
	kernel.bin \
	$(BUILD_DIR)/boot2.bin \
	$(OBJ_BOOT1_ASM) \
	$(OBJ_TOOLS_C) \
	$(ELF_APPS_C)

	dd if=/dev/zero of=hd.img bs=1M count=128

	$(TOOLS_DIR)/mkmbr \
		hd.img boot \
		$(BUILD_DIR)/bootmbr.bin

	$(TOOLS_DIR)/mkmbr \
		hd.img part 1 0

	$(TOOLS_DIR)/mkmbr \
		hd.img active 1

	$(TOOLS_DIR)/mkatufs \
		hd.img part 1 \
		$(BUILD_DIR)/boot2.bin \
		$(BUILD_DIR)/bootvbr.bin

	$(TOOLS_DIR)/cpatufs hd.img 1M kernel.bin /kernel.elf
	$(foreach file,$(wildcard rootfs/*), \
		$(TOOLS_DIR)/cpatufs \
		hd.img 1M \
		$(file) \
		/$(notdir $(file));)


# ============================================================
# RUN
# ============================================================

run: all
	$(QM) $(QM_FLAGS)


# ============================================================
# HEX EDITOR
# ============================================================

hex: all
	flatpak run net.werwolv.ImHex hd.img


# ============================================================
# QEMU DEBUG
# ============================================================

triple: all
	$(QM) \
		$(QM_FLAGS) \
		-d int \
		-no-reboot \
		-no-shutdown


gdb: all
	$(QM) \
		$(QM_FLAGS) \
		-s \
		-S &

	$(GDB) \
		-ex 'target remote localhost:1234' \
		./kernel.bin


# ============================================================
# CLEAN
# ============================================================

clean:
	rm -rf \
		$(BUILD_DIR) \
		$(TOOLS_DIR) \
		kernel.bin \
		hd.img \
		$(ELF_APPS_C)


# ============================================================
# PHONY
# ============================================================

.PHONY: \
	all \
	run \
	hex \
	triple \
	gdb \
	clean
