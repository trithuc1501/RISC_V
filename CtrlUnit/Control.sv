import pkg::*;

module Control (
    input logic [6:0] Opcode,

    output logic [10:0] Control_Signals
);
    always_comb begin
        case (Opcode_e'(Opcode))
            // {JALSrc, Jump, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp[1:0]}
            // Bit mapping (MSB → LSB):
            // [10]    AUIPCSrc : 1 = PC, 0 = SrcA
            // [9]     JALSrc   : 1 = base là rs1 (JALR), 0 = base là PC (JAL)
            // [8]     Jump     : 1 = nhảy vô điều kiện
            // [7]     ALUSrc   : 1 = toán hạng B là immediate, 0 = rs2
            // [6]     MemtoReg : 0=ALU result, 1=data mem
            // [5]     RegWrite
            // [4]     MemRead
            // [3]     MemWrite
            // [2]     Branch
            // [1:0]     ALUOp[1:0]

            R_type, R_type_W : Control_Signals = 11'b0_0_0_0_0_1_0_0_0_10;
            I_type, I_type_W: Control_Signals = 11'b0_0_0_1_0_1_0_0_0_10;
            S_type : Control_Signals = 11'b0_0_0_1_0_0_0_1_0_00;
            B_type : Control_Signals = 11'b0_0_0_0_0_0_0_0_1_01;
            U_type : Control_Signals = 11'b0_0_0_1_0_1_0_0_0_11;
            J_type : Control_Signals = 11'b0_0_1_1_0_1_0_0_0_00;

            load   : Control_Signals = 11'b0_0_0_1_1_1_1_0_0_00;
            jalr : Control_Signals = 11'b0_1_1_1_0_1_0_0_0_00;
            auipc : Control_Signals = 11'b1_0_0_1_0_1_0_0_0_00;

            default  : Control_Signals = '0;
        endcase
    end
    
endmodule