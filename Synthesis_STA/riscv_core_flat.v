module ALU_control (
	ALUOp,
	Opcode5,
	Funct7,
	Funct3,
	ALUctl
);
	input wire [1:0] ALUOp;
	input wire Opcode5;
	input wire Funct7;
	input wire [2:0] Funct3;
	output reg [3:0] ALUctl;
	always @(*)
		casez ({ALUOp, Opcode5, Funct7, Funct3})
			7'b11zzzzz: ALUctl = 4'b1111;
			7'b00zzzzz: ALUctl = 4'b0010;
			7'b01zzzzz: ALUctl = 4'b0110;
			7'b100z000: ALUctl = 4'b0010;
			7'b1010000: ALUctl = 4'b0010;
			7'b1011000: ALUctl = 4'b0110;
			7'b10zz111: ALUctl = 4'b0000;
			7'b10zz110: ALUctl = 4'b0001;
			7'b10zz100: ALUctl = 4'b0011;
			7'b10zz011: ALUctl = 4'b1000;
			7'b10zz010: ALUctl = 4'b0111;
			7'b10zz001: ALUctl = 4'b1101;
			7'b10z0101: ALUctl = 4'b0100;
			7'b10z1101: ALUctl = 4'b0101;
			default: ALUctl = 4'b0000;
		endcase
endmodule
module ALU (
	SrcA,
	SrcB,
	ALUctl,
	Result,
	CarryOut,
	Zero,
	Overflow,
	Sign
);
	input wire [63:0] SrcA;
	input wire [63:0] SrcB;
	input wire [3:0] ALUctl;
	output reg [63:0] Result;
	output reg CarryOut;
	output wire Zero;
	output wire Overflow;
	output wire Sign;
	always @(*) begin
		CarryOut = 1'sb0;
		case (ALUctl)
			4'b0000: Result = SrcA & SrcB;
			4'b0001: Result = SrcA | SrcB;
			4'b0010: {CarryOut, Result} = {1'b0, SrcA} + {1'b0, SrcB};
			4'b0011: Result = SrcA ^ SrcB;
			4'b0110: {CarryOut, Result} = ({1'b0, SrcA} + {1'b0, ~SrcB}) + 65'd1;
			4'b0111: Result = ($signed(SrcA) < $signed(SrcB) ? 64'd1 : 64'd0);
			4'b0100: Result = SrcA >> SrcB[5:0];
			4'b0101: Result = $signed(SrcA) >>> SrcB[5:0];
			4'b1101: Result = SrcA << SrcB[5:0];
			4'b1000: Result = (SrcA < SrcB ? 64'd1 : 64'd0);
			4'b1111: Result = SrcB;
			default: Result = 1'sb0;
		endcase
	end
	assign Zero = ~(|Result);
	assign Sign = Result[63];
	wire is_add;
	wire is_sub;
	assign is_add = ALUctl == 4'b0010;
	assign is_sub = ALUctl == 4'b0110;
	assign Overflow = ((is_add & (SrcA[63] == SrcB[63])) & (SrcA[63] != Result[63])) | ((is_sub & (SrcA[63] != SrcB[63])) & (SrcA[63] != Result[63]));
endmodule
module Branch_Target_Buffer (
	clk,
	rst_n,
	IF_PC,
	Predicted_Target,
	BTB_Hit,
	EX_Update_Enable,
	EX_Update_Valid,
	EX_PC,
	EX_Target_Address
);
	parameter BTB_ENTRIES = 16;
	input wire clk;
	input wire rst_n;
	input wire [63:0] IF_PC;
	output reg [63:0] Predicted_Target;
	output reg BTB_Hit;
	input wire EX_Update_Enable;
	input wire EX_Update_Valid;
	input wire [63:0] EX_PC;
	input wire [63:0] EX_Target_Address;
	reg Valid_Array [0:BTB_ENTRIES - 1];
	reg [63:0] Tag_Array [0:BTB_ENTRIES - 1];
	reg [63:0] Target_Array [0:BTB_ENTRIES - 1];
	wire [3:0] Read_Index;
	assign Read_Index = IF_PC[5:2];
	always @(*) begin
		BTB_Hit = 1'b0;
		Predicted_Target = 64'd0;
		if ((Valid_Array[Read_Index] == 1'b1) && (Tag_Array[Read_Index] == IF_PC)) begin
			BTB_Hit = 1'b1;
			Predicted_Target = Target_Array[Read_Index];
		end
	end
	wire [3:0] Write_Index;
	assign Write_Index = EX_PC[5:2];
	integer i;
	always @(posedge clk or negedge rst_n)
		if (!rst_n)
			for (i = 0; i < BTB_ENTRIES; i = i + 1)
				begin
					Valid_Array[i] <= 1'b0;
					Tag_Array[i] <= 64'd0;
					Target_Array[i] <= 64'd0;
				end
		else if (EX_Update_Enable) begin
			Valid_Array[Write_Index] <= EX_Update_Valid;
			if (EX_Update_Valid) begin
				Tag_Array[Write_Index] <= EX_PC;
				Target_Array[Write_Index] <= EX_Target_Address;
			end
		end
endmodule
module Control (
	Opcode,
	Control_Signals
);
	input wire [6:0] Opcode;
	output reg [10:0] Control_Signals;
	always @(*)
		case (Opcode)
			7'b0110011, 7'b0111011: Control_Signals = 11'b00000100010;
			7'b0010011, 7'b0011011: Control_Signals = 11'b00010100010;
			7'b0100011: Control_Signals = 11'b00010001000;
			7'b1100011: Control_Signals = 11'b00000000101;
			7'b0110111: Control_Signals = 11'b00010100011;
			7'b1101111: Control_Signals = 11'b00110100000;
			7'b0000011: Control_Signals = 11'b00011110000;
			7'b1100111: Control_Signals = 11'b01110100000;
			7'b0010111: Control_Signals = 11'b10010100000;
			default: Control_Signals = 1'sb0;
		endcase
endmodule
module RISC_V_pipe_line (
	clk,
	rst_n,
	res
);
	input clk;
	input rst_n;
	output wire [63:0] res;
	wire [63:0] EX_PC;
	assign res = EX_PC;
	wire [63:0] IF_PC;
	wire [31:0] IF_Instruction;
	wire [63:0] IF_Predicted_Target;
	wire IF_BTB_Hit;
	wire [63:0] ID_PC;
	wire [31:0] ID_Instruction;
	wire [4:0] ID_Read_register_1;
	wire [4:0] ID_Read_register_2;
	wire [4:0] ID_Write_register;
	wire [63:0] ID_Read_data_1;
	wire [63:0] ID_Read_data_2;
	wire [63:0] ID_ImmExt;
	wire [10:0] ID_Control_signals;
	wire [2:0] ID_MemSize;
	wire [31:0] EX_Instruction;
	wire [4:0] EX_Read_register_1;
	wire [4:0] EX_Read_register_2;
	wire [4:0] EX_Write_register;
	wire [63:0] EX_Read_data_1;
	wire [63:0] EX_Read_data_2;
	wire [63:0] EX_ImmExt;
	wire [10:0] EX_Control_signals;
	wire [63:0] EX_ALU_result;
	wire [63:0] EX_Data_To_MEM;
	wire EX_Mispredicted;
	wire EX_BTB_Update_EN;
	wire [2:0] EX_MemSize;
	wire [63:0] MEM_ALU_result;
	wire [63:0] MEM_Write_data;
	wire [63:0] MEM_Read_data;
	wire [4:0] MEM_Write_register;
	wire [3:0] MEM_Control_signals;
	wire [2:0] MEM_MemSize;
	wire [63:0] WB_Read_data;
	wire [63:0] WB_ALU_result;
	wire [4:0] WB_Write_register;
	wire [1:0] WB_Control_signals;
	wire [1:0] ForwardA;
	wire [1:0] ForwardB;
	wire PC_EN;
	wire IF_ID_EN;
	wire IF_ID_CLR;
	wire ID_EX_CLR;
	wire Branch_Taken;
	wire [63:0] Target_Address;
	wire [3:0] ALUctl;
	wire CarryOut;
	wire Zero;
	wire Overflow;
	wire Sign;
	wire [63:0] WriteBack_data;
	reg [63:0] Forwarded_A;
	wire [63:0] ALU_SrcA;
	reg [63:0] Forwarded_B;
	reg Final_Take_Branch;
	reg [63:0] Final_Next_Address;
	wire [63:0] Actual_Next_PC;
	always @(*)
		if (EX_Mispredicted) begin
			Final_Take_Branch = 1'b1;
			Final_Next_Address = Actual_Next_PC;
		end
		else if (IF_BTB_Hit) begin
			Final_Take_Branch = 1'b1;
			Final_Next_Address = IF_Predicted_Target;
		end
		else begin
			Final_Take_Branch = 1'b0;
			Final_Next_Address = 64'd0;
		end
	assign Actual_Next_PC = (Branch_Taken ? Target_Address : EX_PC + 64'd4);
	assign EX_Mispredicted = (EX_Control_signals[2] || EX_Control_signals[8]) && (ID_PC != Actual_Next_PC);
	PC PC_top(
		.clk(clk),
		.rst_n(rst_n),
		.EN(PC_EN),
		.Take_Branch(Final_Take_Branch),
		.Next_Address(Final_Next_Address),
		.Address(IF_PC)
	);
	Branch_Target_Buffer u_BTB(
		.clk(clk),
		.rst_n(rst_n),
		.IF_PC(IF_PC),
		.Predicted_Target(IF_Predicted_Target),
		.BTB_Hit(IF_BTB_Hit),
		.EX_Update_Enable(EX_BTB_Update_EN),
		.EX_Update_Valid(Branch_Taken),
		.EX_PC(EX_PC),
		.EX_Target_Address(Target_Address)
	);
	assign EX_BTB_Update_EN = EX_Control_signals[2] || EX_Control_signals[8];
	IMEM IMEM_top(
		.Read_address(IF_PC),
		.Instruction(IF_Instruction)
	);
	IF_ID_reg IF_ID_reg_top(
		.clk(clk),
		.rst_n(rst_n),
		.EN(IF_ID_EN),
		.CLR(IF_ID_CLR),
		.IF_PC(IF_PC),
		.IF_Instruction(IF_Instruction),
		.ID_PC(ID_PC),
		.ID_Instruction(ID_Instruction)
	);
	assign ID_Read_register_1 = ID_Instruction[19:15];
	assign ID_Read_register_2 = ID_Instruction[24:20];
	assign ID_Write_register = ID_Instruction[11:7];
	assign ID_MemSize = ID_Instruction[14:12];
	Register Register_top(
		.clk(clk),
		.Read_register_1(ID_Read_register_1),
		.Read_register_2(ID_Read_register_2),
		.Write_register(WB_Write_register),
		.Write_data(WriteBack_data),
		.RegWrite(WB_Control_signals[0]),
		.Read_data_1(ID_Read_data_1),
		.Read_data_2(ID_Read_data_2)
	);
	ImmGen ImmGen_top(
		.Instruction(ID_Instruction),
		.ImmExt(ID_ImmExt)
	);
	Control Control_top(
		.Opcode(ID_Instruction[6:0]),
		.Control_Signals(ID_Control_signals)
	);
	ID_EX_reg ID_EX_reg_top(
		.clk(clk),
		.rst_n(rst_n),
		.EN(1'b1),
		.CLR(ID_EX_CLR),
		.ID_PC(ID_PC),
		.ID_Instruction(ID_Instruction),
		.ID_Read_register_1(ID_Read_register_1),
		.ID_Read_register_2(ID_Read_register_2),
		.ID_Write_register(ID_Write_register),
		.ID_Read_data_1(ID_Read_data_1),
		.ID_Read_data_2(ID_Read_data_2),
		.ID_ImmExt(ID_ImmExt),
		.ID_Control_signals(ID_Control_signals),
		.ID_MemSize(ID_MemSize),
		.EX_PC(EX_PC),
		.EX_Instruction(EX_Instruction),
		.EX_Read_register_1(EX_Read_register_1),
		.EX_Read_register_2(EX_Read_register_2),
		.EX_Write_register(EX_Write_register),
		.EX_Read_data_1(EX_Read_data_1),
		.EX_Read_data_2(EX_Read_data_2),
		.EX_ImmExt(EX_ImmExt),
		.EX_Control_signals(EX_Control_signals),
		.EX_MemSize(EX_MemSize)
	);
	always @(*)
		if (ForwardA == 2'b10)
			Forwarded_A = MEM_ALU_result;
		else if (ForwardA == 2'b01)
			Forwarded_A = WriteBack_data;
		else
			Forwarded_A = EX_Read_data_1;
	MUX_2_1 MUX_2_1_top(
		.In0(Forwarded_A),
		.In1(EX_PC),
		.Sel(EX_Control_signals[10]),
		.Out(ALU_SrcA)
	);
	always @(*)
		if (ForwardB == 2'b10)
			Forwarded_B = MEM_ALU_result;
		else if (ForwardB == 2'b01)
			Forwarded_B = WriteBack_data;
		else
			Forwarded_B = EX_Read_data_2;
	ALU_control ALU_control_top(
		.ALUOp(EX_Control_signals[1:0]),
		.Opcode5(EX_Instruction[5]),
		.Funct7(EX_Instruction[30]),
		.Funct3(EX_Instruction[14:12]),
		.ALUctl(ALUctl)
	);
	ALU ALU_top(
		.SrcA(ALU_SrcA),
		.SrcB((EX_Control_signals[7] ? EX_ImmExt : Forwarded_B)),
		.ALUctl(ALUctl),
		.Result(EX_ALU_result),
		.CarryOut(CarryOut),
		.Zero(Zero),
		.Overflow(Overflow),
		.Sign(Sign)
	);
	PC_next Pc_next_top(
		.Zero(Zero),
		.Sign(Sign),
		.CarryOut(CarryOut),
		.Overflow(Overflow),
		.Branch(EX_Control_signals[2]),
		.Jump(EX_Control_signals[8]),
		.JALSrc(EX_Control_signals[9]),
		.Funct3(EX_Instruction[14:12]),
		.Imm(EX_ImmExt),
		.Pre_Address(EX_PC),
		.ALU_Result(EX_ALU_result),
		.Next_Address(Target_Address),
		.Take_Branch(Branch_Taken)
	);
	assign EX_Data_To_MEM = (EX_Control_signals[8] ? EX_PC + 64'd4 : EX_ALU_result);
	EX_MEM_reg EX_MEM_reg_top(
		.clk(clk),
		.rst_n(rst_n),
		.EN(1'b1),
		.CLR(1'b0),
		.EX_ALU_result(EX_Data_To_MEM),
		.EX_Store_Data(Forwarded_B),
		.EX_Write_register(EX_Write_register),
		.EX_Control_signals(EX_Control_signals[6:3]),
		.EX_MemSize(EX_MemSize),
		.MEM_ALU_result(MEM_ALU_result),
		.MEM_Write_data(MEM_Write_data),
		.MEM_Write_register(MEM_Write_register),
		.MEM_Control_signals(MEM_Control_signals),
		.MEM_MemSize(MEM_MemSize)
	);
	DMEM DMEM_top(
		.clk(clk),
		.Address(MEM_ALU_result),
		.Write_data(MEM_Write_data),
		.MemWrite(MEM_Control_signals[0]),
		.MemRead(MEM_Control_signals[1]),
		.MemSize(MEM_MemSize),
		.Read_data(MEM_Read_data)
	);
	MEM_WB_reg MEM_WB_reg_top(
		.clk(clk),
		.rst_n(rst_n),
		.EN(1'b1),
		.CLR(1'b0),
		.MEM_Read_data(MEM_Read_data),
		.MEM_ALU_result(MEM_ALU_result),
		.MEM_Write_register(MEM_Write_register),
		.MEM_Control_signals(MEM_Control_signals[3:2]),
		.WB_Read_data(WB_Read_data),
		.WB_ALU_result(WB_ALU_result),
		.WB_Write_register(WB_Write_register),
		.WB_Control_signals(WB_Control_signals)
	);
	assign WriteBack_data = (WB_Control_signals[1] ? WB_Read_data : WB_ALU_result);
	Hazard_Detection_Unit Hazard_Detection_Unit_top(
		.IF_ID_Rs1(ID_Read_register_1),
		.IF_ID_Rs2(ID_Read_register_2),
		.ID_EX_MemRead(EX_Control_signals[4]),
		.ID_EX_Rd(EX_Write_register),
		.Branch_Taken(EX_Mispredicted),
		.PC_EN(PC_EN),
		.IF_ID_EN(IF_ID_EN),
		.IF_ID_CLR(IF_ID_CLR),
		.ID_EX_CLR(ID_EX_CLR)
	);
	Forwarding_Unit Forwarding_Unit_top(
		.ID_EX_Rs1(EX_Read_register_1),
		.ID_EX_Rs2(EX_Read_register_2),
		.EX_MEM_Rd(MEM_Write_register),
		.MEM_WB_Rd(WB_Write_register),
		.EX_MEM_RegWrite(MEM_Control_signals[2]),
		.MEM_WB_RegWrite(WB_Control_signals[0]),
		.ForwardA(ForwardA),
		.ForwardB(ForwardB)
	);
endmodule
module ImmGen (
	Instruction,
	ImmExt
);
	input wire [31:0] Instruction;
	output reg [63:0] ImmExt;
	always @(*)
		case (Instruction[6:0])
			7'b0010011, 7'b0000011, 7'b1100111, 7'b0011011: ImmExt = {{52 {Instruction[31]}}, Instruction[31:20]};
			7'b0100011: ImmExt = {{52 {Instruction[31]}}, Instruction[31:25], Instruction[11:7]};
			7'b1100011: ImmExt = {{51 {Instruction[31]}}, Instruction[31], Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
			7'b0110111, 7'b0010111: ImmExt = {{32 {Instruction[31]}}, Instruction[31:12], 12'b000000000000};
			7'b1101111: ImmExt = {{43 {Instruction[31]}}, Instruction[31], Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
			default: ImmExt = 64'b0000000000000000000000000000000000000000000000000000000000000000;
		endcase
endmodule
module DMEM (
	clk,
	Address,
	Write_data,
	MemWrite,
	MemRead,
	MemSize,
	Read_data
);
	input wire clk;
	input wire [63:0] Address;
	input wire [63:0] Write_data;
	input wire MemWrite;
	input wire MemRead;
	input wire [2:0] MemSize;
	output wire [63:0] Read_data;
endmodule
module IMEM (
	Read_address,
	Instruction
);
	input wire [63:0] Read_address;
	output wire [31:0] Instruction;
endmodule
module MUX_2_1 (
	In0,
	In1,
	Sel,
	Out
);
	parameter WIDTH = 64;
	input wire [WIDTH - 1:0] In0;
	input wire [WIDTH - 1:0] In1;
	input wire Sel;
	output reg [WIDTH - 1:0] Out;
	always @(*)
		case (Sel)
			1'b0: Out = In0;
			1'b1: Out = In1;
			default: Out = In0;
		endcase
endmodule
module Mux_WB (
	In0,
	In1,
	In2,
	Sel,
	Out
);
	parameter WIDTH = 64;
	input wire [WIDTH - 1:0] In0;
	input wire [WIDTH - 1:0] In1;
	input wire [WIDTH - 1:0] In2;
	input wire [1:0] Sel;
	output reg [WIDTH - 1:0] Out;
	always @(*)
		case (Sel)
			2'b00: Out = In0;
			2'b01: Out = In1;
			2'b10: Out = In2;
			default: Out = In0;
		endcase
endmodule
module PC_next (
	Zero,
	Sign,
	CarryOut,
	Overflow,
	Branch,
	Jump,
	JALSrc,
	Funct3,
	Imm,
	Pre_Address,
	ALU_Result,
	Next_Address,
	Take_Branch
);
	input wire Zero;
	input wire Sign;
	input wire CarryOut;
	input wire Overflow;
	input wire Branch;
	input wire Jump;
	input wire JALSrc;
	input [2:0] Funct3;
	input wire [63:0] Imm;
	input wire [63:0] Pre_Address;
	input wire [63:0] ALU_Result;
	output reg [63:0] Next_Address;
	output wire Take_Branch;
	reg Condition_Met;
	always @(*)
		case (Funct3)
			3'b000: Condition_Met = Zero;
			3'b001: Condition_Met = ~Zero;
			3'b100: Condition_Met = Sign ^ Overflow;
			3'b101: Condition_Met = ~(Sign ^ Overflow);
			3'b110: Condition_Met = CarryOut;
			3'b111: Condition_Met = ~CarryOut;
			default: Condition_Met = 1'b0;
		endcase
	assign Take_Branch = (Branch & Condition_Met) | Jump;
	always @(*)
		if (Jump & JALSrc)
			Next_Address = {ALU_Result[63:1], 1'b0};
		else
			Next_Address = Pre_Address + Imm;
endmodule
module PC (
	clk,
	rst_n,
	EN,
	Take_Branch,
	Next_Address,
	Address
);
	input wire clk;
	input wire rst_n;
	input wire EN;
	input wire Take_Branch;
	input wire [63:0] Next_Address;
	output reg [63:0] Address;
	wire [63:0] Next_PC_internal;
	assign Next_PC_internal = (Take_Branch ? Next_Address : Address + 64'd4);
	always @(posedge clk or negedge rst_n)
		if (!rst_n)
			Address <= 1'sb0;
		else if (EN)
			Address <= Next_PC_internal;
endmodule
module EX_MEM_reg (
	clk,
	rst_n,
	EN,
	CLR,
	EX_ALU_result,
	EX_Store_Data,
	EX_Write_register,
	EX_Control_signals,
	EX_MemSize,
	MEM_ALU_result,
	MEM_Write_data,
	MEM_Write_register,
	MEM_Control_signals,
	MEM_MemSize
);
	input wire clk;
	input wire rst_n;
	input wire EN;
	input wire CLR;
	input wire [63:0] EX_ALU_result;
	input wire [63:0] EX_Store_Data;
	input wire [4:0] EX_Write_register;
	input wire [3:0] EX_Control_signals;
	input wire [2:0] EX_MemSize;
	output reg [63:0] MEM_ALU_result;
	output reg [63:0] MEM_Write_data;
	output reg [4:0] MEM_Write_register;
	output reg [3:0] MEM_Control_signals;
	output reg [2:0] MEM_MemSize;
	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			MEM_ALU_result <= 1'sb0;
			MEM_Write_data <= 1'sb0;
			MEM_Write_register <= 1'sb0;
			MEM_Control_signals <= 1'sb0;
			MEM_MemSize <= 1'sb0;
		end
		else if (CLR)
			MEM_Control_signals <= 1'sb0;
		else if (EN) begin
			MEM_ALU_result <= EX_ALU_result;
			MEM_Write_data <= EX_Store_Data;
			MEM_Write_register <= EX_Write_register;
			MEM_Control_signals <= EX_Control_signals;
			MEM_MemSize <= EX_MemSize;
		end
endmodule
module Forwarding_Unit (
	ID_EX_Rs1,
	ID_EX_Rs2,
	EX_MEM_Rd,
	MEM_WB_Rd,
	EX_MEM_RegWrite,
	MEM_WB_RegWrite,
	ForwardA,
	ForwardB
);
	input wire [4:0] ID_EX_Rs1;
	input wire [4:0] ID_EX_Rs2;
	input wire [4:0] EX_MEM_Rd;
	input wire [4:0] MEM_WB_Rd;
	input wire EX_MEM_RegWrite;
	input wire MEM_WB_RegWrite;
	output reg [1:0] ForwardA;
	output reg [1:0] ForwardB;
	always @(*) begin
		if ((EX_MEM_RegWrite && (EX_MEM_Rd != 5'b00000)) && (EX_MEM_Rd == ID_EX_Rs1))
			ForwardA = 2'b10;
		else if ((MEM_WB_RegWrite && (MEM_WB_Rd != 5'b00000)) && (MEM_WB_Rd == ID_EX_Rs1))
			ForwardA = 2'b01;
		else
			ForwardA = 2'b00;
		if ((EX_MEM_RegWrite && (EX_MEM_Rd != 5'b00000)) && (EX_MEM_Rd == ID_EX_Rs2))
			ForwardB = 2'b10;
		else if ((MEM_WB_RegWrite && (MEM_WB_Rd != 5'b00000)) && (MEM_WB_Rd == ID_EX_Rs2))
			ForwardB = 2'b01;
		else
			ForwardB = 2'b00;
	end
endmodule
module Hazard_Detection_Unit (
	IF_ID_Rs1,
	IF_ID_Rs2,
	ID_EX_MemRead,
	ID_EX_Rd,
	Branch_Taken,
	PC_EN,
	IF_ID_EN,
	IF_ID_CLR,
	ID_EX_CLR
);
	input wire [4:0] IF_ID_Rs1;
	input wire [4:0] IF_ID_Rs2;
	input wire ID_EX_MemRead;
	input wire [4:0] ID_EX_Rd;
	input wire Branch_Taken;
	output reg PC_EN;
	output reg IF_ID_EN;
	output reg IF_ID_CLR;
	output reg ID_EX_CLR;
	always @(*) begin
		PC_EN = 1'b1;
		IF_ID_EN = 1'b1;
		IF_ID_CLR = 1'b0;
		ID_EX_CLR = 1'b0;
		if (Branch_Taken) begin
			IF_ID_CLR = 1'b1;
			ID_EX_CLR = 1'b1;
		end
		else if ((ID_EX_MemRead && (ID_EX_Rd != 5'b00000)) && ((ID_EX_Rd == IF_ID_Rs1) || (ID_EX_Rd == IF_ID_Rs2))) begin
			PC_EN = 1'b0;
			IF_ID_EN = 1'b0;
			ID_EX_CLR = 1'b1;
		end
	end
endmodule
module ID_EX_reg (
	clk,
	rst_n,
	EN,
	CLR,
	ID_PC,
	ID_Instruction,
	ID_Read_register_1,
	ID_Read_register_2,
	ID_Write_register,
	ID_Read_data_1,
	ID_Read_data_2,
	ID_ImmExt,
	ID_Control_signals,
	ID_MemSize,
	EX_PC,
	EX_Instruction,
	EX_Read_register_1,
	EX_Read_register_2,
	EX_Write_register,
	EX_Read_data_1,
	EX_Read_data_2,
	EX_ImmExt,
	EX_Control_signals,
	EX_MemSize
);
	input wire clk;
	input wire rst_n;
	input wire EN;
	input wire CLR;
	input wire [63:0] ID_PC;
	input wire [31:0] ID_Instruction;
	input wire [4:0] ID_Read_register_1;
	input wire [4:0] ID_Read_register_2;
	input wire [4:0] ID_Write_register;
	input wire [63:0] ID_Read_data_1;
	input wire [63:0] ID_Read_data_2;
	input wire [63:0] ID_ImmExt;
	input wire [10:0] ID_Control_signals;
	input wire [2:0] ID_MemSize;
	output reg [63:0] EX_PC;
	output reg [31:0] EX_Instruction;
	output reg [4:0] EX_Read_register_1;
	output reg [4:0] EX_Read_register_2;
	output reg [4:0] EX_Write_register;
	output reg [63:0] EX_Read_data_1;
	output reg [63:0] EX_Read_data_2;
	output reg [63:0] EX_ImmExt;
	output reg [10:0] EX_Control_signals;
	output reg [2:0] EX_MemSize;
	localparam NOP_Instruction = 32'h00000013;
	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			EX_PC <= 1'sb0;
			EX_Instruction <= NOP_Instruction;
			EX_Read_register_1 <= 1'sb0;
			EX_Read_register_2 <= 1'sb0;
			EX_Write_register <= 1'sb0;
			EX_Read_data_1 <= 1'sb0;
			EX_Read_data_2 <= 1'sb0;
			EX_ImmExt <= 1'sb0;
			EX_Control_signals <= 1'sb0;
			EX_MemSize <= 1'sb0;
		end
		else if (CLR) begin
			EX_Instruction <= NOP_Instruction;
			EX_Control_signals <= 1'sb0;
		end
		else if (EN) begin
			EX_PC <= ID_PC;
			EX_Instruction <= ID_Instruction;
			EX_Read_register_1 <= ID_Read_register_1;
			EX_Read_register_2 <= ID_Read_register_2;
			EX_Write_register <= ID_Write_register;
			EX_Read_data_1 <= ID_Read_data_1;
			EX_Read_data_2 <= ID_Read_data_2;
			EX_ImmExt <= ID_ImmExt;
			EX_Control_signals <= ID_Control_signals;
			EX_MemSize <= ID_MemSize;
		end
endmodule
module IF_ID_reg (
	clk,
	rst_n,
	EN,
	CLR,
	IF_PC,
	IF_Instruction,
	ID_PC,
	ID_Instruction
);
	input wire clk;
	input wire rst_n;
	input wire EN;
	input wire CLR;
	input wire [63:0] IF_PC;
	input wire [31:0] IF_Instruction;
	output reg [63:0] ID_PC;
	output reg [31:0] ID_Instruction;
	localparam NOP_Instruction = 32'h00000013;
	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			ID_PC <= 1'sb0;
			ID_Instruction <= NOP_Instruction;
		end
		else if (CLR) begin
			ID_PC <= 1'sb0;
			ID_Instruction <= NOP_Instruction;
		end
		else if (EN) begin
			ID_PC <= IF_PC;
			ID_Instruction <= IF_Instruction;
		end
endmodule
module MEM_WB_reg (
	clk,
	rst_n,
	EN,
	CLR,
	MEM_Read_data,
	MEM_ALU_result,
	MEM_Write_register,
	MEM_Control_signals,
	WB_Read_data,
	WB_ALU_result,
	WB_Write_register,
	WB_Control_signals
);
	input wire clk;
	input wire rst_n;
	input wire EN;
	input wire CLR;
	input wire [63:0] MEM_Read_data;
	input wire [63:0] MEM_ALU_result;
	input wire [4:0] MEM_Write_register;
	input wire [1:0] MEM_Control_signals;
	output reg [63:0] WB_Read_data;
	output reg [63:0] WB_ALU_result;
	output reg [4:0] WB_Write_register;
	output reg [1:0] WB_Control_signals;
	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			WB_Read_data <= 1'sb0;
			WB_ALU_result <= 1'sb0;
			WB_Write_register <= 1'sb0;
			WB_Control_signals <= 1'sb0;
		end
		else if (CLR)
			WB_Control_signals <= 1'sb0;
		else if (EN) begin
			WB_Read_data <= MEM_Read_data;
			WB_ALU_result <= MEM_ALU_result;
			WB_Write_register <= MEM_Write_register;
			WB_Control_signals <= MEM_Control_signals;
		end
endmodule
module Register (
	clk,
	Read_register_1,
	Read_register_2,
	Write_register,
	Write_data,
	RegWrite,
	Read_data_1,
	Read_data_2
);
	input wire clk;
	input wire [4:0] Read_register_1;
	input wire [4:0] Read_register_2;
	input wire [4:0] Write_register;
	input wire [63:0] Write_data;
	input wire RegWrite;
	output wire [63:0] Read_data_1;
	output wire [63:0] Read_data_2;
	reg [63:0] Register [31:0];
	assign Read_data_1 = (Read_register_1 == {5 {1'sb0}} ? {64 {1'sb0}} : (RegWrite && (Write_register == Read_register_1) ? Write_data : Register[Read_register_1]));
	assign Read_data_2 = (Read_register_2 == {5 {1'sb0}} ? {64 {1'sb0}} : (RegWrite && (Write_register == Read_register_2) ? Write_data : Register[Read_register_2]));
	always @(posedge clk)
		if (RegWrite && (Write_register != {5 {1'sb0}}))
			Register[Write_register] <= Write_data;
endmodule
