module Branch_Target_Buffer #(
    parameter BTB_ENTRIES = 16 
)(
    input logic clk,
    input logic rst_n,

    input logic [63:0] IF_PC,
    output logic [63:0] Predicted_Target,
    output logic BTB_Hit,

    input logic EX_Update_Enable,
    input logic [63:0] EX_PC,
    input logic [63:0] EX_Target_Address
);
    
    logic Valid_Array [0:BTB_ENTRIES-1];
    logic [63:0] Tag_Array [0:BTB_ENTRIES-1];
    logic [63:0] Target_Array [0:BTB_ENTRIES-1];

    logic [3:0] Read_Index;
    assign Read_Index = IF_PC[5:2];

    always_comb begin
        BTB_Hit = 1'b0;
        Predicted_Target = 64'd0;

        if (Valid_Array[Read_Index] == 1'b1 && Tag_Array[Read_Index] == IF_PC) begin
            BTB_Hit = 1'b1;
            Predicted_Target = Target_Array[Read_Index];
        end
    end

    logic [3:0] Write_Index;
    assign Write_Index = EX_PC[5:2];

    integer i;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < BTB_ENTRIES; i = i + 1) begin
                Valid_Array[i] <= 1'b0;
                Tag_Array[i] <= 64'd0;
                Target_Array[i] <= 64'd0;
            end
        end 
        else if (EX_Update_Enable) begin
            Valid_Array[Write_Index] <= 1'b1;
            Tag_Array[Write_Index] <= EX_PC;
            Target_Array[Write_Index] <= EX_Target_Address;
        end
    end

endmodule