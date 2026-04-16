#include "main.h"
#include "dma.h"
#include "gpio.h"
#include "memorymap.h"
#include "usart.h"

static void SystemClock_Config(void);

int main(void)
{
    HAL_Init();
    SystemClock_Config();
    MX_DMA_Init();
    MX_GPIO_Init();
    MX_USART1_UART_Init();

    while (1) {
    }
}

static void SystemClock_Config(void)
{
    /* Replace with the clock tree for the specific STM32F4 device. */
}

void Error_Handler(void)
{
    __disable_irq();
    while (1) {
    }
}
