quit -sim
if {[file exists work]} {
    vdel -all -lib work
}

vlib work
vmap work work

vlog -sv RTL/Design/pkg.sv

vlog -sv RTL/*/*.sv

vlog -sv Test_Bench/*.sv

vsim -voptargs=+acc work.RISC_V_pipe_line_tb

add wave -divider {=== Testbench Monitors ===}
add wave -position insertpoint sim:RISC_V_pipe_line_tb/clk
add wave -position insertpoint sim:RISC_V_pipe_line_tb/rst_n
add wave -position insertpoint -radix decimal sim:RISC_V_pipe_line_tb/final_result

add wave -divider "=== SYSTEM & PIPELINE ==="
add wave -radix unsigned /RISC_V_pipe_line_tb/dut/IF_PC
add wave -radix hexadecimal /RISC_V_pipe_line_tb/dut/IF_Instruction
add wave -radix hexadecimal /RISC_V_pipe_line_tb/dut/ID_Instruction
add wave -radix hexadecimal /RISC_V_pipe_line_tb/dut/EX_Instruction

add wave -divider "=== ARRAY SUM REGISTERS ==="
add wave -radix unsigned -label "a0_Pointer" /RISC_V_pipe_line_tb/dut/Register_top/Register[10]
add wave -radix unsigned -label "t0_Sum"     /RISC_V_pipe_line_tb/dut/Register_top/Register[5]
add wave -radix unsigned -label "t1_Counter" /RISC_V_pipe_line_tb/dut/Register_top/Register[6]
add wave -radix unsigned -label "t2_Data"    /RISC_V_pipe_line_tb/dut/Register_top/Register[7]
add wave -radix unsigned /RISC_V_pipe_line_tb/dut/MEM_Read_data

add wave -divider "=== HAZARD & FORWARDING ==="
add wave /RISC_V_pipe_line_tb/dut/Forwarding_Unit_top/ForwardA
add wave /RISC_V_pipe_line_tb/dut/Forwarding_Unit_top/ForwardB
add wave /RISC_V_pipe_line_tb/dut/Hazard_Detection_Unit_top/PC_EN
add wave /RISC_V_pipe_line_tb/dut/Hazard_Detection_Unit_top/IF_ID_CLR
add wave /RISC_V_pipe_line_tb/dut/Hazard_Detection_Unit_top/ID_EX_CLR

add wave -divider "=== BTB & BRANCHING ==="
add wave /RISC_V_pipe_line_tb/dut/IF_BTB_Hit
add wave /RISC_V_pipe_line_tb/dut/Branch_Taken
add wave /RISC_V_pipe_line_tb/dut/EX_Mispredicted
add wave -radix unsigned /RISC_V_pipe_line_tb/dut/Final_Next_Address


view structure
view signals
view wave

run -all

wave zoom full
