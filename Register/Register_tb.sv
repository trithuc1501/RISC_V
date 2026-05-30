module Register_tb;
    logic clk;
    logic rst_n;
    logic [4:0] Read_register_1;
    logic [4:0] Read_register_2;
    logic [4:0] Write_register;
    logic [63:0] Write_data;
    logic RegWrite;

    logic [63:0] Read_data_1;
    logic [63:0] Read_data_2;

    Register Register (
        .clk(clk),
        .rst_n(rst_n),
        .Read_register_1(Read_register_1),
        .Read_register_2(Read_register_2),
        .Write_register(Write_register),
        .Write_data(Write_data),
        .RegWrite(RegWrite),

        .Read_data_1(Read_data_1),
        .Read_data_2(Read_data_2)
    );

    localparam CLK_PERIOD = 20;

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        $display("=================== START SIMULATION ===================\n");

        rst_n = 0;
        #(CLK_PERIOD * 5) rst_n = 1;
        #10;

        Read_register_1 = 5'd22;
        Read_register_2 = 5'd20;
        $display("Time: %0t | Read_register_1 = %0d | Read_register_2 = %0d | Read_data_1 = %0d | Read_data_2 = %0d | RegWrite = %0d | Write_data = %0h | Mem[%0d] = %0d",
                 $time, Read_register_1, Read_register_2, Read_data_1, Read_data_2, RegWrite, $signed(Write_data), Write_register, Register.Register[Write_register]);
        #10;
        RegWrite = 1;
        Write_register = 5'd21;
        Write_data = 64'habcd;
        $display("Time: %0t | Read_register_1 = %0d | Read_register_2 = %0d | Read_data_1 = %0d | Read_data_2 = %0d | RegWrite = %0d | Write_data = %0h | Mem[%0d] = %0d",
                 $time, Read_register_1, Read_register_2, Read_data_1, Read_data_2, RegWrite, $signed(Write_data), Write_register, Register.Register[Write_register]);
        #10;
        Read_register_1 = 5'd21;
        $display("Time: %0t | Read_register_1 = %0d | Read_register_2 = %0d | Read_data_1 = %0d | Read_data_2 = %0d | RegWrite = %0d | Write_data = %0h | Mem[%0d] = %0d",
                 $time, Read_register_1, Read_register_2, Read_data_1, Read_data_2, RegWrite, $signed(Write_data), Write_register, Register.Register[Write_register]);
        #10;
        $display("\n=================== END SIMULATION ===================");
        $finish;
    end

endmodule