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

.global P24_index
.global P24_anodePattern
.global P24_cathodePattern

P24_index:			.word 0
P24_anodePattern:	.word ~(0x80), ~(0x40), ~(0x20), ~(0x10), ~(0x08)
P24_cathodePattern:	.word ~(0x00), ~(0x00), ~(0x00), ~(0x00), ~(0x00)

@; Patterns by index
@; [0] digit3
@; [1] digit2
@; [2] digit1
@; [3] digit0
@; [4] led



@; ///////////////////////////////////////////////////
@; SECTION: TEXT
@; ///////////////////////////////////////////////////
.section .text
@; ---------------------------------------------------
.global P24_init
.thumb_func
P24_init:

	@; set stack frame
	PUSH {R7,LR}
	
	@; enable clock for GPIOA - GPIOD
	CALL BIT_setBitfield, (RCC+RCC_AHB1ENR), 1, 3, 1	@; enable clock on port d
	CALL BIT_setBitfield, (RCC+RCC_AHB1ENR), 1, 2, 1	@; enable clock on port c
	CALL BIT_setBitfield, (RCC+RCC_AHB1ENR), 1, 1, 1	@; enable clock on port b
	CALL BIT_setBitfield, (RCC+RCC_AHB1ENR), 1, 0, 1	@; enable clock on port a
	
	@; set output pins (for U_AN and U_CA)
	CALL PIN_setMode, A, 1,	 1, 0, 1, 0, 0
	CALL PIN_setMode, B, 0,	 1, 0, 1, 0, 0
	CALL PIN_setMode, B, 1,  1, 0, 1, 0, 0
	CALL PIN_setMode, B, 4,  1, 0, 1, 0, 0
	CALL PIN_setMode, B, 5,  1, 0, 1, 0, 0
	CALL PIN_setMode, B, 11, 1, 0, 1, 0, 0
	CALL PIN_setMode, C, 1,  1, 0, 1, 0, 0
	CALL PIN_setMode, C, 2,  1, 0, 1, 0, 0
	CALL PIN_setMode, C, 4,  1, 0, 1, 0, 0
	CALL PIN_setMode, C, 5,  1, 0, 1, 0, 0
	CALL PIN_setMode, C, 11, 1, 0, 1, 0, 0
	CALL PIN_setMode, D, 2,  1, 0, 1, 0, 0
	
	@; set input pins (for BTN)
	CALL PIN_setMode, A, 15, 0, 0, 1, 1, 0
	CALL PIN_setMode, C, 8,  0, 0, 1, 1, 0
	
	@; set default values
	CALL P24_setAnodePattern,	~(0x00)
	CALL P24_setCathodePattern,	~(0x00)

	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = pattern
.global P24_setAnodePattern
.thumb_func
P24_setAnodePattern:

	@; set stack frame
	PUSH {R7,LR}
	PUSH {R4}
	
	MOV R4, R0
	
	@; set input lines
	CALL PIN_setValue, C, 5,  R4
	LSR R4, #1
	CALL PIN_setValue, B, 5,  R4
	LSR R4, #1
	CALL PIN_setValue, B, 0,  R4
	LSR R4, #1
	CALL PIN_setValue, B, 11, R4
	LSR R4, #1
	CALL PIN_setValue, B, 1,  R4
	LSR R4, #1
	CALL PIN_setValue, C, 4,  R4
	LSR R4, #1
	CALL PIN_setValue, A, 1,  R4
	LSR R4, #1
	CALL PIN_setValue, C, 2,  R4
	
	@; toggle clock line
	CALL PIN_setValue, C, 11, 0
	CALL PIN_setValue, C, 11, 1
	
	@; restore stack frame
	POP {R4}
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = pattern
.global P24_setCathodePattern
.thumb_func
P24_setCathodePattern:
	
	@; set stack frame
	PUSH {R7,LR}
	PUSH {R4}
	
	@; load bit pattern into non-scratch register
	MOV R4, R0
	
	@; set input lines
	CALL PIN_setValue, B, 0,  R4
	LSR R4, #1
	CALL PIN_setValue, C, 4,  R4
	LSR R4, #1
	CALL PIN_setValue, C, 2,  R4
	LSR R4, #1
	CALL PIN_setValue, B, 11, R4
	LSR R4, #1
	CALL PIN_setValue, B, 5,  R4
	LSR R4, #1
	CALL PIN_setValue, A, 1,  R4
	LSR R4, #1
	CALL PIN_setValue, B, 1,  R4
	LSR R4, #1
	CALL PIN_setValue, C, 5,  R4
	
	@; toggle clock line
	CALL PIN_setValue, D, 2, 0
	CALL PIN_setValue, D, 2, 1
	
	@; restore stack frame
	POP {R4}
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
.global P24_update
.thumb_func
P24_update:
	
	@; set stack frame
	PUSH {R7,LR}

	LDR R0, =P24_index
	LDR R0, [R0]
	SUBS R0, #0
	BNE update_break_1	@; if (P24_index == 0) {
		BL ROT_poll			@; ROT_poll();
		BL BTN_poll			@; BTN_poll();
	update_break_1:		@; }
	
	@; disable anode latch output
	CALL PIN_setValue, B, 4, ~(0)

	@; P24_setAnodePattern(P24_anodePattern[P24_index]);
	LDR R1, =P24_index
	LDR R1, [R1]
	LDR R0, =P24_anodePattern
	LDR R0, [R0, R1, LSL #2]
	CALL P24_setAnodePattern, R0
	
	@; P24_setCathodePattern(P24_cathodePattern[P24_index]);
	LDR R1, =P24_index
	LDR R1, [R1]
	LDR R0, =P24_cathodePattern
	LDR R0, [R0, R1, LSL #2]
	CALL P24_setCathodePattern, R0
	
	@; enable anode latch output
	CALL PIN_setValue, B, 4, ~(1)
	
	@; P24_index = (P24_index + 1) % 5;
	LDR R0, =P24_index
	LDR R1, [R0]
	ADD R1, #1
	SUBS R2, R1, #5
	IT GE
	MOVGE R1, #0
	STR R1, [R0]
	
	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
