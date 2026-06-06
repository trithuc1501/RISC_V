`timescale 1ns/1ps

module RISC_V_pipe_line_tb1;
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

      	// Chờ 100 chu kỳ Clock để CPU chạy xong toàn bộ các bước nhảy và vòng lặp
        #(CLK_PERIOD * 100); 

        $display("\n=======================================================");
        $display("                  SELF-TEST RESULTS                      ");
        $display("=======================================================");
        
        // Kiểm tra các giá trị cốt lõi
        $display("MEM[0]   = %0d (Expected: 10)", dut.DMEM_top.memory[0]);
        $display("x11      = %0d (Expected: 25)", dut.Register_top.Register[11]);
        $display("x9 (Loop)= %0d (Expected: 0)", dut.Register_top.Register[9]);
        $display("x13      = %0d (Expected: 0 - Phải bị bỏ qua)", dut.Register_top.Register[13]);
        $display("x10(FAIL)= %0d (Expected: 0 - Phải bị bỏ qua)", dut.Register_top.Register[10]);

        if (dut.DMEM_top.memory[0] == 8'd10 && 
            dut.Register_top.Register[11] == 64'd25 && 
            dut.Register_top.Register[9] == 64'd0 &&
            dut.Register_top.Register[13] == 64'd0) begin
            $display("\n>>> STATUS: [ PASS ] - THE ULTIMATE TEST SURVIVED!");
            $display("Hazards, Forwarding, and Branch Prediction working perfectly.");
        end else begin
            $display("\n>>> STATUS: [ FAILED ] - Tín hiệu lỗi! Hãy kiểm tra dạng sóng.");
        end
        $display("=======================================================\n");

        $finish;
    end

    // Theo dõi toàn bộ quá trình biến đổi của các thanh ghi chính
    initial begin
        $monitor("Time=%0t | PC=%0d | x4=%0d | x5=%0d | x7=%0d | x9=%0d | x11=%0d | x12=%0d | x13=%0d", 
                 $time, 
                 dut.IF_PC,
                 dut.Register_top.Register[4],  // Theo dõi Forwarding 1
                 dut.Register_top.Register[5],  // Theo dõi Forwarding 2
                 dut.Register_top.Register[7],  // Theo dõi Load-Use
                 dut.Register_top.Register[9],  // Theo dõi Vòng lặp
                 dut.Register_top.Register[11], // Theo dõi Hàm FUNC
                 dut.Register_top.Register[12], // Theo dõi AUIPC
                 dut.Register_top.Register[13]  // Đảm bảo lệnh x13 không chạy
        );
    end
endmodule