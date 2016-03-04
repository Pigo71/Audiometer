MEMORY {
	SAMPLES : ORIGIN = 0x08010000, LENGTH = 64K
}

SECTIONS {

	.rodata : {
		*(.rodata .rodata.*);
	} >SAMPLES

}
