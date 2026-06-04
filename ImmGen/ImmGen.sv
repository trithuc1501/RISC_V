import pkg::*;

module ImmGen (
    input logic [31:0] Instruction,
    output logic [63:0] ImmExt
);
    always_comb begin

        case (Opcode_e'(Instruction[6:0]))
            I_type, load, jalr, I_type_W : ImmExt = {{52{Instruction[31]}}, Instruction[31:20]};
            S_type : ImmExt = {{52{Instruction[31]}}, Instruction[31:25], Instruction[11:7]};
            B_type : ImmExt = {{51{Instruction[31]}}, Instruction[31], Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
            U_type, auipc : ImmExt = {{32{Instruction[31]}}, Instruction[31:12], 12'b0};
            J_type : ImmExt = {{43{Instruction[31]}}, Instruction[31], Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};

            default: ImmExt = 64'b0;
        endcase
    end
    
endmodule