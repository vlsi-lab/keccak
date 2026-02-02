# Keccak-f[1600] SystemVerilog Implementation

A complete SystemVerilog implementation of the Keccak-f[1600] permutation function for X-HEEP and SHA-3 integration. This repository contains both standalone Keccak core modules and SoC-ready implementations with register interfaces.

## Repository Structure

### [data/](data/)
Contains HJSON register definition files for automated SystemVerilog generation using `reggen`:

- [keccak.hjson](data/keccak.hjson) - Combined register interface definition with 50 shared 32-bit DATA registers
- [keccak_ctrl_regs.hjson](data/keccak_ctrl_regs.hjson) - Control register definitions
- [keccak_data_regs.hjson](data/keccak_data_regs.hjson) - Data register definitions

These files are used to generate register interface modules for seamless SoC integration.

### [soc/](soc/)
SoC-ready Keccak modules with complete integration infrastructure:

#### [soc/rtl_soc/rtl/](soc/rtl_soc/rtl/)
Core Keccak modules for SoC integration:
- [keccak_f.sv](soc/rtl_soc/rtl/keccak_f.sv) - Standalone Keccak-f[1600] permutation core
- [keccak.sv](soc/rtl_soc/rtl/keccak.sv) - Full SHA-3 hashing implementation
- [keccak_buffer.sv](soc/rtl_soc/rtl/keccak_buffer.sv) - Input/output buffer management
- [keccak_cu.sv](soc/rtl_soc/rtl/keccak_cu.sv) - Control unit
- [keccak_dp.sv](soc/rtl_soc/rtl/keccak_dp.sv) - Datapath implementation
- [keccak_round.sv](soc/rtl_soc/rtl/keccak_round.sv) - Single round implementation
- [keccak_round_constants_gen.sv](soc/rtl_soc/rtl/keccak_round_constants_gen.sv) - Round constant generator
- [pkg_keccak.sv](soc/rtl_soc/rtl/pkg_keccak.sv) - Package definitions

#### [soc/rtl_soc/rtl/gen_sv/](soc/rtl_soc/rtl/gen_sv/)
Auto-generated register interface files (from HJSON definitions):
- `keccak_reg_pkg.sv` / `keccak_reg_top.sv` - Combined register interface
- `keccak_ctrl_reg_pkg.sv` / `keccak_ctrl_reg_top.sv` - Control registers
- `keccak_data_reg_pkg.sv` / `keccak_data_reg_top.sv` - Data registers

#### [soc/rtl_soc/wrapper/](soc/rtl_soc/wrapper/)
- [keccak_top.sv](soc/rtl_soc/wrapper/keccak_top.sv) - Top-level wrapper for SoC integration

#### [soc/sw/](soc/sw/)
C header files for software integration:
- `keccak_auto.h` - Combined register definitions
- `keccak_ctrl_auto.h` - Control register definitions
- `keccak_data_auto.h` - Data register definitions

### [src/](src/)
Two RTL implementations with different optimization levels:

#### [src/rtl/](src/rtl/) - Standard Implementation
Standard Keccak implementation with **64-bit round constants**:
- [keccak_f.sv](src/rtl/keccak_f.sv) - Top module instantiating datapath and control unit
- [keccak_dp.sv](src/rtl/keccak_dp.sv) - Datapath managing 24-round permutation
- [keccak_cu.sv](src/rtl/keccak_cu.sv) - Control unit for start/status/interrupt signals
- [keccak_round.sv](src/rtl/keccak_round.sv) - Single round computation (theta, rho, pi, chi, iota)
- [keccak_round_constants_gen.sv](src/rtl/keccak_round_constants_gen.sv) - **64-bit** round constant generator
- [pkg_keccak.sv](src/rtl/pkg_keccak.sv) - Common type definitions and parameters

#### [src/rtl_opt/](src/rtl_opt/) - Optimized Implementation
Area-optimized implementation with **8-bit round constants**:
- Same file structure as `src/rtl/`
- **Key difference**: [keccak_round_constants_gen.sv](src/rtl_opt/keccak_round_constants_gen.sv) uses **8-bit** round constants instead of 64-bit
- Reduced hardware footprint in the iota step for area-constrained designs
- Functionally equivalent to standard implementation

### [tb/](tb/)
- [keccak_tb.sv](tb/keccak_tb.sv) - Comprehensive testbench for functional verification

### [script/](script/)
ModelSim simulation scripts:
- [run.do](script/run.do) - Simulates the standard RTL implementation ([src/rtl/](src/rtl/))
- [run_opt.do](script/run_opt.do) - Simulates the optimized RTL implementation ([src/rtl_opt/](src/rtl_opt/))

## Key Modules

### keccak_f.sv
The top-level Keccak-f[1600] permutation module:
- **Inputs**: 1600-bit state (Din), start signal
- **Outputs**: 1600-bit permuted state (Dout), status, interrupt
- Executes 24 rounds of the Keccak-f permutation
- Suitable for direct X-HEEP integration

### keccak.sv
Full SHA-3 hash function implementation:
- Includes input buffering via `keccak_buffer.sv`
- Manages padding and absorption/squeezing phases
- Implements complete SHA-3 standard

### keccak_round.sv
Implements a single Keccak round with five steps:
1. **Theta** (θ) - XOR column parity
2. **Rho** (ρ) - Bit rotations
3. **Pi** (π) - Lane permutation
4. **Chi** (χ) - Non-linear mixing
5. **Iota** (ι) - Round constant addition

## RTL vs RTL_OPT: Implementation Differences

The primary difference between [src/rtl/](src/rtl/) and [src/rtl_opt/](src/rtl_opt/) is in the **round constant generation**:

| Feature | RTL (Standard) | RTL_OPT (Optimized) |
|---------|----------------|---------------------|
| Round constant width | 64-bit | 8-bit |
| Iota step implementation | Full 64-bit XOR | Optimized 8-bit XOR |
| Hardware area | Larger | Smaller |
| Use case | Performance-oriented | Area-constrained designs |

Both implementations are functionally equivalent and produce identical Keccak-f[1600] outputs.

## SoC Integration Notes

The design uses **50 32-bit registers** for input/output (defined in [keccak_reg_top.sv](soc/rtl_soc/rtl/gen_sv/keccak_reg_top.sv)):
- These registers serve as **shared buffers** for both input and output data
- Software writes input data to these registers, triggers computation via control register, then reads results from the same registers
- The register interface was auto-generated by `reggen` and manually modified to support bidirectional data flow

**Important**: The OBI (Open Bus Interface) distinction between control and data registers is not utilized in the wrapper implementation. All register access uses a unified register interface.

## Simulation Instructions

### Running Standard RTL Simulation
```bash
cd /path/to/keccak
vsim -do script/run.do
```

### Running Optimized RTL Simulation
```bash
cd /path/to/keccak
vsim -do script/run_opt.do
```

Both scripts will:
1. Compile all necessary RTL files
2. Compile the testbench
3. Launch simulation with waveform display
4. Execute all test vectors
5. Report pass/fail results

## Design Features

- Fully synthesizable SystemVerilog
- Asynchronous active-low reset
- Single clock domain design
- Interrupt-driven completion signaling
- Status register for busy/ready indication
- Compatible with X-HEEP platform
- Dual implementations for performance vs area trade-offs

## License

See [LICENSE](LICENSE) for details.

## Authors

- Alessandra Dolmeta - alessandra.dolmeta@polito.it
- Valeria Piscopo - valeria.piscopo@polito.it
- Mattia Mirigaldi - mattia.mirigaldi@polito.it


## References

Based on the Keccak design by Guido Bertoni, Joan Daemen, Michaël Peeters, and Gilles Van Assche.

For more information on Keccak and SHA-3:
- Official Keccak website: https://keccak.team/
- NIST SHA-3 Standard: FIPS 202
