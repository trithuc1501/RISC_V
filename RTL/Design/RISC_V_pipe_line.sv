import pkg::*;

module RISC_V_pipe_line (
    input clk,
    input rst_n
);  

    logic [63:0] IF_PC;
    logic [31:0] IF_Instruction;
    logic [63:0] IF_Predicted_Target;
    logic IF_BTB_Hit;

    logic [63:0] ID_PC;
    logic [31:0] ID_Instruction;
    logic [4:0] ID_Read_register_1;
    logic [4:0] ID_Read_register_2;
    logic [4:0] ID_Write_register;
    logic [63:0] ID_Read_data_1;
    logic [63:0] ID_Read_data_2;
    logic [63:0] ID_ImmExt;
    logic [10:0] ID_Control_signals;
    logic ID_Predicted_Taken;

    logic [63:0] EX_PC;
    logic [31:0] EX_Instruction;
    logic [4:0] EX_Read_register_1;
    logic [4:0] EX_Read_register_2;
    logic [4:0] EX_Write_register;
    logic [63:0] EX_Read_data_1;
    logic [63:0] EX_Read_data_2;
    logic [63:0] EX_ImmExt;
    logic [10:0] EX_Control_signals;
    logic [63:0] EX_ALU_result;
    logic [63:0] EX_Data_To_MEM;
    logic EX_Predicted_Taken;
    logic EX_Mispredicted;
    logic EX_BTB_Update_EN;

    logic [63:0] MEM_ALU_result;
    logic [63:0] MEM_Write_data;
    logic [63:0] MEM_Read_data;
    logic [4:0] MEM_Write_register;
    logic [3:0] MEM_Control_signals;

    logic [63:0] WB_Read_data;
    logic [63:0] WB_ALU_result;
    logic [4:0] WB_Write_register;
    logic [1:0] WB_Control_signals;

    logic [1:0] ForwardA;
    logic [1:0] ForwardB;
    
    logic PC_EN;
    logic IF_ID_EN;
    logic IF_ID_CLR;
    logic ID_EX_CLR;

    logic Branch_Taken;
    logic [63:0] Target_Address;
    ALU_e ALUctl;
    logic CarryOut;
    logic Zero;
    logic Overflow;
    logic Sign;
    logic [63:0] WriteBack_data;

    logic [63:0] Forwarded_A;
    logic [63:0] ALU_SrcA;
    logic [63:0] Forwarded_B;

    logic Final_Take_Branch;
    logic [63:0] Final_Next_Address;
    logic [63:0] Actual_Next_PC;

    always_comb begin
        if (EX_Mispredicted) begin
            Final_Take_Branch  = 1'b1;
            Final_Next_Address = Actual_Next_PC;
        end 
        else if (IF_BTB_Hit) begin
            Final_Take_Branch  = 1'b1;
            Final_Next_Address = IF_Predicted_Target;
        end
        else begin
            Final_Take_Branch  = 1'b0;
            Final_Next_Address = 64'd0; 
        end
    end

    assign Actual_Next_PC = Branch_Taken ? Target_Address : (EX_PC + 64'd4);
    assign EX_Mispredicted = (EX_Control_signals[2] || EX_Control_signals[8]) && (ID_PC != Actual_Next_PC);

    PC PC_top (
        .clk(clk),
        .rst_n(rst_n),
        .EN(PC_EN),
        .Take_Branch(Final_Take_Branch),
        .Next_Address(Final_Next_Address),

        .Address(IF_PC)
    );

    Branch_Target_Buffer u_BTB (
        .clk(clk),
        .rst_n(rst_n),
        .IF_PC(IF_PC),
        .Predicted_Target(IF_Predicted_Target),
        .BTB_Hit(IF_BTB_Hit),

        .EX_Update_Enable(EX_BTB_Update_EN),
        .EX_PC(EX_PC),
        .EX_Target_Address(Target_Address)
    );

    assign EX_BTB_Update_EN = (EX_Control_signals[2] || EX_Control_signals[8]) && Branch_Taken;

    IMEM IMEM_top (
        .Read_address(IF_PC),

        .Instruction(IF_Instruction)
    );

    IF_ID_reg IF_ID_reg_top (
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
    assign ID_Write_register  = ID_Instruction[11:7];

    Register Register_top (
        .clk(clk),
        .Read_register_1(ID_Read_register_1),
        .Read_register_2(ID_Read_register_2),
        .Write_register(WB_Write_register),
        .Write_data(WriteBack_data),
        .RegWrite(WB_Control_signals[0]),

        .Read_data_1(ID_Read_data_1),
        .Read_data_2(ID_Read_data_2)
    );

    ImmGen ImmGen_top (
        .Instruction(ID_Instruction),

        .ImmExt(ID_ImmExt)
    );

    Control Control_top (
        .Opcode(ID_Instruction[6:0]),
        .Control_Signals(ID_Control_signals)
    );

    ID_EX_reg ID_EX_reg_top (
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

        .EX_PC(EX_PC),
        .EX_Instruction(EX_Instruction),
        .EX_Read_register_1(EX_Read_register_1),
        .EX_Read_register_2(EX_Read_register_2),
        .EX_Write_register(EX_Write_register),
        .EX_Read_data_1(EX_Read_data_1),
        .EX_Read_data_2(EX_Read_data_2),
        .EX_ImmExt(EX_ImmExt),
        .EX_Control_signals(EX_Control_signals)
    );

    always_comb begin
        if (ForwardA == 2'b10) Forwarded_A = MEM_ALU_result;
        else if (ForwardA == 2'b01) Forwarded_A = WriteBack_data;
        else Forwarded_A = EX_Read_data_1;
    end

    MUX_2_1 MUX_2_1_top (
        .In0(Forwarded_A),
        .In1(EX_PC),
        .Sel(EX_Control_signals[10]),
        
        .Out(ALU_SrcA)
    );

    always_comb begin
        if (ForwardB == 2'b10) Forwarded_B = MEM_ALU_result;
        else if (ForwardB == 2'b01) Forwarded_B = WriteBack_data;
        else Forwarded_B = EX_Read_data_2;
    end

    ALU_control ALU_control_top (
        .ALUOp(EX_Control_signals[1:0]),
        .Opcode5(EX_Instruction[5]),
        .Funct7(EX_Instruction[30]),
        .Funct3(EX_Instruction[14:12]),

        .ALUctl(ALUctl)
    );

    ALU ALU_top (
        .SrcA(ALU_SrcA),
        .SrcB(EX_Control_signals[7] ? EX_ImmExt : Forwarded_B),
        .ALUctl(ALUctl),

        .Result(EX_ALU_result),
        .CarryOut(CarryOut),
        .Zero(Zero),
        .Overflow(Overflow),
        .Sign(Sign)
    );

    PC_next Pc_next_top (
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

    assign EX_Data_To_MEM = EX_Control_signals[8] ? (EX_PC + 64'd4) : EX_ALU_result;

    EX_MEM_reg EX_MEM_reg_top (
        .clk(clk),
        .rst_n(rst_n),
        .EN(1'b1),
        .CLR(1'b0),
        .EX_ALU_result(EX_Data_To_MEM),
        .EX_Store_Data(Forwarded_B),
        .EX_Write_register(EX_Write_register),
        .EX_Control_signals(EX_Control_signals[6:3]), 

        .MEM_ALU_result(MEM_ALU_result),
        .MEM_Write_data(MEM_Write_data),
        .MEM_Write_register(MEM_Write_register),
        .MEM_Control_signals(MEM_Control_signals)
    );

    DMEM DMEM_top (
        .clk(clk),
        .Address(MEM_ALU_result),
        .Write_data(MEM_Write_data),
        .MemWrite(MEM_Control_signals[0]),
        .MemRead(MEM_Control_signals[1]),

        .Read_data(MEM_Read_data)
    );

    MEM_WB_reg MEM_WB_reg_top (
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

    assign WriteBack_data = WB_Control_signals[1] ? WB_Read_data : WB_ALU_result;

    Hazard_Detection_Unit Hazard_Detection_Unit_top (
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

    Forwarding_Unit Forwarding_Unit_top (
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