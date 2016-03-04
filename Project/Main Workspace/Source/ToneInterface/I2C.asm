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
.global I2C_init
.thumb_func
I2C_init:
	
	@; backup register
	PUSH {R7,LR}

	@; enable clock for GPIOB
	CALL BIT_setBitfield, (RCC + RCC_AHB1ENR), 1, 1, 1

	@; initialize SCL and SDA pins
	CALL PIN_setMode, B, 6, 2, 1, 1, 2, 4
	CALL PIN_setMode, B, 9, 2, 1, 1, 2, 4

	@; enable clock for I2C
	CALL BIT_setBitfield, (RCC + RCC_APB1ENR), 1, 21, 1

	@; set CR2 (configuration register)
	CALL BIT_setBitfield, (I2C1 + I2C_CR2), 48,  0, 6 @; FREQ = 48 MHz
	
	@; set OAR1 (own address register)
	CALL BIT_setBitfield, (I2C1 + I2C_OAR1),  1, 14, 1 @; "should always be kept at 1 by software"
	CALL BIT_setBitfield, (I2C1 + I2C_OAR1), 99,  1, 7 @; the 7 bit address
	
	@; set CCR (clock control registers)
	CALL BIT_setBitfield, (I2C1 + I2C_CCR), 240, 0, 12 @; The input clock rate is 48 MHz. The output clock rate needs to be 100 kHz. Since T_high = T_low = CCR * T_pclk1, 5,000 ns = CCR * 20.83 ns, and CCR = 240. 
	
	@; set TRISE (maximum rise time)
	CALL BIT_setBitfield, (I2C1 + I2C_TRISE), 49, 0, 6 @; The max rise time for Sm is 1000 ns. In terms of clock cycles, (1000 ns / 20.83 ns) + 1 = 49

	@; set CR1 (configuration register)
	CALL BIT_setBitfield, (I2C1 + I2C_CR1), 1, 0, 1 @; enable I2C
	CALL BIT_setBitfield, (I2C1 + I2C_CR1), 1, 10, 1 @; enable ACK

	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = address
.global I2C_sendStart
.thumb_func
I2C_sendStart:
	
	@; backup register
	PUSH {R7,LR}
	PUSH {R4}

	MOV R4, R0

	@; generate start condition
	CALL BIT_setBitfield, (I2C1 + I2C_CR1), 1, 8, 1

	@; while (!SB);
	LDR R0, =(I2C1 + I2C_SR1)
	sendStart_loop1:
	LDR R1, [R0]
	ANDS R1, #(1 << 0)
	BEQ sendStart_loop1

	@; send address and r/w bit
	CALL I2C_sendData, R4

	@; while (!ADDR);
	@; LDR R0, =(I2C1 + I2C_SR1)
	@; sendStart_loop2:
	@; LDR R1, [R0]
	@; ANDS R1, #(1 << 1)
	@; BEQ sendStart_loop2

	@; restore registers
	POP {R4}
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = data
.global I2C_sendData
.thumb_func
I2C_sendData:
	
	@; backup register
	PUSH {R7,LR}

	MOV R1, R0

	@; send data
	CALL BIT_setBitfield, (I2C1 + I2C_DR), R1, 0, 8

	@; while (!TxE);
	@; LDR R0, =(I2C1 + I2C_SR1)
	@; sendData_loop1:
	@; LDR R1, [R0]
	@; ANDS R1, #(1 << 7)
	@; BEQ sendData_loop1

	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
.global I2C_sendStop
.thumb_func
I2C_sendStop:
	
	@; backup register
	PUSH {R7,LR}
	
	@; generate stop condition
	CALL BIT_setBitfield, (I2C1 + I2C_CR1), 1, 9, 1

	@; while (MSL);
	LDR R0, =(I2C1 + I2C_SR2)
	sendStop_loop1:
	LDR R1, [R0]
	ANDS R1, #(1 << 0)
	BNE sendStop_loop1

	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
