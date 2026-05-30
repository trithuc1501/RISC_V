import pkg::*;

module ALU_control (
    input logic [1:0] ALUOp,
    input logic Funct7,
    input logic [2:0] Funct3,

    output ALU_e ALUctl
);
    always_comb begin
        casez ({ALUOp, Funct7, Funct3})
            6'b00_?_???: ALUctl = ALU_ADD;
            6'b?1_?_???: ALUctl = ALU_SUB;
            6'b1?_0_000: ALUctl = ALU_ADD;
            6'b1?_1_000: ALUctl = ALU_SUB;
            6'b1?_0_111: ALUctl = ALU_AND;
            6'b1?_0_110: ALUctl = ALU_OR;
            default:     ALUctl = ALU_AND;
        endcase
    end

endmodule