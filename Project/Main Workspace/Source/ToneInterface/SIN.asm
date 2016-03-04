@; ///////////////////////////////////////////////////
@; GENERAL
@; ///////////////////////////////////////////////////
.syntax unified
.thumb
.include "Header.inc"

.equ SIN_ramMaxSize, 12800
.equ SIN_romSize,    40000
.equ SIN_rom,        0x08010000



@; ///////////////////////////////////////////////////
@; SECTION: DATA
@; ///////////////////////////////////////////////////
.section .data
.global SIN_ramSize
SIN_ramSize: .word 0



@; ///////////////////////////////////////////////////
@; SECTION: BSS
@; ///////////////////////////////////////////////////
.section .bss
.comm SIN_ram, SIN_ramMaxSize



@; ///////////////////////////////////////////////////
@; SECTION: TEXT
@; ///////////////////////////////////////////////////
.section .text
@; ---------------------------------------------------
.global SIN_init
.thumb_func
SIN_init:
	
	@; backup register
	PUSH {R7,LR}
	


	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = frequency (aka freqPick)
.global SIN_setFrequency
.thumb_func
SIN_setFrequency:
	
	@; backup register
	PUSH {R7,LR}
	PUSH {R4-R7}
	
	LDR R4, =SIN_ramMaxSize		@; ramNumSamples = ((((ramMaxNumSamples*frequency)/playbackFrequency)*playbackFrequency)/frequency);
	LDR R1, =40000
	MUL R4, R0
	UDIV R4, R1
	MUL R4, R1
	UDIV R4, R0

	@; R0 = 					@; freqPick
	LDR R1, =SIN_rom			@; rom[]
	LDR R2, =SIN_ram			@; ram[]
	LDR R3, =SIN_romSize		@; romNumSamples
	@; R4 = 					@: ramNumSamples
	LDR R5, =0					@; indexROM = 0;
	LDR R6, =0					@; indexRAM = 0;
	@; R7 = 					@; temp
	setFrequency_loop1_start:	@; while (indexRAM < ramNumSamples) {
	SUBS R7, R6, R4
	IT GE
	BGE setFrequency_loop1_stop
		LDRB R7, [R1, R5]		@; ram[indexRAM] = rom[indexROM]
		STRB R7, [R2, R6]
		ADD R5, R0				@; indexROM = (indexROM + freqPick) % romNumSamples;
		SUBS R7, R5, R3
		IT GE
		MOVGE R5, R7
		ADD R6, #1				@; indexRAM++;

	B setFrequency_loop1_start
	setFrequency_loop1_stop:	@; }
	
	LDR R0, =SIN_ramSize		@; ramSize = ramNumSamples;
	STR R4, [R0]
	
	CALL DMA_setNumSamples, R4 @; update number of samples to transfer for current frequency

	@; restore registers
	POP {R4-R7}
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
