read_liberty $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_verilog synth_netlist.v
link_design RISC_V_pipe_line
read_sdc constraints.sdc

puts "\n======================================================="
puts " WNS (Worst Negative Slack) & TNS (Total Negative Slack)"
puts "======================================================="
report_wns
report_tns

puts "\n======================================================="
puts " Worst Timing Path (Setup / Max Delay)"
puts "======================================================="
# Format báo cáo chi tiết hơn để dễ dò đường đi của tín hiệu
report_checks -path_delay max -fields {slew cap input nets fanout} -digits 3

puts "\n======================================================="
puts " Worst Timing Path (Hold / Min Delay)"
puts "======================================================="
report_checks -path_delay min -fields {slew cap input nets fanout} -digits 3

puts "\n======================================================="
puts " Power Summary"
puts "======================================================="
report_power