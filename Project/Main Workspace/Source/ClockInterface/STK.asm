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
.global STK_init
.thumb_func
STK_init:

	@; set stack frame
	PUSH {R7,LR}

	@; set CTRL (control register)
	CALL BIT_setBitfield, (STK + STK_CTRL), 1, 2, 1 @; clock source is AHB
	CALL BIT_setBitfield, (STK + STK_CTRL), 1, 1, 1 @; enable systick interrupt
	CALL BIT_setBitfield, (STK + STK_CTRL), 1, 0, 1 @; enable counter

	@; set LOAD (reload register)
	CALL BIT_setBitfield, (STK + STK_LOAD), 84000, 0, 24 @; 84 MHz / 84000 = 1 kHz

	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = delay (in milliseconds)
.global STK_delay
.thumb_func
STK_delay:
	
	@; set stack frame
	PUSH {R7,LR}
	
	LDR R1, =CINT_time			@; R1 = &CINT_time
	LDR R2, [R1]				@; R2 = CINT_time
	ADD R0, R2					@; R0 = stop = CINT_time + delay

	LDR R3, =0x0000FFFF			@; R3 = 0x0000FFFF

	SUBS R2, R0, R2				@; R2 = trash
	BGE delay_break_1			@; if (stop < count) {
		delay_repeat_2:				@; while (CINT_time > 0x0000FFFF) {
			LDR R2, [R1]				@; R2 = CINT_time
			SUBS R2, R3					@; R2 = trash
			BGT delay_repeat_2
		delay_break_2:				@; }
	delay_break_1:				@; }

	delay_repeat_3:				@; while (CINT_time < stop)
		LDR R2, [R1]				@; R2 = CINT_time
		SUBS R2, R0					@; R2 = trash
	BLT delay_repeat_3			@; }
	
	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
.global SysTick_Handler
.thumb_func
SysTick_Handler:
	
	@; set stack frame
	PUSH {R7,LR}
	
	@; CINT_time++;
	LDR R0, =CINT_time
	LDR R1, [R0]
	ADD R1, #1
	STR R1, [R0]
	
	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
