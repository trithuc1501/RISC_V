module MUX_2_1 #(
    parameter WIDTH = 64
)(
    input logic [WIDTH-1:0] In0,
    input logic [WIDTH-1:0] In1,
    input logic Sel,
    
    output logic [WIDTH-1:0] Out
);

    always_comb begin
        case (Sel)
            1'b0:   Out = In0;
            1'b1:   Out = In1;
            default: Out = In0;
        endcase
    end

endmodule