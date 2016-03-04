@; ///////////////////////////////////////////////////
@; MACROS
@; ///////////////////////////////////////////////////

@; PendSV
.macro PendSV
	SB (SCB+SCB_ICSR), 1, 28
.endm

@; Call Function
.macro CALL function, p0="t", p1="t", p2="t", p3="t", p4="t", p5="t", p6="t", p7="t"
	CALL_SSP SUB, \p4, \p5, \p6, \p7
	LROV R0, \p0
	LROV R1, \p1
	LROV R2, \p2
	LROV R3, \p3
	LROV R4, \p4, 0
	LROV R5, \p5, 1
	LROV R6, \p6, 2
	LROV R8, \p7, 3
	BL \function
	CALL_SSP ADD, \p4, \p5, \p6, \p7
.endm

@; Set Stack Pointer
.macro CALL_SSP instruction, p4, p5, p6, p7
	.ifnc "\p6", "t"
		\instruction SP, #(4*4)
	.else
	.ifnc "\p4", "t"
		\instruction SP, #(4*2)
	.endif
	.endif
.endm

@; Load Register or Value
.macro LROV destination, source, pushIndex = -1
	.ifnc "\source", "t"
		.ifnc "\destination", "\source"
			IR \source, "LROV_REG", "LROV_LIT", "\destination, \source"
		.endif
		.ifge \pushIndex
			STR \destination, [SP, #(4*(\pushIndex))]
		.endif
	.endif
.endm

.macro LROV_REG destination, source
	MOV \destination, \source
.endm

.macro LROV_LIT destination, source
	LDR \destination, =\source
.endm

@; If Register Do Else Do
.macro IR source, macro1, macro2, params, index = 0
	.ifc "\source", "R0"
		\macro1 \params
	.else
	.ifc "\source", "R1"
		\macro1 \params
	.else
	.ifc "\source", "R2"
		\macro1 \params
	.else
	.ifc "\source", "R3"
		\macro1 \params
	.else
	.ifc "\source", "R4"
		\macro1 \params
	.else
	.ifc "\source", "R5"
		\macro1 \params
	.else
	.ifc "\source", "R6"
		\macro1 \params
	.else
	.ifc "\source", "R7"
		\macro1 \params
	.else
	.ifc "\source", "R8"
		\macro1 \params
	.else
	.ifc "\source", "R9"
		\macro1 \params
	.else
	.ifc "\source", "R10"
		\macro1 \params
	.else
	.ifc "\source", "R11"
		\macro1 \params
	.else
	.ifc "\source", "R12"
		\macro1 \params
	.else
	.ifc "\source", "R13"
		\macro1 \params
	.else
	.ifc "\source", "R14"
		\macro1 \params
	.else
	.ifc "\source", "R15"
		\macro1 \params
	.else
	.ifc "\source", "SP"
		\macro1 \params
	.else
	.ifc "\source", "LR"
		\macro1 \params
	.else
	.ifc "\source", "PC"
		\macro1 \params
	.else
		.ifgt \index
			\macro2 "\params", (\index-1)
		.else
			\macro2 \params
		.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
	.endif
.endm



@; ///////////////////////////////////////////////////
@; REGISTERS
@; ///////////////////////////////////////////////////

.equ GPIOA,	0x40020000
.equ GPIOB,	0x40020400
.equ GPIOC,	0x40020800
.equ GPIOD,	0x40020C00
.equ GPIOE,	0x40021000
.equ GPIOF,	0x40021400
.equ GPIOG,	0x40021800
.equ GPIOH,	0x40021C00
.equ GPIOI,	0x40022000
.equ GPIOJ,	0x40022400
.equ GPIOK,	0x40022800

.equ A, GPIOA
.equ B, GPIOB
.equ C, GPIOC
.equ D, GPIOD
.equ E, GPIOE
.equ F, GPIOF
.equ G, GPIOG
.equ H, GPIOH
.equ I, GPIOI
.equ J, GPIOJ
.equ K, GPIOK

.equ GPIO_MODER, 	0x00
.equ GPIO_OTYPER, 	0x04
.equ GPIO_OSPEEDER, 0x08
.equ GPIO_PUPDR, 	0x0C
.equ GPIO_IDR, 		0x10
.equ GPIO_ODR, 		0x14
.equ GPIO_BSRR, 	0x18
.equ GPIO_LCKR, 	0x1C
.equ GPIO_AFRL, 	0x20
.equ GPIO_AFRH, 	0x24

.equ RCC, 0x40023800

.equ RCC_CR, 		0x00
.equ RCC_PLLCFGR, 	0x04
.equ RCC_CFGR, 		0x08
.equ RCC_CIR, 		0x0C
.equ RCC_AHB1RSTR, 	0x10
.equ RCC_AHB2RSTR, 	0x14
.equ RCC_AHB3RSTR, 	0x18
.equ RCC_APB1RSTR, 	0x20
.equ RCC_APB2RSTR, 	0x24
.equ RCC_AHB1ENR, 	0x30
.equ RCC_AHB2ENR, 	0x34
.equ RCC_AHB3ENR, 	0x38
.equ RCC_APB1ENR,	0x40
.equ RCC_APB2ENR,	0x44
.equ RCC_AHB1LPENR,	0x50
.equ RCC_AHB2LPENR,	0x54
.equ RCC_AHB3LPENR,	0x58
.equ RCC_APB1LPENR,	0x60
.equ RCC_APB2LPENR,	0x64
.equ RCC_BDCR,		0x70
.equ RCC_CSR,		0x74
.equ RCC_SSCGR,		0x80
.equ RCC_PLLIS2C,	0x84
.equ RCC_PLLSAICFGR,0x88
.equ RCC_DCKCFGR,	0x8C

.equ SYSCFG, 0x40013800

.equ SYSCFG_MEMRM,		0x00
.equ SYSCFG_PMC,		0x04
.equ SYSCFG_EXTICR1,	0x08
.equ SYSCFG_EXTICR2,	0x0C
.equ SYSCFG_EXTICR3,	0x10
.equ SYSCFG_EXTICR4,	0x14
.equ SYSCFG_CMPCR,		0x20

.equ EXTI, 0x40013C00

.equ EXTI_IMR,		0x00
.equ EXTI_EMR,		0x04
.equ EXTI_RTSR,		0x08
.equ EXTI_FTSR,		0x0C
.equ EXTI_SWIER,	0x10
.equ EXTI_PR,		0x14

.equ NVIC, 0xE000E100

.equ NVIC_ISER0,	0x000
.equ NVIC_ISER1,	0x004
.equ NVIC_ISER2,	0x008
.equ NVIC_ICER0,	0x080
.equ NVIC_ICER1,	0x084
.equ NVIC_ICER2,	0x088
.equ NVIC_ISPR0,	0x100
.equ NVIC_ISPR1,	0x104
.equ NVIC_ISPR2,	0x108
.equ NVIC_ICPR0,	0x180
.equ NVIC_ICPR1,	0x184
.equ NVIC_ICPR2,	0x188
.equ NVIC_IABR0,	0x200
.equ NVIC_IABR1,	0x204
.equ NVIC_IABR2,	0x208
.equ NVIC_IPR0,		0x300
.equ NVIC_IPR1,		0x304
.equ NVIC_IPR2,		0x308
.equ NVIC_IPR3,		0x30C
.equ NVIC_IPR4,		0x310
.equ NVIC_IPR5,		0x314
.equ NVIC_IPR6,		0x318
.equ NVIC_IPR7,		0x31C
.equ NVIC_IPR8,		0x320
.equ NVIC_IPR9,		0x324
.equ NVIC_IPR10,	0x328
.equ NVIC_IPR11,	0x32C
.equ NVIC_IPR12,	0x330
.equ NVIC_IPR13,	0x334
.equ NVIC_IPR14,	0x338
.equ NVIC_IPR15,	0x33C
.equ NVIC_IPR16,	0x340
.equ NVIC_IPR17,	0x344
.equ NVIC_IPR18,	0x348
.equ NVIC_IPR19,	0x34C
.equ NVIC_STIR,		0xE00

.equ STK, 0xE000E010

.equ STK_CTRL,	0x00
.equ STK_LOAD,	0x04
.equ STK_VAL,	0x08
.equ STK_CALIB,	0x0C

.equ SCB, 0xE000ED00

.equ SCB_CPUID,	0x00
.equ SCB_ICSR,	0x04
.equ SCB_VTOR,	0x08
.equ SCB_AIRCR,	0x0C
.equ SCB_SCR,	0x10
.equ SCB_CCR,	0x14
.equ SCB_SHPR1,	0x18
.equ SCB_SHPR2,	0x1C
.equ SCB_SHPR3,	0x20
.equ SCB_SHCRS,	0x24
.equ SCB_CFSR,	0x28
.equ SCB_HFSR,	0x2C
.equ SCB_MMAR,	0x34
.equ SCB_BFAR,	0x38
.equ SCB_AFSR,	0x3C

.equ TIM6, 0x40001000
.equ TIM7, 0x40001400

.equ TIM_CR1,	0x00
.equ TIM_CR2,	0x04
.equ TIM_SMCR,	0x08
.equ TIM_DIER,	0x0C
.equ TIM_SR,	0x10
.equ TIM_EGR,	0x14
.equ TIM_CCMR1,	0x18
.equ TIM_CCMR2,	0x1C
.equ TIM_CCER,	0x20
.equ TIM_CNT,	0x24
.equ TIM_PSC,	0x28
.equ TIM_ARR,	0x2C
.equ TIM_CCR1,	0x34
.equ TIM_CCR2,	0x38
.equ TIM_CCR3,	0x3C
.equ TIM_CCR4,	0x40
.equ TIM_DCR,	0x48
.equ TIM_DMAR,	0x4C
.equ TIM_OR,	0x50

.equ DAC, 0x40007400

.equ DAC_CR,		0x00
.equ DAC_SWTRIGR,	0x04
.equ DAC_DHR12R1,	0x08
.equ DAC_DHR12L1,	0x0C
.equ DAC_DHR8R1,	0x10
.equ DAC_DHR12R2,	0x14
.equ DAC_DHR12L2,	0x18
.equ DAC_DHR8R2,	0x1C
.equ DAC_DHR12RD,	0x20
.equ DAC_DHR12LD,	0x24
.equ DAC_DHR8RD,	0x28
.equ DAC_DOR1,		0x2C
.equ DAC_DOR2,		0x30
.equ DAC_SR,		0x34

.equ SAI_ACR1,		0x04
.equ SAI_ACR2,		0x08
.equ SAI_AFRCR,		0x0C
.equ SAI_ASLOTR,	0x10
.equ SAI_AIM,		0x14
.equ SAI_ASR,		0x18
.equ SAI_ACLRFR,	0x1C
.equ SAI_ADR,		0x20

.equ SAI_BCR1,		0x24
.equ SAI_BCR2,		0x28
.equ SAI_BFRCR,		0x2C
.equ SAI_BSLOTR,	0x30
.equ SAI_BIM,		0x34
.equ SAI_BSR,		0x38
.equ SAI_BCLRFR,	0x3C
.equ SAI_BDR,		0x40

.equ DMA, 0x40026000

.equ DMA_LISR,		0x00
.equ DMA_HISR,		0x04
.equ DMA_LIFCR,		0x08
.equ DMA_HIFCR,		0x0C

.equ DMA_S0CR,		(0x10 + (0x18 * 0) + 0x00)
.equ DMA_S0NDTR,	(0x10 + (0x18 * 0) + 0x04)
.equ DMA_S0PAR,		(0x10 + (0x18 * 0) + 0x08)
.equ DMA_S0M0AR,	(0x10 + (0x18 * 0) + 0x0C)
.equ DMA_S0M1AR,	(0x10 + (0x18 * 0) + 0x10)
.equ DMA_S0FCR,		(0x10 + (0x18 * 0) + 0x14)

.equ DMA_S1CR,		(0x10 + (0x18 * 1) + 0x00)
.equ DMA_S1NDTR,	(0x10 + (0x18 * 1) + 0x04)
.equ DMA_S1PAR,		(0x10 + (0x18 * 1) + 0x08)
.equ DMA_S1M0AR,	(0x10 + (0x18 * 1) + 0x0C)
.equ DMA_S1M1AR,	(0x10 + (0x18 * 1) + 0x10)
.equ DMA_S1FCR,		(0x10 + (0x18 * 1) + 0x14)

.equ DMA_S2CR,		(0x10 + (0x18 * 2) + 0x00)
.equ DMA_S2NDTR,	(0x10 + (0x18 * 2) + 0x04)
.equ DMA_S2PAR,		(0x10 + (0x18 * 2) + 0x08)
.equ DMA_S2M0AR,	(0x10 + (0x18 * 2) + 0x0C)
.equ DMA_S2M1AR,	(0x10 + (0x18 * 2) + 0x10)
.equ DMA_S2FCR,		(0x10 + (0x18 * 2) + 0x14)

.equ DMA_S3CR,		(0x10 + (0x18 * 3) + 0x00)
.equ DMA_S3NDTR,	(0x10 + (0x18 * 3) + 0x04)
.equ DMA_S3PAR,		(0x10 + (0x18 * 3) + 0x08)
.equ DMA_S3M0AR,	(0x10 + (0x18 * 3) + 0x0C)
.equ DMA_S3M1AR,	(0x10 + (0x18 * 3) + 0x10)
.equ DMA_S3FCR,		(0x10 + (0x18 * 3) + 0x14)

.equ DMA_S4CR,		(0x10 + (0x18 * 4) + 0x00)
.equ DMA_S4NDTR,	(0x10 + (0x18 * 4) + 0x04)
.equ DMA_S4PAR,		(0x10 + (0x18 * 4) + 0x08)
.equ DMA_S4M0AR,	(0x10 + (0x18 * 4) + 0x0C)
.equ DMA_S4M1AR,	(0x10 + (0x18 * 4) + 0x10)
.equ DMA_S4FCR,		(0x10 + (0x18 * 4) + 0x14)

.equ DMA_S5CR,		(0x10 + (0x18 * 5) + 0x00)
.equ DMA_S5NDTR,	(0x10 + (0x18 * 5) + 0x04)
.equ DMA_S5PAR,		(0x10 + (0x18 * 5) + 0x08)
.equ DMA_S5M0AR,	(0x10 + (0x18 * 5) + 0x0C)
.equ DMA_S5M1AR,	(0x10 + (0x18 * 5) + 0x10)
.equ DMA_S5FCR,		(0x10 + (0x18 * 5) + 0x14)

.equ DMA_S6CR,		(0x10 + (0x18 * 6) + 0x00)
.equ DMA_S6NDTR,	(0x10 + (0x18 * 6) + 0x04)
.equ DMA_S6PAR,		(0x10 + (0x18 * 6) + 0x08)
.equ DMA_S6M0AR,	(0x10 + (0x18 * 6) + 0x0C)
.equ DMA_S6M1AR,	(0x10 + (0x18 * 6) + 0x10)
.equ DMA_S6FCR,		(0x10 + (0x18 * 6) + 0x14)

.equ DMA_S7CR,		(0x10 + (0x18 * 7) + 0x00)
.equ DMA_S7NDTR,	(0x10 + (0x18 * 7) + 0x04)
.equ DMA_S7PAR,		(0x10 + (0x18 * 7) + 0x08)
.equ DMA_S7M0AR,	(0x10 + (0x18 * 7) + 0x0C)
.equ DMA_S7M1AR,	(0x10 + (0x18 * 7) + 0x10)
.equ DMA_S7FCR,		(0x10 + (0x18 * 7) + 0x14)

.equ I2C1,		0x40005400
.equ I2C2,		0x40005800
.equ I2C3,		0x40005C00

.equ I2C_CR1,	0x00
.equ I2C_CR2,	0x04
.equ I2C_OAR1,	0x08
.equ I2C_OAR2,	0x0C
.equ I2C_DR,	0x10
.equ I2C_SR1,	0x14
.equ I2C_SR2,	0x18
.equ I2C_CCR,	0x1C
.equ I2C_TRISE,	0x20
.equ I2C_FLTR,	0x24
