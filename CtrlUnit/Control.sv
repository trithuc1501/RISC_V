import pkg::*;

module Control (
    input logic [6:0] Opcode,

    output logic [10:0] Control_Signals
);
    always_comb begin
        case (Opcode_e'(Opcode))
            // {JALSrc, Jump, ALUSrc, MemtoReg[1:0], RegWrite, MemRead, MemWrite, Branch, ALUOp[1:0]}
            // Bit mapping (MSB → LSB):
            // [10]     JALSrc   : 1 = base là rs1 (JALR), 0 = base là PC (JAL)
            // [9]     Jump     : 1 = nhảy vô điều kiện
            // [8]     ALUSrc   : 1 = toán hạng B là immediate, 0 = rs2
            // [7:6]   MemtoReg : 00=ALU result, 01=data mem, 10=PC+4
            // [5]     RegWrite
            // [4]     MemRead
            // [3]     MemWrite
            // [2]     Branch
            // [1:0]     ALUOp[1:0]

            R_type, R_type_W : Control_Signals = 11'b0_0_0_00_1_0_0_0_10;
            I_type, I_type_W : Control_Signals = 11'b0_0_1_00_1_0_0_0_10;
            S_type : Control_Signals = 11'b0_0_1_00_0_0_1_0_00;
            B_type : Control_Signals = 11'b0_0_0_00_0_0_0_1_01;
            U_type : Control_Signals = 11'b0_0_1_00_1_0_0_0_11;
            J_type : Control_Signals = 11'b0_1_1_10_1_0_0_0_00;

            load   : Control_Signals = 11'b0_0_1_01_1_1_0_0_00;

            jalr : Control_Signals = 11'b1_1_1_10_1_0_0_0_00;
            
            default  : Control_Signals = '0;
        endcase
    end
    
endmodule