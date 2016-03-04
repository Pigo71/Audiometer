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
.global TIM6_init
.thumb_func
TIM6_init:
	
	@; set stack frame
	PUSH {R7,LR}
	
	@; enable interrupt for TIM6
	@; CALL BIT_setBitfield, (NVIC + NVIC_ISER1), 1, 22, 1
	
	@; enable clock for TIM6
	CALL BIT_setBitfield, (RCC+RCC_APB1ENR), 1, 4, 1

	@; set CR1 (configuration register)
	CALL BIT_setBitfield, (TIM6 + TIM_CR1), 1, 7, 1 @; enable buffering of auto reload register

	@; set CR2 (configuration register)
	CALL BIT_setBitfield, (TIM6 + TIM_CR2), 2, 4, 3 @; update event drives output trigger

	@; set DIER (DMA interrupt enable register)
	CALL BIT_setBitfield, (TIM6 + TIM_DIER), 1, 8, 1 @; enable DMA request
	@; CALL BIT_setBitfield, (TIM6 + TIM_DIER), 1, 0, 1 @; enable update interrupt

	@; set ARR (auto reload register)
	CALL BIT_setBitfield, (TIM6 + TIM_ARR), 2100, 0, 16 @; 84 MHz / 2100 = 40 kHz

	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = on/off (on = 1)
.global TIM6_setOn
.thumb_func
TIM6_setOn:
	
	@; set up stack frame
	PUSH {R7,LR}

	MOV R1, R0
	CALL BIT_setBitfield, (TIM6 + TIM_CR1), R1, 0, 1 @; enable/disable counter
	
	@; restore stack frame
	POP {R7,LR}

BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
.global TIM6_DAC_Handler
.thumb_func
TIM6_DAC_Handler:
	
	@; set up stack frame
	PUSH {R7,LR}

	@; clear pending bit
	CALL BIT_setBitfield, (TIM6 + TIM_SR), 0, 0, 1
	
	@; restore stack frame
	POP {R7,LR}

BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
.global TIM6_triggerInterrupt
.thumb_func
TIM6_triggerInterrupt:
	
	@; set up stack frame
	PUSH {R7,LR}

	@; trigger interrupt
	CALL BIT_setBitfield, (TIM6 + TIM_EGR), 1, 0, 1
	
	@; restore stack frame
	POP {R7,LR}

BX LR
@; ---------------------------------------------------
