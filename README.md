# Keccak Software-Only Repository

This `main` branch now contains only the software Keccak implementation used for thesis development and validation.

## Keccak Theory (Short Overview)

Keccak is the permutation-based cryptographic design standardized as SHA-3. Its core primitive is the Keccak-f permutation operating on a 1600-bit state arranged as a 5x5 matrix of 64-bit lanes.

For each round, the state is transformed by five steps:
1. Theta ($\theta$): mixes columns by XORing each bit with parities from neighboring columns.
2. Rho ($\rho$): rotates each lane by a fixed offset.
3. Pi ($\pi$): permutes lane positions.
4. Chi ($\chi$): applies a non-linear row-wise boolean layer.
5. Iota ($\iota$): injects a round constant into one lane.

The repeated composition of these steps provides diffusion, confusion, and resistance against known generic attacks.

## What Is In `main`

- `sw/main.c`: software-side Keccak usage/example
- `sw/Makefile`: software build flow

## Branches

- `main`: software-only Keccak snapshot and theory notes
- `loosely-standalone`: standalone RTL core and ModelSim verification flow
- `loosely_cva6`: loosely coupled 64-bit CVA6 integration overlay and usage notes

## Looking For More Than The Software Snapshot?

For the standalone RTL Keccak module, testbench, and ModelSim scripts, use:

- `loosely-standalone`

Use:

```bash
git checkout loosely-standalone
```

That branch README keeps the complete standalone module description and simulation workflow.

For the loosely coupled CVA6 integration overlay, use:

- `loosely_cva6`

```bash
git checkout loosely_cva6
```

That branch explains how the standalone Keccak core is wrapped as a 64-bit AXI-mapped peripheral and how it is used and tested inside the CVA6 flow.
