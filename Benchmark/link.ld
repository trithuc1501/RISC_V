OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
  IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 64K
  DMEM (rw) : ORIGIN = 0x00010000, LENGTH = 64K
}

SECTIONS
{
  .text : {
    *(.text.init) 
    *(.text*)     
  } > IMEM

  .rodata : {
    *(.rodata*)   
  } > DMEM

  .data : {
    *(.data*)     
  } > DMEM

  .bss : {
    *(.bss*)     
  } > DMEM
}