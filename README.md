# Keccak Loosely Coupled CVA6 Overlay

This branch, `loosely_cva6`, documents and mirrors the **CVA6 integration delta** for the Keccak accelerator.

It is not a full replacement for the upstream CVA6 repository. Instead, it collects the files that changed between the upstream CVA6 `master` branch and the public `keccak_loosely` branch, then explains how the standalone Keccak core was adapted into a **64-bit AXI-mapped peripheral**.

---

## Branch Guide

| Branch | Purpose |
| --- | --- |
| `main` | Software-only Keccak snapshot plus theory overview |
| `loosely-standalone` | Standalone RTL Keccak core and ModelSim flow |
| `loosely_cva6` | CVA6 integration overlay for the loosely coupled 64-bit Keccak accelerator |

---

## Upstream Reference

For the **full runnable CVA6 platform**, use the upstream repository and branch:

- Repository: https://github.com/vlsi-lab/cva6.git
- Branch: `keccak_loosely`
- Direct branch URL: https://github.com/vlsi-lab/cva6/tree/keccak_loosely

Suggested checkout:

```bash
git clone -b keccak_loosely https://github.com/vlsi-lab/cva6.git
cd cva6
```

This branch keeps the **overlay files and documentation**, while the upstream CVA6 repository remains the authoritative source for full build, simulation, FPGA, and dependency management details.

---

## What This Branch Contains

All copied files are mirrored under `cva6/` and come from the tracked diff between:

- upstream baseline: `master`
- integrated branch: `keccak_loosely`

That means this branch contains:

- the full `keccak_ip/` subtree
- the CVA6 files modified to hook the IP into the SoC
- the software tests used to exercise the accelerator
- the extra platform files that were changed together with this integration branch

Two upstream delta items are intentionally not materialized as normal files here:

- `core/cvfpu`, because it is a submodule pointer change in CVA6 rather than a plain source file
- `.gitlab-ci/iti_reference.trace`, because it is a deletion in the upstream branch delta

---

## 1. Start From The Standalone Branch

To understand the Keccak algorithm itself, start from `loosely-standalone`.

That branch shows the clean standalone pipeline:

1. `keccak_f` orchestrates the permutation.
2. `keccak_dp` holds the datapath and round state.
3. `keccak_cu` controls the 24-round execution.
4. `keccak_round` implements $\theta$, $\rho$, $\pi$, $\chi$, and $\iota$.
5. The testbench verifies the permutation on fixed vectors.

In this `loosely_cva6` branch, the same Keccak core logic reappears inside:

- `cva6/keccak_ip/rtl/pkg_keccak.sv`
- `cva6/keccak_ip/rtl/keccak_round.sv`
- `cva6/keccak_ip/rtl/keccak_dp.sv`
- `cva6/keccak_ip/rtl/keccak_cu.sv`
- `cva6/keccak_ip/rtl/keccak_f.sv`

The important conceptual shift is that the standalone module is no longer driven directly by a simple testbench. It is wrapped so that software running on CVA6 can access it through memory-mapped registers.

---

## 2. What Changes For CVA6 Integration

### Hardware Packaging

The loosely coupled CVA6 version adds a new top-level wrapper:

- `cva6/keccak_ip/rtl/keccak_axi_top.sv`

This wrapper does three things:

1. Converts AXI transactions into a register-bus interface with `axi_to_reg`.
2. Exposes a generated register bank through `keccak_reg_top`.
3. Connects the register bank to the standalone `keccak_f` core.

### Register Interface

The register map is defined in:

- `cva6/keccak_ip/keccak.hjson`

The generated software header is:

- `cva6/keccak_ip/sw/keccak_axi.h`

Programming model:

| Register region | Meaning |
| --- | --- |
| `DATA[0..24]` | 25 lanes of the 1600-bit Keccak state |
| `CSREG.START` | Starts a permutation |
| `CSREG.DONE` | Signals completion |

Because CVA6 is used here in a 64-bit configuration, each lane is exposed as a **64-bit memory-mapped register**. This is the main difference from the standalone SoC-oriented version based on shared 32-bit buffers.

### SoC Address Map

The AXI slave slot and base address are added in:

- `cva6/corev_apu/tb/ariane_soc_pkg.sv`

Key integration facts:

- slave enum entry: `Keccak`
- base address: `0x5000_0000`
- window size: `0x1000`

### SoC Instantiation

The Keccak peripheral is instantiated in:

- `cva6/corev_apu/fpga/src/ariane_xilinx.sv`

That file wires the accelerator as a **loosely coupled AXI slave** and connects its interrupt output to the SoC-side logic.

### Build-System Hookup

The new RTL is pulled into the build from:

- `cva6/core/Flist.cva6`
- `cva6/Bender.yml`
- `cva6/Makefile`

Those files are where a student should look if they want to answer the question: _"How does CVA6 know about the new Keccak IP?"_

---

## 3. How Software Uses The IP

The reference software test is:

- `cva6/tests/keccak64/keccak_axi.c`

Its flow is simple and important:

1. Treat `0x5000_0000` as the Keccak base address.
2. Write the 25 input lanes to the `DATA` registers.
3. Set the `START` bit in `CSREG`.
4. Poll the `DONE` bit.
5. Clear `START`.
6. Read back the 25 output lanes.
7. Compare against expected golden values.

The software-only baseline is also kept for comparison:

- `cva6/tests/keccak64/keccak_noopt.c`

That file is useful when explaining to a student what stayed the same algorithmically and what changed architecturally.

Algorithm:

- same Keccak-f[1600] permutation

Architecture:

- standalone software version computes locally on CPU registers and memory
- loosely coupled version offloads the permutation to the AXI peripheral

---

## 4. How To Test The CVA6 Version

Inside the full upstream CVA6 checkout on branch `keccak_loosely`, the simplest student-facing entry point is:

```bash
cd cva6
./tests/keccak64/run.sh
```

That script:

1. sources `verif/sim/setup-env.sh`
2. selects target `cv64a6_imac_crypto`
3. uses the `veri-testharness` flow
4. lets the user choose a C test under `tests/keccak64/`

Recommended first run:

1. choose `keccak_noopt.c` to understand the expected functional result in software
2. choose `keccak_axi.c` to see the same permutation executed through the AXI accelerator

This is the cleanest path for a thesis student who needs both the algorithmic reference and the SoC-accelerated path.

---

## 5. Suggested Reading Order For A Student

### Step A: Understand Keccak itself

- go to branch `loosely-standalone`
- read the standalone RTL hierarchy
- run the standalone ModelSim flow

### Step B: Understand the wrapper

- read `cva6/keccak_ip/rtl/keccak_axi_top.sv`
- read `cva6/keccak_ip/keccak.hjson`
- read `cva6/keccak_ip/sw/keccak_axi.h`

### Step C: Understand the SoC hookup

- read `cva6/corev_apu/tb/ariane_soc_pkg.sv`
- read `cva6/corev_apu/fpga/src/ariane_xilinx.sv`
- read `cva6/core/Flist.cva6`

### Step D: Understand software control

- read `cva6/tests/keccak64/keccak_noopt.c`
- read `cva6/tests/keccak64/keccak_axi.c`
- run `./tests/keccak64/run.sh` in the full upstream CVA6 checkout

---

## Quick Summary

This branch answers two different questions:

1. **How does Keccak work?**
	Use `loosely-standalone`.

2. **How was Keccak adapted into a 64-bit loosely coupled CVA6 peripheral?**
	Use `loosely_cva6`, then cross-check with the upstream CVA6 branch `keccak_loosely`.

If a student remembers only one thing, it should be this:

> the standalone branch explains the **cryptographic engine**, while this branch explains the **AXI wrapper, address map, and software-visible SoC integration**.
