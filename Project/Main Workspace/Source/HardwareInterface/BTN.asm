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
BTN_pressed: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0



@; ///////////////////////////////////////////////////
@; SECTION: TEXT
@; ///////////////////////////////////////////////////
.section .text
@; ---------------------------------------------------
.global BTN_init
.thumb_func
BTN_init:
	
	@; backup register
	PUSH {R7,LR}



	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = button
@; R1 = port
@; R2 = pin
.global BTN_pollButton
.thumb_func
BTN_pollButton:
	
	@; backup register
	PUSH {R7,LR}
	PUSH {R4}
	
	MOV R4, R0						@; R4 = button
	
	CALL PIN_getValue, R1, R2		@; R0 = input from (port, pin)
	EOR R0, #1						@; invert input from active low to activ high

	LDR R2, =BTN_pressed			@; R2 = &BTN_pressed
	LDR R1, [R2, R4, LSL #2]		@; R1 = BTN_pressed[button]
	SUBS R3, R1, R0					@; if (BTN_pressed[button] != input) {
	BEQ pollButton_skip_1		
		STR R0, [R2, R4, LSL #2]		@; BTN_pressed[button] = input;
		MOV R1, R4						@; R1 = button
		LDR R2, =CINT_time				@; R2 = &CINT_time
		LDR R2, [R2]					@; R2 = CINT_time
		BL BTQ_add						@; BTQ_add(input, button, CINT_time);
	pollButton_skip_1:				@; }

	@; restore registers
	POP {R4}
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
.global BTN_poll
.thumb_func
BTN_poll:
	
	@; backup register
	PUSH {R7,LR}
	
	@; turn off all anodes
	CALL P24_setAnodePattern, 0xFF
	
	@; buttons 0, 1
	CALL P24_setCathodePattern, ~(0x10)
	CALL BTN_pollButton, 0, A, 15
	CALL BTN_pollButton, 1, C, 8
	
	@; buttons 2, 3
	CALL P24_setCathodePattern, ~(0x08)
	CALL BTN_pollButton, 2, A, 15
	CALL BTN_pollButton, 3, C, 8
	
	@; buttons 4, 5
	CALL P24_setCathodePattern, ~(0x01)
	CALL BTN_pollButton, 4, A, 15
	CALL BTN_pollButton, 5, C, 8
	
	@; buttons 6, 7
	CALL P24_setCathodePattern, ~(0x40)
	CALL BTN_pollButton, 6, A, 15
	CALL BTN_pollButton, 7, C, 8
	
	@; buttons 8, 9
	CALL P24_setCathodePattern, ~(0x02)
	CALL BTN_pollButton, 8, A, 15
	CALL BTN_pollButton, 9, C, 8
	
	@; buttons 10, 11
	CALL P24_setCathodePattern, ~(0x80)
	CALL BTN_pollButton, 10, A, 15
	CALL BTN_pollButton, 11, C, 8
	
	@; buttons 12
	CALL P24_setCathodePattern, ~(0x20)
	CALL BTN_pollButton, 12, A, 15
	
	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
