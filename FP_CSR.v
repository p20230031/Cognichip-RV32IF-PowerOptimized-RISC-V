`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: FP_CSR
// Description: Floating-point Control and Status Register (FCSR) for RV32F
//              Manages rounding mode (frm) and exception flags (fflags)
//              FCSR = {24'b0, frm[2:0], fflags[4:0]}
//////////////////////////////////////////////////////////////////////////////////

module FP_CSR(
    input clock,
    input reset,
    
    // CSR access interface
    input csr_write,             // Write enable for CSR
    input [11:0] csr_addr,       // CSR address
    input [31:0] csr_wdata,      // Data to write to CSR
    output reg [31:0] csr_rdata, // Data read from CSR
    
    // FP operation interface
    input [4:0] fflags_in,       // Exception flags from FP ALU
    input fflags_valid,          // Valid FP operation completed
    
    // Outputs
    output [2:0] frm,            // Rounding mode for FP operations
    output [4:0] fflags          // Current exception flags
);

    // CSR addresses
    localparam FFLAGS_ADDR = 12'h001;  // Floating-point accrued exceptions
    localparam FRM_ADDR    = 12'h002;  // Floating-point rounding mode
    localparam FCSR_ADDR   = 12'h003;  // Floating-point control and status
    
    // Rounding modes
    localparam RNE = 3'b000;  // Round to Nearest, ties to Even
    localparam RTZ = 3'b001;  // Round towards Zero
    localparam RDN = 3'b010;  // Round Down (towards -infinity)
    localparam RUP = 3'b011;  // Round Up (towards +infinity)
    localparam RMM = 3'b100;  // Round to Nearest, ties to Max Magnitude
    
    // CSR registers
    reg [2:0] frm_reg;     // Rounding mode
    reg [4:0] fflags_reg;  // Accrued exception flags {NV, DZ, OF, UF, NX}
    
    assign frm = frm_reg;
    assign fflags = fflags_reg;
    
    // CSR read logic
    always @(*) begin
        case (csr_addr)
            FFLAGS_ADDR: csr_rdata = {27'b0, fflags_reg};
            FRM_ADDR:    csr_rdata = {29'b0, frm_reg};
            FCSR_ADDR:   csr_rdata = {24'b0, frm_reg, fflags_reg};
            default:     csr_rdata = 32'b0;
        endcase
    end
    
    // CSR write and flag accumulation logic
    always @(posedge clock) begin
        if (reset) begin
            frm_reg <= RNE;      // Default to round-to-nearest-even
            fflags_reg <= 5'b0;  // Clear all flags
        end
        else begin
            // Accumulate exception flags from FP operations (OR accumulation)
            if (fflags_valid) begin
                fflags_reg <= fflags_reg | fflags_in;
            end
            
            // CSR write operations
            if (csr_write) begin
                case (csr_addr)
                    FFLAGS_ADDR: begin
                        fflags_reg <= csr_wdata[4:0];
                    end
                    
                    FRM_ADDR: begin
                        frm_reg <= csr_wdata[2:0];
                    end
                    
                    FCSR_ADDR: begin
                        frm_reg <= csr_wdata[7:5];
                        fflags_reg <= csr_wdata[4:0];
                    end
                endcase
            end
        end
    end

endmodule
