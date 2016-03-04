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
@; R0 = port (A-K)
@; R1 = pin (0-15)
@; R2 = moder
@; R3 = otyper
@; SP[0] = ospeeder
@; SP[1] = pupdr
@; SP[2] = af
.global PIN_setMode
.thumb_func
PIN_setMode:
	
	@; set stack frame
	PUSH {R7,LR}
	PUSH {R0-R3}
	
	@; set moder
	LDR R0, [SP, #(4*0)]
	ADD R0, #GPIO_MODER
	LDR R1, [SP, #(4*2)]
	LDR R2, [SP, #(4*1)]
	LSL R2, #1
	CALL BIT_setBitfield, R0, R1, R2, 2
	
	@; set otyper
	LDR R0, [SP, #(4*0)]
	ADD R0, #GPIO_OTYPER
	LDR R1, [SP, #(4*3)]
	LDR R2, [SP, #(4*1)]
	CALL BIT_setBitfield, R0, R1, R2, 1
	
	@; set ospeeder
	LDR R0, [SP, #(4*0)]
	ADD R0, #GPIO_OSPEEDER
	LDR R1, [SP, #(4*6)]
	LDR R2, [SP, #(4*1)]
	LSL R2, #1
	CALL BIT_setBitfield, R0, R1, R2, 2
	
	@; set pupdr
	LDR R0, [SP, #(4*0)]
	ADD R0, #GPIO_PUPDR
	LDR R1, [SP, #(4*7)]
	LDR R2, [SP, #(4*1)]
	LSL R2, #1
	CALL BIT_setBitfield, R0, R1, R2, 2
	
	@; set af
	LDR R0, [SP, #(4*0)]
	ADD R0, #GPIO_AFRL
	LDR R1, [SP, #(4*8)]
	LDR R2, [SP, #(4*1)]
	SUBS R3, R2, #8
	ITT GE
	ADDGE R0, #(GPIO_AFRH-GPIO_AFRL)
	SUBGE R2, #8
	LSL R2, #2
	CALL BIT_setBitfield, R0, R1, R2, 4
	
	@; restore stack frame
	POP {R0-R3}
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = port (A-K)
@; R1 = pin (0-15)
@; R2 = value (0-1)
.global PIN_setValue
.thumb_func
PIN_setValue:

	@; set stack frame
	PUSH {R7,LR}

	@; write to BSRR
	ADD R0, #GPIO_BSRR
	MOV R3, R1
	MOV R1, R2
	MOV R2, R3
	ANDS R1, #0x01
	ITT EQ
	MOVEQ R1, #1
	ADDEQ R2, #16
	CALL BIT_setBit, R0, R1, R2

	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = port (A-K)
@; R1 = pin (0-15)
.global PIN_getValue
.thumb_func
PIN_getValue:

	@; set stack frame
	PUSH {R7,LR}

	@; read from IDR (input data register)
	ADD R0, #GPIO_IDR
	CALL BIT_getBit, R0, R1

	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
