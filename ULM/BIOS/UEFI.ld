OUTPUT_FORMAT(elf32-i386)
ENTRY(_entry)
SECTIONS
{
	.text : { *(.text) }
	.data : { *(.data) }
	.bss  : { *(.bss)  }
}
