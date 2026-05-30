import pkg::*;

module Control (
    input logic [6:0] Opcode,

    output logic [7:0] Control_Signals
);
    always_comb begin
        case (Opcode)
            R_format : Control_Signals = 8'b00100010;
            ld       : Control_Signals = 8'b11110000;
            sd       : Control_Signals = 8'b1x001000;
            beq      : Control_Signals = 8'b0x000101;
            default  : Control_Signals = '0;
        endcase
    end
    
endmodule