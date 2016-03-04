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
.global TIM7_init
.thumb_func
TIM7_init:
	
	@; set stack frame
	PUSH {R7,LR}
	
	@; enable interrupt for TIM7
	CALL BIT_setBit, (NVIC + NVIC_ISER1), 1, 23
	
	@; enable clock for TIM7
	CALL BIT_setBit, (RCC + RCC_APB1ENR), 1, 5

	@; set CR1 (configuration register)
	CALL BIT_setBitfield, (TIM7 + TIM_CR1), 0, 7, 1 @; ARR is unbuffered

	@; set CR2 (configuration register)
	CALL BIT_setBitfield, (TIM7 + TIM_CR2), 2, 4, 3 @; update event drives output trigger

	@; set DIER (DMA interrupt enable register)
	CALL BIT_setBitfield, (TIM7 + TIM_DIER), 1, 0, 1 @; enable update interrupt

	@; set ARR (auto reload register)
	CALL BIT_setBitfield, (TIM7 + TIM_ARR), 16800, 0, 16 @; 84 MHz / 16800 = 5 kHz

	@; enable counter
	CALL BIT_setBitfield, (TIM7 + TIM_CR1), 1, 0, 1
	
	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
.global TIM7_Handler
.thumb_func
TIM7_Handler:

	@; set up stack frame
	PUSH {R7,LR}
	
	@; Drive P24 IO operations with TIM7
	CALL P24_update
	
	@; clear pending bit
	CALL BIT_setBitfield, (TIM7 + TIM_SR), 0, 0, 1

	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
