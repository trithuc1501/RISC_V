module Mux_WB #(
    parameter WIDTH = 64
)(
    input  logic [WIDTH-1:0] In0,
    input  logic [WIDTH-1:0] In1,
    input  logic [WIDTH-1:0] In2,
    input  logic [1:0]       Sel,
    
    output logic [WIDTH-1:0] Out
);

    always_comb begin
        case (Sel)
            2'b00:   Out = In0;
            2'b01:   Out = In1;
            2'b10:   Out = In2;
            default: Out = In0;
        endcase
    end

endmodule