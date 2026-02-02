# =============================================================================
# ModelSim .do file for Keccak-f[1600] Testbench
# =============================================================================
# Usage in ModelSim:
#   1. Open ModelSim
#   2. Change to the directory containing your design files
#   3. Run: do run_keccak_tb.do
# =============================================================================

# Quit any previous simulation
quit -sim

# Create work library if it doesn't exist
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# =============================================================================
# Compile Design Files
# =============================================================================
vlog -work work src/rtl/pkg_keccak.sv
vlog -work work src/rtl/keccak_round.sv
vlog -work work src/rtl/keccak_round_constants_gen.sv
vlog -work work src/rtl/keccak_dp.sv 
vlog -work work src/rtl/keccak_cu.sv
vlog -work work src/rtl/keccak_f.sv

# Compile the testbench
vlog -work work tb/keccak_tb.sv

# =============================================================================
# Elaborate and Load Design
# =============================================================================
vsim -t 1ns -voptargs="+acc" work.keccak_tb

# =============================================================================
# Add Waveforms
# =============================================================================
# Add all signals from testbench
add wave -divider "Clock and Reset"
add wave -position insertpoint sim:/keccak_tb/clk
add wave -position insertpoint sim:/keccak_tb/rst_n

add wave -divider "Control Signals"
add wave -position insertpoint sim:/keccak_tb/start_i
add wave -position insertpoint sim:/keccak_tb/status_d
add wave -position insertpoint sim:/keccak_tb/keccak_intr

add wave -divider "Data"
add wave -position insertpoint -radix hexadecimal sim:/keccak_tb/Din
add wave -position insertpoint -radix hexadecimal sim:/keccak_tb/Dout

add wave -divider "Test Control"
add wave -position insertpoint -radix unsigned sim:/keccak_tb/test_idx
add wave -position insertpoint -radix unsigned sim:/keccak_tb/cycle_cnt
add wave -position insertpoint -radix unsigned sim:/keccak_tb/total_errors
add wave -position insertpoint -radix unsigned sim:/keccak_tb/total_passes

# Add internal DUT signals if needed
# add wave -divider "DUT Internals"
# add wave -position insertpoint sim:/keccak_tb/dut/*

# =============================================================================
# Run Simulation
# =============================================================================
# Configure waveform display
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -timelineunits ns

# Run the simulation
run -all

# Zoom to fit all waveforms
wave zoom full

# =============================================================================
# End of .do file
# =============================================================================
