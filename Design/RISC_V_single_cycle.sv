import pkg::*;

`include "ALU_control.sv"
`include "ALU.sv"
`include "Control.sv"
`include "ImmGen.sv"
`include "PC.sv"
`include "Register.sv"
`include "IMEM.sv"
`include "DMEM.sv"
`include "Mux_WB.sv"

module RISC_V_single_cycle (
    input logic clk,
    input logic rst_n
);
    logic [63:0] Address;
    logic [31:0] Instruction;
    logic [10:0] Control_Signals;
    logic [63:0] ImmExt;

    logic [63:0] Read_data_1;
    logic [63:0] Read_data_2;
    logic [63:0] WriteBack_data;
    ALU_e ALUctl;

    logic [63:0] ALU_Result;
    logic Zero;
    logic Overflow;
    logic Sign;
    logic CarryOut;

    logic [63:0] Read_data;

    PC PC_top (
        .clk(clk),
        .rst_n(rst_n),
        .Zero(Zero),
        .Sign(Sign),
        .CarryOut(CarryOut),
        .Overflow(Overflow),
        .Jump(Control_Signals[9]),
        .JALSrc(Control_Signals[10]),
        .Branch(Control_Signals[2]),
        .Funct3(Instruction[14:12]),
        .Imm(ImmExt),
        .Pre_Address(Address),
        .ALU_Result(ALU_Result),
        .Address(Address)
    );

    IMEM IMEM_top (
        .Read_address(Address),
        .Instruction(Instruction)
    );

    Register Register_top (
        .clk(clk),

        .Read_register_1(Instruction[19:15]),
        .Read_register_2(Instruction[24:20]),
        .Write_register(Instruction[11:7]),
        .Write_data(WriteBack_data),
        .RegWrite(Control_Signals[5]),
        .Read_data_1(Read_data_1),
        .Read_data_2(Read_data_2)
    );

    Control Control_top (
        .Opcode(Instruction[6:0]),
        .Control_Signals(Control_Signals)
    );

    ImmGen ImmGen_top (
        .Instruction(Instruction),
        .ImmExt(ImmExt)
    );

    ALU_control ALU_control_top (
        .ALUOp(Control_Signals[1:0]),
        .Opcode5(Instruction[5]),
        .Funct7(Instruction[30]),
        .Funct3(Instruction[14:12]),
        .ALUctl(ALUctl)
    );

    ALU ALU_top (
        .SrcA(Read_data_1),
        .SrcB(Control_Signals[8] ? ImmExt : Read_data_2),
        .ALUctl(ALUctl),

        .Result(ALU_Result),
        .CarryOut(CarryOut),
        .Zero(Zero),
        .Overflow(Overflow),
        .Sign(Sign)
    );

    DMEM DMEM_top (
        .clk(clk),
        .Address(ALU_Result),
        .Write_data(Read_data_2),

        .MemWrite(Control_Signals[3]),
        .MemRead(Control_Signals[4]),

        .Read_data(Read_data)
    );

    Mux_WB Mux_WB_top (
        .In0(ALU_Result),
        .In1(Read_data),
        .In2(Address + 64'd4),
        .Sel(Control_Signals[7:6]),
        .Out(WriteBack_data)
    );

endmodule