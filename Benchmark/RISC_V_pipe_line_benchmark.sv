`timescale 1ns/1ps

module RISC_V_pipe_line_benchmark;
    logic clk;
    logic rst_n;

    string imem_path = "Benchmark/imem.hex";
    string dmem_path = "Benchmark/dmem.hex";
    int    timeout_cycles = 500000;

    localparam CLK_PERIOD = 20;

    longint total_cycles      = 0;
    longint fetched_count     = 0;
    longint stall_cycles      = 0;
    longint mispredict_events = 0; 
    longint flush_count       = 0; 
                                    
    longint branch_jump_count = 0;
    longint btb_hit_count     = 0;
    longint forwardA_count    = 0;
    longint forwardB_count    = 0;
    longint total_instructions = 0;
 
    RISC_V_pipe_line dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    always_ff @(posedge clk) begin
        if (rst_n) total_cycles <= total_cycles + 1;
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            if (dut.PC_EN) begin
                fetched_count <= fetched_count + 1;
                if (dut.IF_BTB_Hit) btb_hit_count <= btb_hit_count + 1;
            end else begin
                stall_cycles <= stall_cycles + 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n && dut.EX_Mispredicted) begin
            mispredict_events <= mispredict_events + 1;
            flush_count       <= flush_count + 2;
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n && (dut.EX_Control_signals[2] || dut.EX_Control_signals[8])) begin
            branch_jump_count <= branch_jump_count + 1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            if (dut.ForwardA != 2'b00) forwardA_count <= forwardA_count + 1;
            if (dut.ForwardB != 2'b00) forwardB_count <= forwardB_count + 1;
        end
    end

    initial begin
        void'($value$plusargs("IMEM_FILE=%s", imem_path));
        void'($value$plusargs("DMEM_FILE=%s", dmem_path));
        void'($value$plusargs("TIMEOUT=%d", timeout_cycles));

        $dumpfile("riscv_pipeline.vcd");
        $dumpvars(0, RISC_V_pipe_line_benchmark);

        $display("=========================================================");
        $display("           STARTING BENCHMARK SIMULATION                 ");
        $display("=========================================================");
        $display("IMEM : %s", imem_path);
        $display("DMEM : %s\n", dmem_path);

        rst_n = '0;

        $readmemh(imem_path, dut.IMEM_top.memory);
        $readmemh(dmem_path, dut.DMEM_top.memory);

        #(CLK_PERIOD * 2);
        rst_n = '1;

        fork
            begin
                #(CLK_PERIOD * timeout_cycles);
                $display("\n>>> [WARNING] SIMULATION TIMEOUT: Reached %0d cycles.", timeout_cycles);
            end

            begin
                wait (dut.EX_Instruction == 32'h0000006f && dut.EX_Control_signals[8] == 1'b1);
                $display("\n>>> [SUCCESS] REACHED END_LOOP: Program finished naturally.");
                #(CLK_PERIOD * 5);
            end
        join_any
        disable fork;

        total_instructions = fetched_count - flush_count;

        $display("\n=========================================================");
        $display("                    BENCHMARK RESULTS                     ");
        $display("=========================================================");
        $display("-- Throughput --------------------------------------------");
        $display("Total Cycles        : %0d", total_cycles);
        $display("Total Fetched        : %0d", fetched_count);
        $display("Squashed (mispredict): %0d", flush_count);
        $display("Total Instructions   : %0d", total_instructions);
        if (total_cycles > 0 && total_instructions > 0) begin
            $display("IPC (Instr/Cycle)    : %.4f", $itor(total_instructions) / $itor(total_cycles));
            $display("CPI (Cycle/Instr)    : %.4f", $itor(total_cycles) / $itor(total_instructions));
        end

        $display("\n-- Hazards -------------------------------------------------");
        $display("Load-use Stall Cycles : %0d (%.2f%% of total cycles)",
                  stall_cycles,
                  (total_cycles > 0) ? (100.0 * $itor(stall_cycles) / $itor(total_cycles)) : 0.0);

        $display("\n-- Branch / Jump / BTB --------------------------------------");
        $display("Branch+Jump Executed  : %0d", branch_jump_count);
        $display("Mispredict Events     : %0d", mispredict_events);
        if (branch_jump_count > 0) begin
            $display("Misprediction Rate    : %.2f%%",
                      100.0 * $itor(mispredict_events) / $itor(branch_jump_count));
        end
        $display("BTB Hit Count         : %0d", btb_hit_count);
        if (fetched_count > 0) begin
            $display("BTB Hit Rate (/fetch) : %.2f%%",
                      100.0 * $itor(btb_hit_count) / $itor(fetched_count));
        end

        $display("\n-- Forwarding ------------------------------------------------");
        if (total_cycles > 0) begin
            $display("ForwardA active       : %0d cycles (%.2f%%)",
                      forwardA_count, 100.0 * $itor(forwardA_count) / $itor(total_cycles));
            $display("ForwardB active       : %0d cycles (%.2f%%)",
                      forwardB_count, 100.0 * $itor(forwardB_count) / $itor(total_cycles));
        end
        $display("=========================================================\n");

        $finish;
    end

    bit trace_en;
    initial trace_en = $test$plusargs("TRACE");

    initial begin
        if (trace_en) begin
            $monitor("Time=%0t | PC=%0d | Instr=%08h | a0(x10)=%0d | a1(x11)=%0d | a2(x12)=%0d | ra(x1)=%0d | PC_EN=%0b | Stall=%0b | Mispred=%0b",
                     $time,
                     dut.IF_PC,
                     dut.IF_Instruction,
                     dut.Register_top.Register[10],
                     dut.Register_top.Register[11],
                     dut.Register_top.Register[12],
                     dut.Register_top.Register[1],
                     dut.PC_EN,
                     ~dut.PC_EN,
                     dut.EX_Mispredicted
            );
        end
    end

endmodule