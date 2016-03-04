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

.global ROT_value
.global ROT_on

ROT_state: .word 0
ROT_on:    .word 1
ROT_value: .word 0



@; ///////////////////////////////////////////////////
@; SECTION: TEXT
@; ///////////////////////////////////////////////////
.section .text
@; ---------------------------------------------------
.global ROT_init
.thumb_func
ROT_init:
	
	@; set stack frame
	PUSH {R7,LR}
	PUSH {R4}
	
	@; Set the state to the starting position of the rotary encoder. 
	CALL P24_setAnodePattern, ~(0x02)
	CALL P24_setCathodePattern, ~(0x00)
	CALL PIN_getValue, A, 15
	MOV R4, R0, LSL #1
	CALL PIN_getValue, C, 8
	ORR R4, R0
	LDR R0, =ROT_state
	STR R4, [R0]
	
	@; restore stack frame
	POP {R4}
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = on/off (on = 1)
.global ROT_setOn
.thumb_func
ROT_setOn:
	
	@; backup register
	PUSH {R7,LR}
	
	LDR R1, =ROT_on
	STR R0, [R1]
	
	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
.global ROT_poll
.thumb_func
ROT_poll:
	
	@; backup register
	PUSH {R7,LR}
	PUSH {R4}

	CALL P24_setAnodePattern, ~(0x02)
	CALL P24_setCathodePattern, ~(0x00)
	CALL PIN_getValue, A, 15
	MOV R4, R0, LSL #1
	CALL PIN_getValue, C, 8
	ORR R4, R0					@; R4 = nextState

	LDR R0, =ROT_state
	LDR R0, [R0]				@; R0 = currState
	MOV R1, R4					@; R1 = nextState, trash R4
	LDR R2, =ROT_value
	LDR R2, [R2]				@; R2 = ROT_value
	
	SUBS R3, R0, #0
	BNE poll_state_0_break		@; if (currState == 0) { // trash R0
		SUBS R3, R1, #1
		IT EQ
		ADDEQ R2, #1				@; if (nextState == 1) R2 = t_ROT_value = ROT_value++;
		SUBS R3, R1, #2
		IT EQ
		SUBEQ R2, #1				@; if (nextState == 1) R2 = t_ROT_value = ROT_value--;
	poll_state_0_break:
	SUBS R3, R0, #1
	BNE poll_state_1_break		@; } else if (currState == 1) { // trash R0
		SUBS R3, R1, #3
		IT EQ
		ADDEQ R2, #1				@; if (nextState == 1) R2 = t_ROT_value = ROT_value++;
		SUBS R3, R1, #0
		IT EQ
		SUBEQ R2, #1				@; if (nextState == 1) R2 = t_ROT_value = ROT_value--;
	poll_state_1_break:
	SUBS R3, R0, #2
	BNE poll_state_2_break		@; } else if (currState == 2) { // trash R0
		SUBS R3, R1, #0
		IT EQ
		ADDEQ R2, #1				@; if (nextState == 1) R2 = t_ROT_value = ROT_value++;
		SUBS R3, R1, #3
		IT EQ
		SUBEQ R2, #1				@; if (nextState == 1) R2 = t_ROT_value = ROT_value--;
	poll_state_2_break:
	SUBS R3, R0, #3
	BNE poll_state_3_break		@; } else if (currState == 3) { // trash R0
		SUBS R3, R1, #2
		IT EQ
		ADDEQ R2, #1				@; if (nextState == 1) R2 = t_ROT_value = ROT_value++;
		SUBS R3, R1, #1
		IT EQ
		SUBEQ R2, #1				@; if (nextState == 1) R2 = t_ROT_value = ROT_value--;
	poll_state_3_break:			@; }

	LDR R3, =ROT_state
	STR R1, [R3]				@; ROT_state = nextState; // trash R1
	LDR R3, =ROT_on
	LDR R3, [R3]
	SUBS R3, #1
	BNE poll_skip_1				@; if (ROT_on) {
		LDR R3, =ROT_value
		STR R2, [R3]				@; ROT_value = t_ROT_value; // trash R2
	poll_skip_1:				@; }

	@; restore registers
	POP {R4}
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
