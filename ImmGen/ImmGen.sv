import pkg::*;

module ImmGen (
    input logic [31:0] Instruction,
    output logic [63:0] ImmExt
);
    always_comb begin
        case (Opcode_e'(Instruction[6:0]))
            ld : ImmExt = {{52{Instruction[31]}}, Instruction[31:20]};
            sd : ImmExt = {{52{Instruction[31]}}, Instruction[31:25], Instruction[11:7]};
            beq: ImmExt = {{51{Instruction[31]}}, Instruction[31], Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
            default: ImmExt = 64'b0;
        endcase
    end
endmodule