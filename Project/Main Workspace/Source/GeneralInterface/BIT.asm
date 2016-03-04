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
@; R0 = address
@; R1 = bit
@; R2 = lsb
.global BIT_setBit
.thumb_func
BIT_setBit:

	@; set stack frame
	PUSH {R7,LR}

	@; call setBitfield
	CALL BIT_setBitfield, R0, R1, R2, 1

	@; restore stack frame
	POP {R7,LR}

BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = address
@; R1 = bitfield
@; R2 = lsb
@; R3 = width
.global BIT_setBitfield
.thumb_func
BIT_setBitfield:

	@; set stack frame
	PUSH {R7,LR}
	PUSH {R4-R5}

	@; shift bitfield by lsb
	LSL R1, R2

	@; create bitfield2 of all 1's
	LDR R4, =0xFFFFFFFF
	LSL R4, R3
	MVN R4, R4
	LSL R4, R2

	@; mask bitfield by bitfield2
	AND R1, R4

	@; value: clear bitfield2, insert bitfield
	LDR R5, [R0]
	BIC R5, R4
	ORR R5, R1
	STR R5, [R0]

	@; restore stack frame
	POP {R4-R5}
	POP {R7,LR}

BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = address
@; R1 = lsb
.global BIT_getBit
.thumb_func
BIT_getBit:

	@; set stack frame
	PUSH {R7,LR}

	@; call getBitfield
	CALL BIT_getBitfield, R0, R1, 1

	@; restore stack frame
	POP {R7,LR}

BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = address
@; R1 = lsb
@; R2 = width
.global BIT_getBitfield
.thumb_func
BIT_getBitfield:

	@; set stack frame
	PUSH {R7,LR}

	@; create bitfield2 of all 1's
	LDR R3, =0xFFFFFFFF
	LSL R3, R2
	MVN R3, R3
	LSL R3, R1

	@; value: clear bitfield2, insert bitfield
	LDR R0, [R0]
	AND R0, R3
	LSR R0, R1

	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
