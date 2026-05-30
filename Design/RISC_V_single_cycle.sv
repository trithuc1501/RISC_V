import pkg::*;

module RISC_V_single_cycle (
    input logic clk,
    input logic rst_n
);
    logic [63:0] Address;
    logic [31:0] Instruction;
    logic [7:0] Control_Signals;
    logic [63:0] ImmExt;

    logic [63:0] Read_data_1;
    logic [63:0] Read_data_2;
    ALU_e ALUctl;

    logic [63:0] Result;
    logic Zero;
    logic Overflow;
    logic CarryOut;

    logic [63:0] Read_data;

    PC PC_top (
        .clk(clk),
        .rst_n(rst_n),
        .Zero(Zero),
        .Branch(Control_Signals[2]),
        .Imm(ImmExt),
        .Address(Address)
    );

    IMEM IMEM_top (
        .Read_address(Address),
        .Instruction(Instruction)
    );

    Register Register_top (
        .clk(clk),
        .rst_n(rst_n),

        .Read_register_1(Instruction[19:15]),
        .Read_register_2(Instruction[24:20]),
        .Write_register(Instruction[11:7]),
        .Write_data(Control_Signals[6] ? Read_data : Result),
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
        .Funct7(Instruction[30]),
        .Funct3(Instruction[14:12]),
        .ALUctl(ALUctl)
    );

    ALU ALU_top (
        .A(Read_data_1),
        .B(Control_Signals[7] ? ImmExt : Read_data_2),
        .ALUctl(ALUctl),

        .Result(Result),
        .CarryOut(CarryOut),
        .Zero(Zero),
        .Overflow(Overflow)
    );

    DMEM DMEM_top (
        .clk(clk),
        .Address(Result),
        .Write_data(Read_data_2),

        .MemWrite(Control_Signals[3]),
        .MemRead(Control_Signals[4]),

        .Read_data(Read_data)
    );


    
endmodule