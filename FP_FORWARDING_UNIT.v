`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: FP_FORWARDING_UNIT
// Description: Forwarding unit for RV32F floating-point pipeline
//              Detects and resolves data hazards for FP registers
//              Implements forwarding from MEM and WB stages
//////////////////////////////////////////////////////////////////////////////////

module FP_FORWARDING_UNIT(
    // Write-back control signals
    input mem_fp_reg_write,     // MEM stage writing to FP register
    input wb_fp_reg_write,      // WB stage writing to FP register
    
    // Destination registers
    input [4:0] mem_fp_rd,      // MEM stage destination FP register
    input [4:0] wb_fp_rd,       // WB stage destination FP register
    
    // Source registers in EX stage
    input [4:0] ex_fp_rs1,      // EX stage source FP register 1
    input [4:0] ex_fp_rs2,      // EX stage source FP register 2
    input [4:0] ex_fp_rs3,      // EX stage source FP register 3 (for fused ops)
    
    // Instruction type
    input ex_is_fp_instr,       // Current EX instruction is FP
    
    // Forwarding control outputs
    output reg [1:0] forward_fp_rs1,  // 00: no forward, 01: from MEM, 10: from WB
    output reg [1:0] forward_fp_rs2,
    output reg [1:0] forward_fp_rs3
);

    // Forwarding from MEM stage takes priority over WB stage
    
    always @(*) begin
        // Default: no forwarding
        forward_fp_rs1 = 2'b00;
        forward_fp_rs2 = 2'b00;
        forward_fp_rs3 = 2'b00;
        
        if (ex_is_fp_instr) begin
            // Forward FP RS1
            // CRITICAL FIX: Removed (mem_fp_rd != 5'b0) check - f0 is a valid FP register!
            if (mem_fp_reg_write && (mem_fp_rd == ex_fp_rs1)) begin
                forward_fp_rs1 = 2'b01;  // Forward from MEM
            end
            else if (wb_fp_reg_write && (wb_fp_rd == ex_fp_rs1)) begin
                forward_fp_rs1 = 2'b10;  // Forward from WB
            end
            
            // Forward FP RS2
            if (mem_fp_reg_write && (mem_fp_rd == ex_fp_rs2)) begin
                forward_fp_rs2 = 2'b01;  // Forward from MEM
            end
            else if (wb_fp_reg_write && (wb_fp_rd == ex_fp_rs2)) begin
                forward_fp_rs2 = 2'b10;  // Forward from WB
            end
            
            // Forward FP RS3 (for fused multiply-add operations)
            if (mem_fp_reg_write && (mem_fp_rd == ex_fp_rs3)) begin
                forward_fp_rs3 = 2'b01;  // Forward from MEM
            end
            else if (wb_fp_reg_write && (wb_fp_rd == ex_fp_rs3)) begin
                forward_fp_rs3 = 2'b10;  // Forward from WB
            end
        end
    end

endmodule
