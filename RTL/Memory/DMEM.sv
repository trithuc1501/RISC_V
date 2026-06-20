module DMEM (
    input clk,
    input [63:0] Address,
    input [63:0] Write_data,

    input MemWrite,
    input MemRead,

    output [63:0] Read_data
);
    logic [7:0] memory [1023:0];
    
        
    assign Read_data = MemRead ? {memory[Address + 7], memory[Address + 6], memory[Address + 5], memory[Address + 4],
                                memory[Address + 3], memory[Address + 2], memory[Address + 1], memory[Address]} : '0; 
        
    always_ff @(posedge clk) begin
        if (MemWrite) begin
            for (int i = 0; i < 8; i++) begin
                memory[Address + i] <= Write_data[8 * i +: 8];
            end  
        end
    end

endmodule
