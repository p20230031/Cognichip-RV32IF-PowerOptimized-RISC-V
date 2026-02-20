`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: FP_REGFILE
// Description: 32-register floating-point register file for RV32F
//              Supports dual-read, single-write operations
//              Compatible with IEEE 754 single-precision (32-bit) format
//////////////////////////////////////////////////////////////////////////////////

module FP_REGFILE(
    input clock,
    input reset,
    
    // Read ports
    input [4:0] rs1,          // Source register 1 address
    input [4:0] rs2,          // Source register 2 address
    input [4:0] rs3,          // Source register 3 address (for fused operations)
    
    // Write port
    input fp_reg_write,       // Write enable
    input [4:0] rd,           // Destination register address
    input [31:0] wb_data,     // Write-back data
    
    // Read outputs
    output [31:0] FRS1,       // Source register 1 data
    output [31:0] FRS2,       // Source register 2 data
    output [31:0] FRS3        // Source register 3 data
);

    integer i;
    
    // Floating-point register bank (32 registers, 32-bit each)
    // Using distributed RAM for FPGA efficiency
    (* ram_style = "distributed" *) reg [31:0] FP_REG [31:0];
    
    // Asynchronous read (combinational)
    assign FRS1 = FP_REG[rs1];
    assign FRS2 = FP_REG[rs2];
    assign FRS3 = FP_REG[rs3];
    
    // Synchronous write on negative edge (matches integer register file)
    always @(negedge clock) begin
        if (reset) begin
            // Initialize all FP registers to zero on reset
            for (i = 0; i < 32; i = i + 1) begin
                FP_REG[i] <= 32'b0;
            end
        end
        else begin
            if (fp_reg_write) begin
                FP_REG[rd] <= wb_data;
            end
        end
    end

endmodule
