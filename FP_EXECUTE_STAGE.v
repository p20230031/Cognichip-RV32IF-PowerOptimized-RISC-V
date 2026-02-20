`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: FP_EXECUTE_STAGE
// Description: Floating-point execution stage for RV32F
//              Integrates with existing integer execution pipeline
//              Handles FP ALU operations
//////////////////////////////////////////////////////////////////////////////////

module FP_EXECUTE_STAGE(
    // FP register inputs (after forwarding)
    input [31:0] fp_rs1,
    input [31:0] fp_rs2,
    input [31:0] fp_rs3,
    
    // Integer register input (for conversions and moves)
    input [31:0] int_rs1,
    
    // Control signals
    input [4:0] fp_alu_control,
    input [2:0] rm,              // Rounding mode
    input int_to_fp,             // Integer to FP operation
    input fp_to_int,             // FP to integer operation
    input enable,                // POWER OPT: Enable signal to gate FP execution
    
    // Outputs
    output [31:0] fp_result,
    output [4:0] fflags          // Floating-point exception flags
);

    wire [31:0] alu_operand_a;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_operand_c;
    
    // POWER OPT: Gate operand selection when FP execution is disabled
    // This prevents unnecessary mux switching and reduces power
    assign alu_operand_a = enable ? (int_to_fp ? int_rs1 : fp_rs1) : 32'b0;
    assign alu_operand_b = enable ? fp_rs2 : 32'b0;
    assign alu_operand_c = enable ? fp_rs3 : 32'b0;
    
    // Instantiate FP ALU
    FP_ALU fp_alu_inst (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .operand_c(alu_operand_c),
        .fp_alu_control(fp_alu_control),
        .rm(rm),
        .enable(enable),           // POWER OPT: Pass enable to ALU
        .result(fp_result),
        .fflags(fflags)
    );

endmodule
