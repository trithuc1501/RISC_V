import pkg::*;

module ALU (
    input logic [63:0] A,
    input logic [63:0] B,
    input ALU_e ALUctl,
    
    output logic [63:0] Result,
    output logic CarryOut,
    output logic Zero,
    output logic Overflow
);


    always_comb begin
        case (ALUctl)
            ALU_AND: {CarryOut, Result} = {1'b0, A & B};
            ALU_OR:  {CarryOut, Result} = {1'b0, A | B};
            ALU_ADD: {CarryOut, Result} = {1'b0, A} + {1'b0, B};
            ALU_SUB: {CarryOut, Result} = {1'b0, A} - {1'b0, B};
            ALU_SLT: {CarryOut, Result} = ($signed(A) < $signed(B)) ? 65'd1 : 65'd0;
            ALU_NOR: {CarryOut, Result} = {1'b0, ~(A | B)};
            default: {CarryOut, Result} = '0;
        endcase
    end

    assign Zero = ~(|Result);

    logic is_add, is_sub;
    assign is_add = (ALUctl == ALU_ADD);
    assign is_sub = (ALUctl == ALU_SUB);

    assign Overflow = (is_add & (A[63] == B[63]) & (A[63] != Result[63])) |
                      (is_sub & (A[63] != B[63]) & (A[63] != Result[63]));
    
endmodule