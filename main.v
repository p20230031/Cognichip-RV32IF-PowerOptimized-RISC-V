`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: main
// Description: Top-level main module for RISC-V RV32F processor with VIO and ILA
//              Simplified version - only essential signals
//////////////////////////////////////////////////////////////////////////////////

module main(
    input clk
);

    // Internal wires - processor connections
    wire reset;
    wire [31:0] int_wb_data;
    wire [31:0] fp_wb_data_out;
    wire [4:0] fp_flags_out;
    
    // Processor instantiation (5 ports)
    RISC_V_RV32F_PROCESSOR_POWER_OPT processor(
        clk,
        reset,
        int_wb_data,
        fp_wb_data_out,
        fp_flags_out
    );
    
    // VIO instantiation (5 ports)
    // Ports: clk, probe_in0, probe_in1, probe_in2, probe_out0
    vio_0 vio_inst(
        clk,                // Clock
        int_wb_data,        // probe_in0: Monitor integer writeback
        fp_wb_data_out,     // probe_in1: Monitor FP writeback
        fp_flags_out,       // probe_in2: Monitor FP flags
        reset               // probe_out0: Control reset
    );
    
    // ILA instantiation (5 ports)
    // Ports: clk, probe0, probe1, probe2, probe3
    ila_0 ila_inst(
        clk,                // Clock
        reset,              // probe0: Capture reset
        int_wb_data,        // probe1: Capture integer writeback
        fp_wb_data_out,     // probe2: Capture FP writeback
        fp_flags_out        // probe3: Capture FP flags
    );

endmodule
