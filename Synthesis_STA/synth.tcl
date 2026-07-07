yosys read_verilog riscv_core_flat.v
yosys hierarchy -check -top RISC_V_pipe_line

yosys proc; yosys opt
yosys fsm; yosys opt
yosys memory; yosys opt
yosys techmap; yosys opt

set lib_path "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

yosys dfflibmap -liberty $lib_path
yosys abc -liberty $lib_path

yosys opt_clean -purge
yosys stat
yosys write_verilog -noattr -noexpr synth_netlist.v