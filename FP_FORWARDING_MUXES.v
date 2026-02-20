`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: FP_FORWARDING_MUXES
// Description: 3-to-1 multiplexer for floating-point forwarding
//              Selects between register file output, MEM stage, or WB stage
//////////////////////////////////////////////////////////////////////////////////

module FP_FORWARDING_MUXES(
    input [31:0] reg_data,       // Data from FP register file
    input [31:0] mem_data,       // Forwarded data from MEM stage
    input [31:0] wb_data,        // Forwarded data from WB stage
    input [1:0] forward_sel,     // Forwarding select signal
    
    output reg [31:0] out_data   // Selected output data
);

    always @(*) begin
        case (forward_sel)
            2'b00: out_data = reg_data;   // No forwarding, use register file
            2'b01: out_data = mem_data;   // Forward from MEM stage
            2'b10: out_data = wb_data;    // Forward from WB stage
            default: out_data = reg_data; // Default to register file
        endcase
    end

endmodule
