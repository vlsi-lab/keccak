# SystemVerilog Implementation of Keccak

- The design has been updated to use only 50 32-bit registers of in/out.
- The OBI interface is not used in the wrapper, so the distinction between ctrl and data registers is not necessary.
-