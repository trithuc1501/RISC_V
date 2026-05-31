module RISC_V_single_cycle_tb;
    logic clk;
    logic rst_n;

    RISC_V_single_cycle dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    localparam CLK_PERIOD = 20;

    initial begin
        clk = 0;
        forever begin
            #(CLK_PERIOD/2) clk = ~clk;
        end
    end

    initial begin
        $display("=================== START SIMULATION ===================\n");

        $monitor("Time=%0t | PC=%0d | Inst=%h | ALU_Out=%0d | x1=%0d | x2=%0d | x3=%0d", 
                 $time, dut.Address, dut.Instruction, dut.Result, dut.Register_top.Register[1], dut.Register_top.Register[2], dut.Register_top.Register[3]);

        rst_n = '0;
        for (int i = 0; i < 1024; i = i + 1) dut.IMEM_top.memory[i] = '0;
      	for (int i = 0; i < 1024; i = i + 1) dut.DMEM_top.memory[i] = '0;
      	for (int i = 0; i < 32; i = i + 1) dut.Register_top.Register[i] = '0;
        dut.Register_top.Register[0] = '0;

        $readmemh("program.hex", dut.IMEM_top.memory);
        $readmemh("dmem.hex", dut.DMEM_top.memory);

        #(CLK_PERIOD * 2);

        rst_n = '1;
        repeat (10) @(posedge clk);

        $display("\n=== KIEM TRA KET QUA TAI DMEM[16] ===");
        $display("DMEM[16] = %0d (Ky vong = 15)", dut.DMEM_top.memory[16]);

        $display("\n=================== END SIMULATION ===================");
        $finish;
    end

endmodule