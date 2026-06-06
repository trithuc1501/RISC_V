module IF_ID_reg (
    input logic clk,
    input logic rst_n,

    input logic EN,
    input logic CLR,

    input logic [63:0] IF_PC,
    input logic [31:0] IF_Instruction,

    output logic [63:0] ID_PC,
    output logic [31:0] ID_Instruction
);

    localparam NOP_Instruction = 32'h00000013; // addi x0, x0, 0
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ID_PC <= '0;
            ID_Instruction <= NOP_Instruction;

        end else if (CLR) begin
            ID_PC <= '0;
            ID_Instruction <= NOP_Instruction;
            
        end else if (EN) begin
            ID_PC <= IF_PC;
            ID_Instruction <= IF_Instruction;
        end
    end

endmodule