module DMEM (
    input  logic clk,
    input  logic [63:0] Address,
    input  logic [63:0] Write_data,

    input  logic MemWrite,
    input  logic MemRead,

    input  logic [2:0] MemSize,

    output logic [63:0] Read_data
);

    logic [7:0] memory [0:262143];

    logic [7:0]  byte_data;
    logic [15:0] half_data;
    logic [31:0] word_data;
    logic [63:0] dword_data;

    assign byte_data  = memory[Address];
    assign half_data  = {memory[Address+1], memory[Address]};
    assign word_data  = {memory[Address+3], memory[Address+2], memory[Address+1], memory[Address]};
    assign dword_data = {memory[Address+7], memory[Address+6], memory[Address+5], memory[Address+4],
                          memory[Address+3], memory[Address+2], memory[Address+1], memory[Address]};

    always_comb begin
        if (!MemRead) begin
            Read_data = 64'b0;
        end else begin
            case (MemSize)
                3'b000: Read_data = {{56{byte_data[7]}},  byte_data};  // lb
                3'b001: Read_data = {{48{half_data[15]}}, half_data};  // lh
                3'b010: Read_data = {{32{word_data[31]}}, word_data};  // lw
                3'b011: Read_data = dword_data;                        // ld
                3'b100: Read_data = {56'b0, byte_data};                // lbu 
                3'b101: Read_data = {48'b0, half_data};                // lhu 
                3'b110: Read_data = {32'b0, word_data};                // lwu 
                default: Read_data = dword_data;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (MemWrite) begin
            int num_bytes;

            case (MemSize)
                3'b000: num_bytes = 1; // sb
                3'b001: num_bytes = 2; // sh
                3'b010: num_bytes = 4; // sw
                3'b011: num_bytes = 8; // sd
                default: num_bytes = 8;
            endcase

            for (int i = 0; i < num_bytes; i++) begin
                memory[Address + i] <= Write_data[8 * i +: 8];
            end
        end
    end

endmodule