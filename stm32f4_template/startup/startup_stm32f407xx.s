.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global g_pfnVectors
.global Default_Handler
.global Reset_Handler

.extern _estack
.extern main

.section .isr_vector,"a",%progbits
g_pfnVectors:
  .word _estack
  .word Reset_Handler
  .word Default_Handler
  .word Default_Handler
  .word Default_Handler
  .word Default_Handler
  .word Default_Handler
  .word 0
  .word 0
  .word 0
  .word 0
  .word Default_Handler
  .word Default_Handler
  .word 0
  .word Default_Handler
  .word Default_Handler

.section .text.Reset_Handler
Reset_Handler:
  bl main
1:
  b 1b

.section .text.Default_Handler,"ax",%progbits
Default_Handler:
2:
  b 2b
