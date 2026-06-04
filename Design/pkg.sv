package pkg;

    typedef enum logic [2:0] {
        beq = 3'b000,
        bne = 3'b001,
        blt = 3'b100,
        bge = 3'b101,
        bltu = 3'b110,
        bgeu = 3'b111,
    } Function_3_B_type_e;

    typedef enum logic [3:0] { 
        ALU_AND = 4'b0000, // a & b
        ALU_OR  = 4'b0001, // a | b
        ALU_ADD = 4'b0010, // a + b
        ALU_XOR = 4'b0011, // a ^ b
        ALU_SUB = 4'b0110, // a + ~b + 1
        ALU_SLT = 4'b0111, // a + ~b + 1 => bit MSB 
        ALU_SLTU = 4'b1000, // sltu
        //ALU_NOR = 4'b1100, // ~(a | b) = ~a & ~b
        ALU_SRL = 4'b0100, // a >> b 
        ALU_SRA = 4'b0101, // a >>> b 
        ALU_SLL = 4'b1101, // a << b 
        ALU_PASS_B = 4'b1111    // pass b
    } ALU_e;

    typedef enum logic [6:0] {
        R_type = 7'b0110011, //add, sub, sll, slt, sltu, xor, srl, sra, or, and
        I_type = 7'b0010011, //addi, slti, sltiu, xori, ori, andi, slli, srli, srai, 
        S_type = 7'b0100011, //sb, sh, sw
        B_type = 7'b1100011, //beq, bne, blt, bge, bltu, bgeu
        U_type = 7'b0110111, //lui
        J_type = 7'b1101111, //jal

        auipc  = 7'b0010111,
        jalr   = 7'b1100111,
        load   = 7'b0000011, //lb, lh, lw, lbu, lhu, lwu, ld

        R_type_W = 7'b0111011, //addw, subw, sllw, srlw, sraw
        I_type_W = 7'b0011011  //addiw, slliw, srliw, sraiw
    } Opcode_e;

endpackage