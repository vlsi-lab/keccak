## Notes
- This version uses custom instructions implemented through the CV-X-IF interface.
- The rol_32 instruction is a key enabler for efficient bitwise operations across 64-bit Keccak lanes on 32-bit hardware.
- The integration ensures minimal data movement overhead by tightly coupling the permutation logic to the RISC-V execution pipeline.
- Unlike the coprocessor version, all Keccak-related instructions operate directly on the scalar register file, maintaining ISA compatibility.
- The tightly coupled design offers a strong tradeoff between performance and hardware complexity, and demonstrates the feasibility of efficient post-quantum hashing in constrained environments.