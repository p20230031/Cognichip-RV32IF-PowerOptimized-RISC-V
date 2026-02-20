`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: FP_EXECUTE_STAGE_POWER_OPT
// Description: POWER-OPTIMIZED floating-point execution stage
//              Enhanced power gating with result and flag isolation
//////////////////////////////////////////////////////////////////////////////////

module FP_EXECUTE_STAGE_POWER_OPT(
    input [31:0] fp_rs1,
    input [31:0] fp_rs2,
    input [31:0] fp_rs3,
    input [31:0] int_rs1,
    input [4:0] fp_alu_control,
    input [2:0] rm,
    input int_to_fp,
    input fp_to_int,
    input enable,
    output [31:0] fp_result,
    output [4:0] fflags
);

    wire [31:0] alu_operand_a;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_operand_c;
    wire [31:0] alu_result_raw;
    wire [4:0] alu_fflags_raw;
    
    // POWER OPT: Gate operand selection
    assign alu_operand_a = enable ? (int_to_fp ? int_rs1 : fp_rs1) : 32'b0;
    assign alu_operand_b = enable ? fp_rs2 : 32'b0;
    assign alu_operand_c = enable ? fp_rs3 : 32'b0;
    
    // FP ALU instantiation
    FP_ALU fp_alu_inst (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .operand_c(alu_operand_c),
        .fp_alu_control(fp_alu_control),
        .rm(rm),
        .enable(enable),
        .result(alu_result_raw),
        .fflags(alu_fflags_raw)
    );
    
    // POWER OPT: Gate outputs when disabled
    assign fp_result = enable ? alu_result_raw : 32'b0;
    assign fflags = enable ? alu_fflags_raw : 5'b0;

endmodule