module PC_tb;
    logic clk;
    logic rst_n;
    logic Zero;
    logic Branch;
    logic [63:0] Imm;

    logic [63:0] Address;

    PC PC (
        .clk(clk),
        .rst_n(rst_n),
        .Zero(Zero),
        .Branch(Branch),
        .Imm(Imm),

        .Address(Address)
    );

    localparam CLK_PERIOD = 20;

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    always_ff @(posedge clk) begin
      $display("Time = %0d | Address = %0h", $time, Address);
    end

    initial begin
        $display("=================== START SIMULATION ===================\n");

        rst_n = 0;
      	Branch = '0;
      	Zero = '0;
        #(CLK_PERIOD * 5);
        rst_n = 1;

        #(CLK_PERIOD * 5);

        Zero = 1'b1;
        Branch = 1'b1;
        Imm = 64'hFFFFFFFE;

      	#(CLK_PERIOD * 2);

        rst_n = 0;
      	Branch = '0;
      	Zero = '0;
      	#(CLK_PERIOD);
      
      	rst_n = 1;

      	#(CLK_PERIOD * 6);

        $display("\n=================== END SIMULATION ===================");
        $finish;
    end

endmodule