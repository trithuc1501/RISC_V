package pkg;

    typedef enum logic [3:0] { 
        ALU_AND = 4'b0000,
        ALU_OR  = 4'b0001,
        ALU_ADD = 4'b0010,
        ALU_SUB = 4'b0110,
        ALU_SLT = 4'b0111,
        ALU_NOR = 4'b1100
    } ALU_e;

    typedef enum logic [6:0] {
        R_format = 7'b0110011,
        ld       = 7'b0000011,
        sd       = 7'b0100011,
        beq      = 7'b1100011
    } Opcode_e;

endpackage