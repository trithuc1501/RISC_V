module PC (
    input logic clk,
    input logic rst_n,
    input logic Zero,
    input logic Branch,
    input logic [63:0] Imm,

    output logic [63:0] Address
);

    logic [63:0] NextAddress;

    always_comb begin
        case (Branch & Zero) 
            1'b0 : NextAddress = Address + 4; 
            1'b1 : NextAddress = Imm + Address;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            Address <= '0;
        end else begin
            Address <= NextAddress;
        end
    end

endmodule