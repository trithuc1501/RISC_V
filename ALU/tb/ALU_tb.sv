import pkg::*;

module ALU_tb;

    logic [63:0] A;
    logic [63:0] B;
    ALU_e ALUctl;
    
    logic [64:0] Result;
    logic CarryOut;
    logic Zero;
    logic Overflow;

    logic [1:0] ALUOp;
    logic Funct7,
    logic [2:0] Funct3,

    ALU alu (
        .A(A),
        .B(B),
        .ALUctl(ALUctl),
        .Result(Result),
        .CarryOut(CarryOut),
        .Zero(Zero),
        .Overflow(Overflow)
    );

    ALU_control alu_control (
        .ALUOp(ALUOp),
        .Funct7(Funct7),
        .Funct3(Funct3),
        .ALUctl(ALUctl)
    );


    initial begin
        $display("=================== START SIMULATION ===================\n");
        A = 64'd100;
        B = 64'd30;
      	{ALUOp, Funct7, Funct3} = 6'b10_0_000;
        #10;
        $display("Time: %0t | A = %0d, B = %0d | ALUctl = %s | Result = %0d | CarryOut = %b | Zero = %b | Overflow = %b",
                 $time, A, B, ALUctl.name(), $signed(Result[63:0]), CarryOut, Zero, Overflow);
      
      	A = 64'd10;
        B = 64'd30;
      	{ALUOp, Funct7, Funct3} = 6'b10_1_000;
        #10;
        $display("Time: %0t | A = %0d, B = %0d | ALUctl = %s | Result = %0d | CarryOut = %b | Zero = %b | Overflow = %b",
                 $time, A, B, ALUctl.name(), $signed(Result[63:0]), CarryOut, Zero, Overflow);
      
      	A = 64'd10;
        B = 64'd10;
      	{ALUOp, Funct7, Funct3} = 6'b10_0_111;
        #10;
        $display("Time: %0t | A = %0d, B = %0d | ALUctl = %s | Result = %0d | CarryOut = %b | Zero = %b | Overflow = %b",
                 $time, A, B, ALUctl.name(), $signed(Result[63:0]), CarryOut, Zero, Overflow);
      
      	$display("\n=================== END SIMULATION ===================");
        $finish;
    end

endmodule