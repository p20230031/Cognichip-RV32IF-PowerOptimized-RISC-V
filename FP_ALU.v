`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: FP_ALU (Top-level Wrapper)
// Description: Configurable FP ALU wrapper for RV32F extension
//              Automatically selects between functional and synthesis implementations
//              
// USAGE:
//   - For SIMULATION: Uses FP_ALU_FUNCTIONAL (behavioral model with real arithmetic)
//   - For SYNTHESIS: Define SYNTHESIS macro to use FP_ALU_SYNTH (vendor IP placeholder)
//   
// To use synthesis version, add to your compilation:
//   +define+SYNTHESIS  (for simulation tools)
//   Or set SYNTHESIS define in your synthesis script
//
// Power Optimization: Includes enable signal to gate FP operations when not needed
//////////////////////////////////////////////////////////////////////////////////

module FP_ALU(
    input clk,                   // Clock (used by synthesis version only)
    input [31:0] operand_a,      // First operand (IEEE 754 single-precision)
    input [31:0] operand_b,      // Second operand (IEEE 754 single-precision)
    input [31:0] operand_c,      // Third operand for fused ops (IEEE 754)
    input [4:0] fp_alu_control,  // ALU operation control signal
    input [2:0] rm,              // Rounding mode (RNE, RTZ, RDN, RUP, RMM)
    input enable,                // POWER OPT: Enable signal to gate FP execution
    
    output [31:0] result,        // Result (IEEE 754 or integer depending on operation)
    output [4:0] fflags          // Exception flags {NV, DZ, OF, UF, NX}
);

    //=========================================================================
    // CONDITIONAL INSTANTIATION: Simulation vs Synthesis
    //=========================================================================
    
`ifdef SYNTHESIS
    //-------------------------------------------------------------------------
    // SYNTHESIS MODE: Use vendor-specific FPU IP cores
    //-------------------------------------------------------------------------
    FP_ALU_SYNTH fp_alu_inst (
        .clk(clk),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operand_c(operand_c),
        .fp_alu_control(fp_alu_control),
        .rm(rm),
        .enable(enable),
        .result(result),
        .fflags(fflags)
    );
    
`else
    //-------------------------------------------------------------------------
    // SIMULATION MODE: Use functional behavioral model
    //-------------------------------------------------------------------------
    FP_ALU_FUNCTIONAL fp_alu_inst (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operand_c(operand_c),
        .fp_alu_control(fp_alu_control),
        .rm(rm),
        .enable(enable),
        .result(result),
        .fflags(fflags)
    );
    
`endif

endmodule
