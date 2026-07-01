import pkg::*;

module ALU (
    input logic [63:0] SrcA,
    input logic [63:0] SrcB,
    input ALU_e ALUctl,
    
    output logic [63:0] Result,
    output logic CarryOut,
    output logic Zero,
    output logic Overflow,
    output logic Sign
);


    always_comb begin
        CarryOut = '0;
        case (ALUctl)
            ALU_AND: Result = SrcA & SrcB;
            ALU_OR:  Result = SrcA | SrcB;
            ALU_ADD: {CarryOut, Result} = {1'b0, SrcA} + {1'b0, SrcB};
            ALU_XOR: Result = SrcA ^ SrcB;
            ALU_SUB: {CarryOut, Result} = {1'b0, SrcA} + {1'b0, (~SrcB)} + 65'd1;
            ALU_SLT: Result = ($signed(SrcA) < $signed(SrcB)) ? 64'd1 : 64'd0;
            //ALU_NOR: Result = {1'b0, ~(SrcA | SrcB)};
            ALU_SRL: Result = SrcA >> SrcB[5:0];
            ALU_SRA: Result = $signed(SrcA) >>> SrcB[5:0];
            ALU_SLL: Result = SrcA << SrcB[5:0];
            ALU_SLTU : Result = (SrcA < SrcB) ? 64'd1 : 64'd0;
            ALU_PASS_B : Result = SrcB;
            
            default: Result = '0;
        endcase
    end

    assign Zero = ~(|Result);
    assign Sign = Result[63];

    logic is_add, is_sub;
    assign is_add = (ALUctl == ALU_ADD);
    assign is_sub = (ALUctl == ALU_SUB);

    assign Overflow = (is_add & (SrcA[63] == SrcB[63]) & (SrcA[63] != Result[63])) |
                      (is_sub & (SrcA[63] != SrcB[63]) & (SrcA[63] != Result[63]));
    
endmodule