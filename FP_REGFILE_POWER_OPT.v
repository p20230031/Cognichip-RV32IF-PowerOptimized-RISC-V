`timescale 1ns / 1ps

module FP_REGFILE_POWER_OPT(
    input clock,
    input reset,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rs3,
    input fp_reg_write,
    input [4:0] rd,
    input [31:0] wb_data,
    input read_enable,
    input write_enable,
    output [31:0] FRS1,
    output [31:0] FRS2,
    output [31:0] FRS3
);

    integer i;
    (* ram_style = "distributed" *) reg [31:0] FP_REG [31:0];
    
    assign FRS1 = read_enable ? FP_REG[rs1] : 32'b0;
    assign FRS2 = read_enable ? FP_REG[rs2] : 32'b0;
    assign FRS3 = read_enable ? FP_REG[rs3] : 32'b0;
    
    always @(negedge clock) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                FP_REG[i] <= 32'b0;
            end
        end
        else begin
            if (write_enable && fp_reg_write) begin
                FP_REG[rd] <= wb_data;
            end
        end
    end

endmodule