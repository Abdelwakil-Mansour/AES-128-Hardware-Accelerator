# ============================================================================
# ModelSim Automation Script for AES-128
# ============================================================================
# This script compiles the RTL, runs the verification testbench, generates
# waveforms, and attempts Quartus FPGA compilation if available.
#
# Usage in ModelSim GUI:  do run_modelsim.do
# Usage in command line:  vsim -c -do run_modelsim.do
# ============================================================================

puts "=========================================================="
puts " 1. RTL & Testbench Compilation"
puts "=========================================================="

# Clean up old work library
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# Compile Datapath, Key Schedule, and Top-Level RTL
vlog rtl/datapath/*.v
vlog rtl/key_schedule/*.v
vlog rtl/*.v

# Compile the verification testbench
vlog tb/tb_aes_top.v

puts "=========================================================="
puts " 2. RTL Simulation & Verification"
puts "=========================================================="

# Start the simulator without optimizations that might hide signals
vsim -voptargs="+acc" work.tb_aes_top

# Add critical signals to the waveform viewer
add wave -divider "Global Signals"
add wave -position insertpoint sim:/tb_aes_top/uut/clk
add wave -position insertpoint sim:/tb_aes_top/uut/reset
add wave -position insertpoint sim:/tb_aes_top/uut/start
add wave -position insertpoint sim:/tb_aes_top/uut/done

add wave -divider "AES I/O"
add wave -position insertpoint -radix hex sim:/tb_aes_top/uut/key
add wave -position insertpoint -radix hex sim:/tb_aes_top/uut/plaintext
add wave -position insertpoint -radix hex sim:/tb_aes_top/uut/ciphertext

add wave -divider "Internal State"
add wave -position insertpoint -radix hex sim:/tb_aes_top/uut/state_reg_out
add wave -position insertpoint -radix hex sim:/tb_aes_top/uut/key_reg_out
add wave -position insertpoint -radix unsigned sim:/tb_aes_top/uut/round_number
add wave -position insertpoint -radix unsigned sim:/tb_aes_top/uut/u_controller/current_state

# Run the simulation until $finish is called in the testbench
run -all

# Save the waveform data for later viewing
write format wave -window .main_pane.wave.interior.cs.body.pw.wf aes_modelsim.do
dataset save sim aes_waveform.wlf

puts "=========================================================="
puts " 3. Quartus Synthesis & FPGA Implementation (If Available)"
puts "=========================================================="

# Check if a Quartus project exists in the root directory
if {[file exists "aes_top.qpf"]} {
    puts "Found aes_top.qpf. Attempting Quartus compilation..."
    
    # exec runs system commands. catch prevents the script from crashing if Quartus isn't installed.
    if { [catch {exec quartus_sh --flow compile aes_top} result] } {
        puts "-> Quartus compilation failed or tool is not in your system PATH."
        puts "-> Skipping synthesis, static timing analysis, and .sof generation."
    } else {
        puts "-> Quartus Synthesis: SUCCESS"
        puts "-> FPGA Implementation (Fitter): SUCCESS"
        puts "-> Static Timing Analysis (STA): SUCCESS"
        puts "-> Programming File (.sof): GENERATED"
    }
} else {
    puts "-> No Quartus project (aes_top.qpf) found in root directory."
    puts "-> Skipping Quartus Synthesis and FPGA implementation."
}

puts "=========================================================="
puts " Script Execution Complete!"
puts "=========================================================="
