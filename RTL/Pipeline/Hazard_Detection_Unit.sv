module Hazard_Detection_Unit (
    
    input logic [4:0] IF_ID_Rs1,
    input logic [4:0] IF_ID_Rs2,

    input logic ID_EX_MemRead,
    input logic [4:0] ID_EX_Rd,
    input logic Branch_Taken,

    output logic PC_EN,
    output logic IF_ID_EN,
    output logic IF_ID_CLR,
    output logic ID_EX_CLR
);

    always_comb begin

        PC_EN     = 1'b1;
        IF_ID_EN  = 1'b1;
        IF_ID_CLR = 1'b0;
        ID_EX_CLR = 1'b0;
        
        if (Branch_Taken) begin
            IF_ID_CLR = 1'b1;
            ID_EX_CLR = 1'b1;   
        end 
        else if (ID_EX_MemRead && (ID_EX_Rd != 5'b00000) && ((ID_EX_Rd == IF_ID_Rs1) || (ID_EX_Rd == IF_ID_Rs2))) begin
            PC_EN     = 1'b0;
            IF_ID_EN  = 1'b0;
            ID_EX_CLR = 1'b1;
        end
    end

endmodule