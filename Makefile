SHELL := cmd

.DEFAULT_GOAL := all

PROJECT := app
BUILD_DIR := build
LDSCRIPT := linker/stm32h743iitx_flash.ld
MAP := $(BUILD_DIR)/$(PROJECT).map

CC := arm-none-eabi-gcc
AS := arm-none-eabi-gcc
OBJCOPY := arm-none-eabi-objcopy
OBJDUMP := arm-none-eabi-objdump
SIZE := arm-none-eabi-size
OPENOCD := openocd

OPENOCD_INTERFACE := interface/cmsis-dap.cfg
OPENOCD_TARGET := target/stm32h7x.cfg

MCU := cortex-m7
FPU := fpv5-d16
FLOATABI := hard
CPU_FLAGS := -mcpu=$(MCU) -mthumb -mfpu=$(FPU) -mfloat-abi=$(FLOATABI)

CONFIG ?= debug

C_DEFS := -DUSE_HAL_DRIVER -DSTM32H743xx
C_INCLUDES := -Iinc \
              -IDrivers/CMSIS/Include \
              -IDrivers/CMSIS/Device/ST/STM32H7xx/Include \
              -IDrivers/STM32H7xx_HAL_Driver/Inc

CPPFLAGS := $(C_DEFS) $(C_INCLUDES)
WARN_FLAGS := -Wall
COMMON_FLAGS := $(CPU_FLAGS) -ffunction-sections -fdata-sections -fno-common
DEPFLAGS := -MMD -MP
SIZEFLAGS := --format=berkeley

ifeq ($(CONFIG),debug)
OPT_FLAGS := -O0 -g3
else ifeq ($(CONFIG),release)
OPT_FLAGS := -Os
else
$(error Unsupported CONFIG='$(CONFIG)'. Use CONFIG=debug or CONFIG=release)
endif

CFLAGS := $(COMMON_FLAGS) $(OPT_FLAGS) $(WARN_FLAGS) $(DEPFLAGS)
ASFLAGS := $(CPU_FLAGS) $(CPPFLAGS) -x assembler-with-cpp $(DEPFLAGS)

LDFLAGS := $(CPU_FLAGS) \
           -T$(LDSCRIPT) \
           -Wl,--gc-sections \
           -Wl,-Map=$(MAP) \
           -Wl,--print-memory-usage \
           -nostartfiles \
           --specs=nano.specs \
           --specs=nosys.specs

LDLIBS := -lm

SRC_C := src/main.c \
         src/system_stm32h7xx.c \
         src/syscalls.c \
         src/sysmem.c \
         src/gpio.c \
         src/dma.c \
         src/fdcan.c \
         src/usart.c \
         src/stm32h7xx_it.c \
         src/stm32h7xx_hal_msp.c \
         src/memorymap.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_cortex.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rcc.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rcc_ex.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_pwr.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_pwr_ex.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_flash.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_gpio.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_fdcan.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_uart.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_uart_ex.c \
         Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_dma.c

SRC_S := startup/startup_stm32h743xx.s

OBJ_C := $(patsubst %.c,$(BUILD_DIR)/%.o,$(SRC_C))
OBJ_S := $(patsubst %.s,$(BUILD_DIR)/%.o,$(SRC_S))
OBJS := $(OBJ_C) $(OBJ_S)
DEPS := $(OBJS:.o=.d)

ELF := $(BUILD_DIR)/$(PROJECT).elf
HEX := $(BUILD_DIR)/$(PROJECT).hex
BIN := $(BUILD_DIR)/$(PROJECT).bin
LIST := $(BUILD_DIR)/$(PROJECT).list

.PHONY: all clean flash print debug release size rebuild list

all: $(ELF) $(HEX) $(BIN)

debug:
	@$(MAKE) CONFIG=debug

release:
	@$(MAKE) CONFIG=release

rebuild:
	@$(MAKE) clean
	@$(MAKE) all

print:
	@echo SHELL=$(SHELL)
	@echo CONFIG=$(CONFIG)
	@echo CC=$(CC)
	@echo CPPFLAGS=$(CPPFLAGS)
	@echo CFLAGS=$(CFLAGS)
	@echo ASFLAGS=$(ASFLAGS)
	@echo LDFLAGS=$(LDFLAGS)
	@echo LDLIBS=$(LDLIBS)
	@echo LDSCRIPT=$(LDSCRIPT)
	@echo MAP=$(MAP)
	@echo ELF=$(ELF)

$(ELF): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) $(LDLIBS) -o $@
	$(SIZE) $(SIZEFLAGS) $@

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(LIST): $(ELF)
	$(OBJDUMP) -h -S $< > $@

list: $(LIST)

size: $(ELF)
	$(SIZE) $(SIZEFLAGS) $<

$(BUILD_DIR)/%.o: %.c
	@if not exist "$(dir $@)" mkdir "$(dir $@)"
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.s
	@if not exist "$(dir $@)" mkdir "$(dir $@)"
	$(AS) -c $(ASFLAGS) $< -o $@

flash: $(ELF)
	$(OPENOCD) -f $(OPENOCD_INTERFACE) -f $(OPENOCD_TARGET) -c "transport select swd" -c "program $(ELF) verify reset exit"

clean:
	@echo Cleaning $(BUILD_DIR)...
	@if exist "$(BUILD_DIR)" rmdir /S /Q "$(BUILD_DIR)"

-include $(DEPS)