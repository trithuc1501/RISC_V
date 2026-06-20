module EX_MEM_reg (
    input logic clk,
    input logic rst_n,

    input logic EN,
    input logic CLR,

    input logic [63:0] EX_ALU_result,
    input logic [63:0] EX_Store_Data,
    input logic [4:0] EX_Write_register,
    input logic [3:0] EX_Control_signals, 

    output logic [63:0] MEM_ALU_result,
    output logic [63:0] MEM_Write_data,
    output logic [4:0] MEM_Write_register,
    output logic [3:0] MEM_Control_signals
);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            MEM_ALU_result <= '0;
            MEM_Write_data <= '0;
            MEM_Write_register <= '0;
            MEM_Control_signals <= '0;
            
        end else if (CLR) begin
            MEM_Control_signals <= '0;
            
        end else if (EN) begin
            MEM_ALU_result <= EX_ALU_result;
            MEM_Write_data <= EX_Store_Data;
            MEM_Write_register <= EX_Write_register;
            MEM_Control_signals <= EX_Control_signals;
        end
    end

endmodule