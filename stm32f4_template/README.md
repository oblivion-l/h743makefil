# STM32F4 template

This directory is a STM32F4 project skeleton rewritten to match the structure
and Makefile style used by `firmware/`.

## Directory layout

- `Makefile`: Windows `cmd` style build script, same layout as the H7 template
- `compile_flags.txt`: editor/clangd include and macro hints
- `inc/`: user headers
- `src/`: user sources and startup support files
- `linker/`: linker script placeholder
- `startup/`: startup assembly placeholder

## What is already aligned with the H7 template

- Same top-level file layout
- Same `Makefile` variable grouping and targets
- Same `inc/`, `src/`, `linker/`, `startup/` split
- Same `debug`, `release`, `rebuild`, `flash`, `size`, `list` targets
- Same Windows-oriented directory creation and clean commands

## What you still need to provide

- `Drivers/CMSIS/...` for the exact STM32F4 family you use
- `Drivers/STM32F4xx_HAL_Driver/...` HAL source tree
- The exact startup file for your part number if it is not `startup_stm32f407xx.s`
- The exact linker script for your flash/RAM layout
- Real clock tree code in `src/main.c`
- Real UART pin/peripheral init in `src/stm32f4xx_hal_msp.c`
- Any extra peripheral files you actually use, such as SPI, CAN, I2C, ADC, TIM

## Suggested modification order

1. Replace the chip-specific identifiers in `Makefile` and `compile_flags.txt`
2. Drop in your `Drivers/` directory
3. Replace `startup/startup_stm32f407xx.s`
4. Replace `linker/stm32f407vgtx_flash.ld`
5. Complete `SystemClock_Config()`
6. Complete GPIO/UART/DMA MSP setup
7. Add or remove source files in `SRC_C`

## Common places to modify

- `Makefile`
  - `LDSCRIPT`
  - `C_DEFS`
  - `C_INCLUDES`
  - `SRC_C`
  - `SRC_S`
  - `OPENOCD_TARGET`
- `compile_flags.txt`
  - device include path
  - HAL include path
  - device macro such as `-DSTM32F407xx`
- `src/main.c`
  - `SystemClock_Config()`
- `src/stm32f4xx_hal_msp.c`
  - peripheral clocks
  - GPIO alternate functions
  - DMA binding

## Usage

If you keep this directory name as `stm32f4_template`, enter it first:

```bat
cd stm32f4_template
make
```

Other common commands:

```bat
make clean
make rebuild
make CONFIG=release
make flash
make size
make list
```

## Current limitations

- This is a template, not a complete board-support package
- `Drivers/` is intentionally absent because you said you will supply the libraries
- The startup file and linker script are placeholders for a common F407 layout
- `memorymap.c` is only a reserved stub to keep structure consistent with the H7 template
