@; ///////////////////////////////////////////////////
@; GENERAL
@; ///////////////////////////////////////////////////
.syntax unified
.thumb
.include "Header.inc"



@; ///////////////////////////////////////////////////
@; SECTION: DATA
@; ///////////////////////////////////////////////////
.section .data



@; ///////////////////////////////////////////////////
@; SECTION: TEXT
@; ///////////////////////////////////////////////////
.section .text
@; ---------------------------------------------------
.global DAC_init
.thumb_func
DAC_init:
	
	@; backup register
	PUSH {R7,LR}

	@; enable clock for GPIOA
	CALL BIT_setBitfield, (RCC + RCC_AHB1ENR), 1, 0, 1

	@; set PA4 to analog input mode
	CALL PIN_setMode, A, 4, 3, 0, 1, 0, 0

	@; enable clock for DAC
	CALL BIT_setBitfield, (RCC + RCC_APB1ENR), 1, 29, 1

	@; set CR (configuration register)
	CALL BIT_setBitfield, (DAC + DAC_CR), 1, 12, 1 @; enable CH1 DMA requests
	CALL BIT_setBitfield, (DAC + DAC_CR), 1,  2, 1 @; enabled TIM6 trigger
	CALL BIT_setBitfield, (DAC + DAC_CR), 1,  1, 1 @; enable output buffer
	CALL BIT_setBitfield, (DAC + DAC_CR), 1,  0, 1 @; enable CH1
	
	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
