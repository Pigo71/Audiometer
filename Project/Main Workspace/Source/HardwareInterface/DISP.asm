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
.global DISP_numberToPattern
@; DISP_numberToPattern = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', ' '};
@; Patterns '0'-'9' are indexed by numbers '0'-'9'. 
@; Patterns '-' and ' ' are indexed by symbols 'dash' and 'space' (defined in the header).
DISP_numberToPattern: .word 0x03, 0x9F, 0x25, 0x0D, 0x99, 0x49, 0x41, 0x1F, 0x01, 0x09, 0xFD, 0xFF



@; ///////////////////////////////////////////////////
@; SECTION: TEXT
@; ///////////////////////////////////////////////////
.section .text
@; ---------------------------------------------------
.global DISP_init
.thumb_func
DISP_init:
	
	@; set stack frame
	PUSH {R7,LR}
	
	
	
	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = digit (0-3)
@; R1 = patternIndex (0-9, dash, space)
.global DISP_setDigit
.thumb_func
DISP_setDigit:
	
	@; set stack frame
	PUSH {R7,LR}
	
	LDR R2, =P24_cathodePattern
	LSL R0, #2
	ADD R0, R2								@; R0 = &P24_cathodePattern[digit]

	LDR R2, =DISP_numberToPattern			@; R2 = DISP_numberToPattern
	LDR R1, [R2, R1, LSL #2]				@; R1 = DISP_numberToPattern[patternIndex]
	CALL BIT_setBitfield, R0, R1, 0, 8		@; BIT_setBitfield(&P24_cathodePattern[digit], DISP_numberToPattern[patternIndex], 0, 8);
	
	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
