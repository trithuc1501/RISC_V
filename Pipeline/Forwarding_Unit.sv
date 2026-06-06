module Forwarding_Unit (
    input logic [4:0] ID_EX_Rs1,
    input logic [4:0] ID_EX_Rs2,
    input logic [4:0] EX_MEM_Rd,
    input logic [4:0] MEM_WB_Rd,

    input logic EX_MEM_RegWrite,
    input logic MEM_WB_RegWrite,

    output logic [1:0] ForwardA,
    output logic [1:0] ForwardB
);

    always_comb begin
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'b00000) && (EX_MEM_Rd == ID_EX_Rs1)) begin
            ForwardA = 2'b10;
        end 
        else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'b00000) && (MEM_WB_Rd == ID_EX_Rs1)) begin
            ForwardA = 2'b01;
        end 
        else begin
            ForwardA = 2'b00;
        end

        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'b00000) && (EX_MEM_Rd == ID_EX_Rs2)) begin
            ForwardB = 2'b10;
        end 
        else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'b00000) && (MEM_WB_Rd == ID_EX_Rs2)) begin
            ForwardB = 2'b01;
        end 
        else begin
            ForwardB = 2'b00;
        end
    end

endmodule