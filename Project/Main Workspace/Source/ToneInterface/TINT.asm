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
.global TINT_init
.thumb_func
TINT_init:
	
	@; backup register
	PUSH {R7,LR}

	@; The order of I2C and CS43 matters. 
	CALL DAC_init
	CALL I2C_init
	CALL CS43_init
	CALL SIN_init
	CALL DMA_init
	CALL TIM6_init

	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = on/off (on = 1)
.global TINT_setOn
.thumb_func
TINT_setOn:
	
	@; backup register
	PUSH {R7,LR}

	CALL TIM6_setOn, R0

	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = frequency
.global TINT_setFrequency
.thumb_func
TINT_setFrequency:
	
	@; backup register
	PUSH {R7,LR}

	CALL SIN_setFrequency, R0

	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = intensity (-10->110)
.global TINT_setIntensity
.thumb_func
TINT_setIntensity:
	
	@; backup register
	PUSH {R7,LR}

	CALL CS43_setIntensity, R0

	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
