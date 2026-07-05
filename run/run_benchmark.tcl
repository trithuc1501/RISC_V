# ============================================================================
# Vi xử lý RISC-V 5-Stage Pipeline - Automated Simulation Script
# ============================================================================

# 1. Dừng mô phỏng hiện tại (nếu có) và dọn dẹp thư viện cũ
quit -sim
if {[file exists work]} {
    vdel -all -lib work
}

# 2. Khởi tạo thư viện work mới
vlib work
vmap work work

# 3. Biên dịch mã nguồn (Theo thứ tự: Package -> RTL -> Testbench)
puts ">>> COMPILING RTL & TESTBENCH..."
vlog -sv RTL/Design/pkg.sv
vlog -sv RTL/*/*.sv
vlog -sv Benchmark/*.sv

# 4. Khởi chạy mô phỏng với cờ tối ưu hóa và cho phép đọc tín hiệu (+acc)
puts ">>> STARTING SIMULATION..."
vsim -voptargs=+acc work.RISC_V_pipe_line_tb

# ============================================================================
# CẤU HÌNH HIỂN THỊ DẠNG SÓNG (WAVEFORMS)
# ============================================================================

# --- Phân vùng 1: Testbench Monitors (Hiệu năng Benchmark) ---
add wave -divider {=== BENCHMARK MONITORS ===}
add wave -position insertpoint sim:RISC_V_pipe_line_tb/clk
add wave -position insertpoint sim:RISC_V_pipe_line_tb/rst_n
add wave -position insertpoint -radix decimal sim:RISC_V_pipe_line_tb/total_cycles
add wave -position insertpoint -radix decimal sim:RISC_V_pipe_line_tb/total_instructions
add wave -position insertpoint -radix decimal sim:RISC_V_pipe_line_tb/fetched_count
add wave -position insertpoint -radix decimal sim:RISC_V_pipe_line_tb/flush_count

# --- Phân vùng 2: System & Pipeline ---
add wave -divider {=== SYSTEM & PIPELINE ===}
add wave -radix unsigned     /RISC_V_pipe_line_tb/dut/IF_PC
add wave -radix hexadecimal  /RISC_V_pipe_line_tb/dut/IF_Instruction
add wave -radix hexadecimal  /RISC_V_pipe_line_tb/dut/ID_Instruction
add wave -radix hexadecimal  /RISC_V_pipe_line_tb/dut/EX_Instruction

# --- Phân vùng 3: Function Call Registers (ABI) ---
add wave -divider {=== C-CODE REGISTERS ===}
add wave -radix decimal -label "a0 (Return)" /RISC_V_pipe_line_tb/dut/Register_top/Register[10]
add wave -radix decimal -label "a1 (Arg 1)"  /RISC_V_pipe_line_tb/dut/Register_top/Register[11]
add wave -radix decimal -label "a2 (Arg 2)"  /RISC_V_pipe_line_tb/dut/Register_top/Register[12]
add wave -radix decimal -label "a3 (Arg 3)"  /RISC_V_pipe_line_tb/dut/Register_top/Register[13]
add wave -radix decimal -label "a4 (Arg 4)"  /RISC_V_pipe_line_tb/dut/Register_top/Register[14]
add wave -radix decimal -label "ra (Return Addr)" /RISC_V_pipe_line_tb/dut/Register_top/Register[1]
add wave -radix hexadecimal /RISC_V_pipe_line_tb/dut/MEM_Read_data

# --- Phân vùng 4: Hazard & Forwarding ---
add wave -divider {=== HAZARD & FORWARDING ===}
add wave /RISC_V_pipe_line_tb/dut/Forwarding_Unit_top/ForwardA
add wave /RISC_V_pipe_line_tb/dut/Forwarding_Unit_top/ForwardB
add wave /RISC_V_pipe_line_tb/dut/Hazard_Detection_Unit_top/PC_EN
add wave /RISC_V_pipe_line_tb/dut/Hazard_Detection_Unit_top/IF_ID_CLR
add wave /RISC_V_pipe_line_tb/dut/Hazard_Detection_Unit_top/ID_EX_CLR

# --- Phân vùng 5: BTB & Branching ---
add wave -divider {=== BTB & BRANCHING ===}
add wave /RISC_V_pipe_line_tb/dut/IF_BTB_Hit
add wave /RISC_V_pipe_line_tb/dut/Branch_Taken
add wave /RISC_V_pipe_line_tb/dut/EX_Mispredicted
add wave -radix unsigned /RISC_V_pipe_line_tb/dut/Final_Next_Address

# ============================================================================
# THỰC THI & HIỂN THỊ
# ============================================================================

view structure
view signals
view wave

# Chạy mô phỏng cho đến khi gặp lệnh $finish trong Testbench
run -all

# Tự động zoom vừa vặn cửa sổ sóng
wave zoom full

puts ">>> SIMULATION COMPLETED. CHECK WAVEFORMS."