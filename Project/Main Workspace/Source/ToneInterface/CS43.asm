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
.global CS43_powerOn
.thumb_func
CS43_powerOn:
	
	@; backup register
	PUSH {R7,LR}

	

	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; Requires I2C to be initialized. 
.global CS43_init
.thumb_func
CS43_init:
	
	@; backup register
	PUSH {R7,LR}

	@; enable clock for GPIOD
	CALL BIT_setBitfield, (RCC + RCC_AHB1ENR), 1, 3, 1

	@; initialize !RESET pin
	CALL PIN_setMode, D, 4,	1, 0, 1, 0, 0

	@; set !RESET
	CALL PIN_setValue, D, 4, 1

	CALL CS43_setRegister, 0x00, 0x99
	CALL CS43_setRegister, 0x47, 0x80
	CALL CS43_setRegister, 0x32, 0x80
	CALL CS43_setRegister, 0x32, 0x00
	CALL CS43_setRegister, 0x00, 0x00
	CALL CS43_setRegister, 0x02, 0x9E

	CALL CS43_setRegister, 0x04, 0xAF
	CALL CS43_setRegister, 0x08, 0x01
	CALL CS43_setRegister, 0x09, 0x01
	CALL CS43_setRegister, 0x0D, 0xD0
	CALL CS43_setRegister, 0x0E, 0xC3
	CALL CS43_setRegister, 0x0F, 0x30
	CALL CS43_setRegister, 0x14, 0x00
	CALL CS43_setRegister, 0x15, 0x00
	CALL CS43_setRegister, 0x20, 0x00
	CALL CS43_setRegister, 0x21, 0x00
	CALL CS43_setRegister, 0x22, 0x00
	CALL CS43_setRegister, 0x23, 0x00

	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = register address
@; R1 = data
.global CS43_setRegister
.thumb_func
CS43_setRegister:
	
	@; backup register
	PUSH {R7,LR}
	PUSH {R4,R5}
	
	MOV R4, R0
	MOV R5, R1

	CALL I2C_sendStart, 0x94
	CALL I2C_sendData, R4
	CALL I2C_sendData, R5
	CALL I2C_sendStop

	@; restore registers
	POP {R4,R5}
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = intensity (-10->110)
.global CS43_setIntensity
.thumb_func
CS43_setIntensity:
	
	@; backup register
	PUSH {R7,LR}
	PUSH {R4}
	
	LDR R1, =10
	SDIV R0, R1
	MOV R4, R0

	CALL CS43_setRegister, 0x14, R4
	CALL CS43_setRegister, 0x15, R4

	@; restore registers
	POP {R4}
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
