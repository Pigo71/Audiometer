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
ledToBitPosition:	.word 5, 1, 0, 2, 7, 6



@; ///////////////////////////////////////////////////
@; SECTION: TEXT
@; ///////////////////////////////////////////////////
.section .text
@; ---------------------------------------------------
.global LED_init
.thumb_func
LED_init:
	
	@; set stack frame
	PUSH {R7,LR}
	
	
	
	@; restore stack frame
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = led (0-5)
@; R1 = on/off (on = 1)
.global LED_setOn
.thumb_func
LED_setOn:

	@; backup registers
	PUSH {R7,LR}
	
	LDR R2, =ledToBitPosition
	LDR R2, [R2, R0, LSL #2]		@; R2 = ledToBitPosition[led];
	
	LDR R0, =P24_cathodePattern		@; R0 = P24_cathodePattern
	LDR R3, [R0, #(4*4)]		@; R3 = P24_cathodePattern[4];
	
	ANDS R1, #1
	BEQ setOn_skip_1				@; if (on == 1) {
		LSL R1, R2						@; R1 = on << ledToBitPosition[led];
		BIC R3, R1						@; R3 = P24_cathodePattern[4] & ~(on << ledToBitPosition[led]);
		B setOn_skip_2
	setOn_skip_1:					@; } else {
		MOV R1, #1						@; R1 = 1
		LSL R1, R2						@; R1 = 1 << ledToBitPosition[led];
		ORR R3, R1						@; R3 = P24_cathodePattern[4] | (on << ledToBitPosition[led]);
	setOn_skip_2:

	STR R3, [R0, #(4*4)]		@; P24_cathodePattern[4] = R3 (updated value if-else);
	
	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
