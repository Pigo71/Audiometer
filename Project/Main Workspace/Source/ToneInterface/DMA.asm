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
.global DMA_init
.thumb_func
DMA_init:
	
	@; backup register
	PUSH {R7,LR}
	
	@; enable interrupt for DMA
	@; CALL BIT_setBitfield, (NVIC + NVIC_ISER0), 1, 16, 1

	@; enable clock for DMA
	CALL BIT_setBitfield, (RCC + RCC_AHB1ENR), 1, 21, 1
	
	@; set S5CR (steam 5 configuration register)
	CALL BIT_setBitfield, (DMA + DMA_S5CR), 7, 25, 3 @; channel 7 (DAC1)
	CALL BIT_setBitfield, (DMA + DMA_S5CR), 1, 10, 1 @; auto increment memory pointer
	CALL BIT_setBitfield, (DMA + DMA_S5CR), 1,  8, 1 @; circular mode
	CALL BIT_setBitfield, (DMA + DMA_S5CR), 1,  6, 2 @; transfer direction: memory-to-peripheral
	@; CALL BIT_setBitfield, (DMA + DMA_S5CR), 1,  4, 1 @; enable transfer complete interrupt
	
	@; set S5PAR (stream 5 peripheral address register)
	CALL BIT_setBitfield, (DMA + DMA_S5PAR), (DAC + DAC_DHR8R1), 0, 32
	
	@; set S5M0AR (stream 5 memory 0 address register)
	CALL BIT_setBitfield, (DMA + DMA_S5M0AR), SIN_ram, 0, 32

	@; enable stream
	CALL BIT_setBitfield, (DMA + DMA_S5CR), 1, 0, 1

	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
@; R0 = numSamples
.global DMA_setNumSamples
.thumb_func
DMA_setNumSamples:
	
	@; backup register
	PUSH {R7,LR}
	PUSH {R4}
	
	MOV R4, R0
	CALL BIT_setBitfield, (DMA + DMA_S5CR),    0, 0,  1 @; disable stream
	CALL BIT_setBitfield, (DMA + DMA_S5NDTR), R4, 0, 16 @; update number of samples to transfer for current frequency
	CALL BIT_setBitfield, (DMA + DMA_S5CR),    1, 0,  1 @; enable stream

	@; restore registers
	POP {R4}
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
@; ---------------------------------------------------
.global DMA1_Stream5_Handler
.thumb_func
DMA1_Stream5_Handler:
	
	@; backup register
	PUSH {R7,LR}

	@; clear interrupt flags
	CALL BIT_setBitfield, (DMA + DMA_HIFCR), 0xFFFFFFFF, 0, 32
	CALL BIT_setBitfield, (DMA + DMA_LIFCR), 0xFFFFFFFF, 0, 32

	@; restore registers
	POP {R7,LR}
	
BX LR
@; ---------------------------------------------------
