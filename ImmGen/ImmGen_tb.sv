module ImmGen_tb;
    logic [31:0] instruction;
    logic [63:0] ImmExt;

    ImmGen ImmGen (
        .instruction(instruction),
        .ImmExt(ImmExt)
    );

    initial begin
        $display("=================== START SIMULATION ===================\n");

        instruction = 32'b000000010000_01010_011_00101_1100000;
        #10;
        $display("Time: %0t | instruction = %0d | ImmExt = %0d", $time, instruction, ImmExt);

        instruction = 32'b1111111_00110_01011_011_00000_1100010;
        #10;
        $display("Time: %0t | instrucion = %0d | ImmExt = %0d", $time, instruction, ImmExt);

        instruction = 32'b1_111111_00010_00001_000_1100_1_1100011;
        #10;
        $display("Time: %0t | instruction = %0d | ImmExt = %0d", $time, instruction, ImmExt);

        $display("\n=================== END SIMULATION ===================");
        $finish;
    end

endmodule