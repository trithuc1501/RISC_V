quit -sim
if {[file exists work]} {
    vdel -all -lib work
}

vlib work
vmap work work

vlog -sv Design/*.sv

vsim -voptargs=+acc work.Test_Bench/RISC_V_pipe_line_tb

add wave -position insertpoint sim:/Test_Bench/RISC_V_pipe_line_tb/dut/*

add wave -divider "--- Testbench Monitors ---"
add wave -position insertpoint sim:/Test_Bench/RISC_V_pipe_line_tb/clk
add wave -position insertpoint sim:/Test_Bench/RISC_V_pipe_line_tb/rst_n
add wave -position insertpoint -radix decimal sim:/Test_Bench/RISC_V_pipe_line_tb/final_result

view structure
view signals
view wave

run -all

wave zoom full
