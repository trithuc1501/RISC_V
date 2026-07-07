module IMEM (
    input logic [63:0] Read_address,

    output logic [31:0] Instruction
); 
    `ifndef SYNTHESIS
    logic [7:0] memory [0:65535];

    assign Instruction = {memory[Read_address + 3], memory[Read_address + 2], memory[Read_address + 1], memory[Read_address]};
    `endif
    
endmodule