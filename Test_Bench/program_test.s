.text
.global _start

_start:  
    
    0:  addi a0, zero, 64
    4:  addi a1, zero, 3
    8:  jal  ra, 16
    12: sd   a0, 0(zero)
    16: jal  zero, 0
    20: addi zero, zero, 0

    24: addi t0, zero, 0
    28: addi t1, zero, 0
    32: bge  t0, a1, 24
    36: ld   t2, 0(a0)
    40: add  t1, t1, t2
    44: addi a0, a0, 8
    48: addi t0, t0, 1
    52: jal  zero, -20
    56: add  a0, zero, t1
    60: jalr zero, 0(ra)