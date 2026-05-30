module Register (
    input logic clk,
    input logic rst_n,
    input logic [4:0] Read_register_1,
    input logic [4:0] Read_register_2,
    input logic [4:0] Write_register,
    input logic [63:0] Write_data,
    input logic RegWrite,

    output logic [63:0] Read_data_1,
    output logic [63:0] Read_data_2        
);
    logic [63:0] Register [31:0]; 

    assign Read_data_1 = (Read_register_1 == '0) ? '0 : Register[Read_register_1];
    assign Read_data_2 = (Read_register_2 == '0) ? '0 : Register[Read_register_2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                Register[i] <= '0;
            end
        end elseif (RegWrite || (Write_register != '0)) begin
            Register[Write_register] <= Write_data;
        end
    end
endmodule