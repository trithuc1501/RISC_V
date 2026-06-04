import pkg::*;

module ALU_control (
    input logic [1:0] ALUOp,
    input logic Opcode5,
    input logic Funct7,
    input logic [2:0] Funct3,

    output ALU_e ALUctl
);
    always_comb begin
        casez ({ALUOp, Opcode5, Funct7, Funct3})

            7'b11_?_?_??? : ALUctl = ALU_PASS_B; //u_type
            7'b00_?_?_??? : ALUctl = ALU_ADD;    //j_type, load, store, jalr
            7'b01_?_?_??? : ALUctl = ALU_SUB;    //b_type

            7'b10_0_?_000 : ALUctl = ALU_ADD; //addi, addiw
            7'b10_1_0_000 : ALUctl = ALU_ADD; //add, addw
            7'b10_1_1_000 : ALUctl = ALU_SUB; //sub, subw

            7'b10_?_?_111 : ALUctl = ALU_AND; //and, andi
            7'b10_?_?_110 : ALUctl = ALU_OR;  //or, ori
            7'b10_?_?_100 : ALUctl = ALU_XOR; //xor, xori
            7'b10_?_?_011 : ALUctl = ALU_SLTU;  //sltu, sltui
            7'b10_?_?_010 : ALUctl = ALU_SLT;   //slt, slti

            7'b10_?_?_001 : ALUctl = ALU_SLL; //sll, slli, sllw, slliw
            7'b10_?_0_101 : ALUctl = ALU_SRL; //srl, srli, srlw, srliw
            7'b10_?_1_101 : ALUctl = ALU_SRA; //sra, srai, sraw, sraiw

            default:     ALUctl = ALU_AND;
        endcase
    end

endmodule