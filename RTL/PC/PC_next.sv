import pkg::*;

module PC_next (
    input logic Zero,
    input logic Sign,
    input logic CarryOut,
    input logic Overflow,

    input logic Branch,
    input logic Jump,
    input logic JALSrc,
    input [2:0] Funct3,

    input logic [63:0] Imm,
    input logic [63:0] Pre_Address,
    input logic [63:0] ALU_Result,

    output logic [63:0] Next_Address,
    output logic Take_Branch
);

    // PC + 4; Branch = 0, Jump = 0, JALSrc = 0
    // PC + imm; Branch = 1, Jump = 0, JALSrc = 0 or Branch = 0, Jump = 1, JALSrc = 0 
    // rs + imm; Branch = 0, Jump = 1, JALSrc = 1
    
    // Branch: beq (Zero)
    //         bne (~Zero)
    //         blt (Sign ^ Overflow)
    //         bge ~(Sign ^ Overflow)
    //         bltu (CarryOut)
    //         bgeu ~(CarryOut)

    logic Condition_Met;

    always_comb begin
        case (Function_3_B_type_e'(Funct3))
            beq : Condition_Met = Zero;
            bne : Condition_Met = ~Zero;
            blt : Condition_Met = Sign ^ Overflow;
            bge : Condition_Met = ~(Sign ^ Overflow);
            bltu: Condition_Met = CarryOut;
            bgeu: Condition_Met = ~CarryOut;

            default: Condition_Met = 1'b0;
        endcase
    end

    assign Take_Branch = (Branch & Condition_Met) | Jump;


    always_comb begin
        if (Jump & JALSrc) begin
            Next_Address = {ALU_Result[63:1], 1'b0};
        end else begin
            Next_Address = Pre_Address + Imm;   
        end 
    end
    
endmodule