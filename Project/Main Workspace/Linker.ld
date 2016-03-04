ENTRY(Reset_Handler)

MEMORY {
	ROM : ORIGIN = 0x08000000, LENGTH = 1024K
	RAM : ORIGIN = 0x20000000, LENGTH = 128K
}

_stack_end = 0x20000000 + (128 * 1024);

SECTIONS {

	.interrupt_vector : {
		KEEP(*(.interrupt_vector));
	} >ROM

	.text : {
		. = ALIGN(4);
		_text_beg = .;
		*(.text .text.*);
		*(.rodata .rodata.*);
		_text_end = .;
	} >ROM

	.data : {
		. = ALIGN(4);
		_data_beg = .;
		*(.data .data.*)
		. = ALIGN(4);
		_data_end = .;
	} >RAM AT >ROM

	.bss : {
		. = ALIGN(4);
		_bss_beg = .;
		*(.bss .bss.*);
		*(COMMON);
		. = ALIGN(4);
		_bss_end = .;
	} >RAM

}
