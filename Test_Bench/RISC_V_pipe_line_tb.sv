`timescale 1ns/1ps

module RISC_V_pipe_line_tb;
    logic clk;
    logic rst_n;
    
    logic [63:0] final_result; 

    RISC_V_pipe_line dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    localparam CLK_PERIOD = 20;

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
      
        $dumpfile("riscv_pipeline.vcd");
        $dumpvars(0, RISC_V_pipe_line_tb);

        $display("=========================================================");
        $display("           STARTING PIPELINE SIMULATION                  ");
        $display("=========================================================\n");

        rst_n = '0;

        for (int i = 0; i < 1024; i++) dut.IMEM_top.memory[i] = '0;
        for (int i = 0; i < 1024; i++) dut.DMEM_top.memory[i] = '0;
        for (int i = 0; i < 32; i++)   dut.Register_top.Register[i] = '0;

        $readmemh("program.hex", dut.IMEM_top.memory);
        $readmemh("dmem.hex", dut.DMEM_top.memory);

        #(CLK_PERIOD * 2);
        rst_n = '1; 

        wait(dut.IF_PC == 64'd16);
        
        #(CLK_PERIOD * 5); 

        final_result = {dut.DMEM_top.memory[7], dut.DMEM_top.memory[6], 
                        dut.DMEM_top.memory[5], dut.DMEM_top.memory[4],
                        dut.DMEM_top.memory[3], dut.DMEM_top.memory[2], 
                        dut.DMEM_top.memory[1], dut.DMEM_top.memory[0]};

        $display("\n=======================================================");
        $display("                  SELF-TEST RESULTS                      ");
        $display("=======================================================");
        $display("Array sum at DMEM[0] = %0d (Expected = 60)", final_result);

        if (final_result == 64'd60) begin
            $display(">>> STATUS: [ PASS ] - Pipeline executed function perfectly!");
        end else begin
            $display(">>> STATUS: [ FAILED ] - Results mismatch! Check Hazards/Forwarding!");
        end
        $display("=======================================================\n");

        $finish;
    end

    initial begin
        $monitor("Time=%0t | PC=%0d | a0(x10)=%0d | a1(x11)=%0d | t0(x5)=%0d | t1(x6)=%0d | t2(x7)=%0d | ra(x1)=%0d", 
                 $time, 
                 dut.IF_PC,
                 dut.Register_top.Register[10], 
                 dut.Register_top.Register[11], 
                 dut.Register_top.Register[5],  
                 dut.Register_top.Register[6],  
                 dut.Register_top.Register[7], 
                 dut.Register_top.Register[1]
        );
    end

endmodule