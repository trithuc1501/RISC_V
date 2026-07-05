// File: crt0.S
.section .text.init
.global _start

_start:
    li sp, 0x0001FFFF  
    
    call main          

end_loop:
    j end_loop