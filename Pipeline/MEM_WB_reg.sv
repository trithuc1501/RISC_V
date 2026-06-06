module MEM_WB_reg (
    input logic clk,
    input logic rst_n,

    input logic EN,
    input logic CLR,

    input logic [63:0] MEM_Read_data,
    input logic [63:0] MEM_ALU_result,
    input logic [4:0] MEM_Write_register,
    input logic [1:0] MEM_Control_signals, 

    output logic [63:0] WB_Read_data,
    output logic [63:0] WB_ALU_result,
    output logic [4:0] WB_Write_register,
    output logic [1:0] WB_Control_signals
);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            WB_Read_data <= '0;
            WB_ALU_result <= '0;
            WB_Write_register <= '0;
            WB_Control_signals <= '0;
            
        end else if (CLR) begin
            WB_Control_signals <= '0;
            
        end else if (EN) begin
            WB_Read_data <= MEM_Read_data;
            WB_ALU_result <= MEM_ALU_result;
            WB_Write_register <= MEM_Write_register;
            WB_Control_signals <= MEM_Control_signals;
        end
    end

endmodule