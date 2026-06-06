module PC (
    input logic clk,
    input logic rst_n,
    
    input logic EN,
    
    input logic Take_Branch,
    input logic [63:0] Next_Address,
    
    output logic [63:0] Address
);
    logic [63:0] Next_PC_internal;

    assign Next_PC_internal = Take_Branch ? Next_Address : (Address + 64'd4);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Address <= '0;
        end else if (EN) begin
            Address <= Next_PC_internal;
        end
    end
    
endmodule