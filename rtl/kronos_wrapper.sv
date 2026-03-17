//////////////////////////////////////////////////////////////////////////////////////////
// Engineer:      Alessandra Dolmeta - alessandra.dolmeta@polito.it                     //
//                                                                                      //                            
// Design Name:    Top level module                                                     //
// Language:       SystemVerilog                                                        //
//                                                                                      //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

module kronos_wrapper 
  import cv32e40px_pkg::*;
  import cv32e40px_core_v_xif_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,

    // eXtension interface
    cv32e40px_if_xif.coproc_compressed xif_compressed_if,
    cv32e40px_if_xif.coproc_issue      xif_issue_if,
    cv32e40px_if_xif.coproc_commit     xif_commit_if,
    cv32e40px_if_xif.coproc_mem        xif_mem_if,
    cv32e40px_if_xif.coproc_mem_result xif_mem_result_if,
    cv32e40px_if_xif.coproc_result     xif_result_if
);


    kronos_top kronos_top_i(
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .xif_compressed_if,
    .xif_issue_if,
    .xif_commit_if,
    .xif_mem_if,
    .xif_mem_result_if,
    .xif_result_if
  );

endmodule

