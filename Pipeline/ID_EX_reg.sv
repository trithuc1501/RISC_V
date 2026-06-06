module ID_EX_reg (
    input logic clk,
    input logic rst_n,

    input logic EN,
    input logic CLR,

    input logic [63:0] ID_PC,
    input logic [31:0] ID_Instruction,
    input logic [4:0] ID_Read_register_1,
    input logic [4:0] ID_Read_register_2,
    input logic [4:0] ID_Write_register,
    input logic [63:0] ID_Read_data_1,
    input logic [63:0] ID_Read_data_2,
    input logic [63:0] ID_ImmExt,
    input logic [9:0] ID_Control_signals,

    output logic [63:0] EX_PC,
    output logic [31:0] EX_Instruction,
    output logic [4:0] EX_Read_register_1,
    output logic [4:0] EX_Read_register_2,
    output logic [4:0] EX_Write_register,
    output logic [63:0] EX_Read_data_1,
    output logic [63:0] EX_Read_data_2,
    output logic [63:0] EX_ImmExt,
    output logic [9:0] EX_Control_signals
    
);

    localparam NOP_Instruction = 32'h00000013; // addi x0, x0, 0
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            EX_PC <= '0;
            EX_Instruction     <= NOP_Instruction;
            EX_Read_register_1 <= '0;
            EX_Read_register_2 <= '0;
            EX_Write_register <= '0;
            EX_Read_data_1 <= '0;
            EX_Read_data_2 <= '0;
            EX_ImmExt <= '0;
            EX_Control_signals <= '0;

        end else if (CLR) begin
            EX_Instruction     <= NOP_Instruction;
            EX_Control_signals <= '0;
            
        end else if (EN) begin
            EX_PC <= ID_PC;
            EX_Instruction     <= ID_Instruction;
            EX_Read_register_1 <= ID_Read_register_1;
            EX_Read_register_2 <= ID_Read_register_2;
            EX_Write_register <= ID_Write_register;
            EX_Read_data_1 <= ID_Read_data_1;
            EX_Read_data_2 <= ID_Read_data_2;
            EX_ImmExt <= ID_ImmExt;
            EX_Control_signals <= ID_Control_signals;
        end
    end

endmodule