current_design RISC_V_pipe_line

create_clock -name clk -period 50.0 [get_ports clk]

set_clock_uncertainty 0.25 [get_clocks clk]
set_clock_transition  0.15 [get_clocks clk]

if {[llength [get_ports rst_n]]} {
    set_false_path -from [get_ports rst_n]
}

set_input_delay  2.00 -clock clk [get_ports {imem_inst* dmem_rdata*}]
set_output_delay 2.00 -clock clk [get_ports {imem_addr* dmem_addr* dmem_wdata* dmem_we dmem_re dmem_size*}]

set_max_transition 1.50 [current_design]

set_max_capacitance 0.50 [current_design]

set_load 0.05 [all_outputs]