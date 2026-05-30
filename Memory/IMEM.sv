module IMEM (
    input logic [63:0] Read_address,

    output logic [31:0] Instruction
); 
    logic [7:0] memory [1023:0];

    assign Instruction = {memory[Read_address + 3], memory[Read_address + 2], memory[Read_address + 1], memory[Read_address]};

endmodule