quit -sim
if {[file exists work]} {
    vdel -all -lib work
}

vlib work
vmap work work

puts ">>> COMPILING RTL & TESTBENCH..."
vlog -sv RTL/Design/pkg.sv
vlog -sv RTL/*/*.sv
vlog -sv Benchmark/*.sv

puts ">>> STARTING SIMULATION..."
vsim -voptargs=+acc work.RISC_V_pipe_line_benchmark

add wave -divider {=== BENCHMARK MONITORS ===}
add wave -position insertpoint sim:RISC_V_pipe_line_benchmark/clk
add wave -position insertpoint sim:RISC_V_pipe_line_benchmark/rst_n
add wave -position insertpoint -radix decimal sim:RISC_V_pipe_line_benchmark/total_cycles
add wave -position insertpoint -radix decimal sim:RISC_V_pipe_line_benchmark/total_instructions
add wave -position insertpoint -radix decimal sim:RISC_V_pipe_line_benchmark/fetched_count
add wave -position insertpoint -radix decimal sim:RISC_V_pipe_line_benchmark/flush_count

add wave -divider {=== SYSTEM & PIPELINE ===}
add wave -radix unsigned     /RISC_V_pipe_line_benchmark/dut/IF_PC
add wave -radix hexadecimal  /RISC_V_pipe_line_benchmark/dut/IF_Instruction
add wave -radix hexadecimal  /RISC_V_pipe_line_benchmark/dut/ID_Instruction
add wave -radix hexadecimal  /RISC_V_pipe_line_benchmark/dut/EX_Instruction

add wave -divider {=== C-CODE REGISTERS ===}
add wave -radix decimal -label "a0 (Return)" /RISC_V_pipe_line_benchmark/dut/Register_top/Register[10]
add wave -radix decimal -label "a1 (Arg 1)"  /RISC_V_pipe_line_benchmark/dut/Register_top/Register[11]
add wave -radix decimal -label "a2 (Arg 2)"  /RISC_V_pipe_line_benchmark/dut/Register_top/Register[12]
add wave -radix decimal -label "a3 (Arg 3)"  /RISC_V_pipe_line_benchmark/dut/Register_top/Register[13]
add wave -radix decimal -label "a4 (Arg 4)"  /RISC_V_pipe_line_benchmark/dut/Register_top/Register[14]
add wave -radix decimal -label "ra (Return Addr)" /RISC_V_pipe_line_benchmark/dut/Register_top/Register[1]
add wave -radix hexadecimal /RISC_V_pipe_line_benchmark/dut/MEM_Read_data

add wave -divider {=== HAZARD & FORWARDING ===}
add wave /RISC_V_pipe_line_benchmark/dut/Forwarding_Unit_top/ForwardA
add wave /RISC_V_pipe_line_benchmark/dut/Forwarding_Unit_top/ForwardB
add wave /RISC_V_pipe_line_benchmark/dut/Hazard_Detection_Unit_top/PC_EN
add wave /RISC_V_pipe_line_benchmark/dut/Hazard_Detection_Unit_top/IF_ID_CLR
add wave /RISC_V_pipe_line_benchmark/dut/Hazard_Detection_Unit_top/ID_EX_CLR

add wave -divider {=== BTB & BRANCHING ===}
add wave /RISC_V_pipe_line_benchmark/dut/IF_BTB_Hit
add wave /RISC_V_pipe_line_benchmark/dut/Branch_Taken
add wave /RISC_V_pipe_line_benchmark/dut/EX_Mispredicted
add wave -radix unsigned /RISC_V_pipe_line_benchmark/dut/Final_Next_Address

view structure
view signals
view wave

run -all

wave zoom full

puts ">>> SIMULATION COMPLETED. CHECK WAVEFORMS."