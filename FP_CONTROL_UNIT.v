`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: FP_CONTROL_UNIT
// Description: Control unit for RV32F floating-point instructions
//              Decodes FP opcodes and generates control signals
//              Integrates with existing integer control unit
//////////////////////////////////////////////////////////////////////////////////

module FP_CONTROL_UNIT(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input [4:0] rs2_field,     // Used for some FP instructions
    
    output reg is_fp_instr,    // Indicates FP instruction
    output reg [4:0] fp_alu_control,  // FP ALU operation
    output reg fp_reg_read1,   // Read FP register rs1
    output reg fp_reg_read2,   // Read FP register rs2
    output reg fp_reg_read3,   // Read FP register rs3 (for fused ops)
    output reg fp_reg_write,   // Write to FP register
    output reg int_reg_read,   // Read integer register
    output reg int_reg_write,  // Write to integer register
    output reg fp_mem_op,      // FP load/store operation
    output reg fp_to_int,      // FP to integer conversion
    output reg int_to_fp,      // Integer to FP conversion
    output reg unrecognized
);

    // RV32F Opcodes
    localparam OP_FP     = 7'b1010011;  // Floating-point operations
    localparam LOAD_FP   = 7'b0000111;  // FLW (load FP word)
    localparam STORE_FP  = 7'b0100111;  // FSW (store FP word)
    localparam FMADD     = 7'b1000011;  // Fused multiply-add
    localparam FMSUB     = 7'b1000111;  // Fused multiply-sub
    localparam FNMSUB    = 7'b1001011;  // Fused negative multiply-sub
    localparam FNMADD    = 7'b1001111;  // Fused negative multiply-add
    
    // funct7 values for OP_FP
    localparam FADD_S    = 7'b0000000;
    localparam FSUB_S    = 7'b0000100;
    localparam FMUL_S    = 7'b0001000;
    localparam FDIV_S    = 7'b0001100;
    localparam FSQRT_S   = 7'b0101100;
    localparam FSGNJ_S   = 7'b0010000;
    localparam FMINMAX_S = 7'b0010100;
    localparam FCVT_W_S  = 7'b1100000;  // Float to int
    localparam FMV_X_W   = 7'b1110000;  // FP to int register
    localparam FCMP_S    = 7'b1010000;  // FP compare
    localparam FCLASS_S  = 7'b1110000;  // FP classify
    localparam FCVT_S_W  = 7'b1101000;  // Int to float
    localparam FMV_W_X   = 7'b1111000;  // Int register to FP
    
    // ALU control codes (match FP_ALU)
    localparam FP_ADD_OP    = 5'b00000;
    localparam FP_SUB_OP    = 5'b00001;
    localparam FP_MUL_OP    = 5'b00010;
    localparam FP_DIV_OP    = 5'b00011;
    localparam FP_SQRT_OP   = 5'b00100;
    localparam FP_MIN_OP    = 5'b00101;
    localparam FP_MAX_OP    = 5'b00110;
    localparam FP_MADD_OP   = 5'b00111;
    localparam FP_MSUB_OP   = 5'b01000;
    localparam FP_NMADD_OP  = 5'b01001;
    localparam FP_NMSUB_OP  = 5'b01010;
    localparam FP_SGNJ_OP   = 5'b01011;
    localparam FP_SGNJN_OP  = 5'b01100;
    localparam FP_SGNJX_OP  = 5'b01101;
    localparam FP_CVT_W_OP  = 5'b01110;
    localparam FP_CVT_WU_OP = 5'b01111;
    localparam FP_CVT_S_W_OP = 5'b10000;
    localparam FP_CVT_S_WU_OP = 5'b10001;
    localparam FP_MV_X_W_OP = 5'b10010;
    localparam FP_MV_W_X_OP = 5'b10011;
    localparam FP_CLASS_OP  = 5'b10100;
    localparam FP_EQ_OP     = 5'b10101;
    localparam FP_LT_OP     = 5'b10110;
    localparam FP_LE_OP     = 5'b10111;
    
    always @(*) begin
        // Default values
        is_fp_instr = 1'b0;
        fp_alu_control = 5'b0;
        fp_reg_read1 = 1'b0;
        fp_reg_read2 = 1'b0;
        fp_reg_read3 = 1'b0;
        fp_reg_write = 1'b0;
        int_reg_read = 1'b0;
        int_reg_write = 1'b0;
        fp_mem_op = 1'b0;
        fp_to_int = 1'b0;
        int_to_fp = 1'b0;
        unrecognized = 1'b0;
        
        case (opcode)
            LOAD_FP: begin
                // FLW: Load floating-point word
                if (funct3 == 3'b010) begin
                    is_fp_instr = 1'b1;
                    fp_mem_op = 1'b1;
                    fp_reg_write = 1'b1;
                    int_reg_read = 1'b1;  // Base address from int register
                end
                else begin
                    unrecognized = 1'b1;
                end
            end
            
            STORE_FP: begin
                // FSW: Store floating-point word
                if (funct3 == 3'b010) begin
                    is_fp_instr = 1'b1;
                    fp_mem_op = 1'b1;
                    fp_reg_read1 = 1'b1;  // Data from FP register
                    int_reg_read = 1'b1;   // Base address from int register
                end
                else begin
                    unrecognized = 1'b1;
                end
            end
            
            FMADD: begin
                // FMADD: rd = (rs1 * rs2) + rs3
                is_fp_instr = 1'b1;
                fp_alu_control = FP_MADD_OP;
                fp_reg_read1 = 1'b1;
                fp_reg_read2 = 1'b1;
                fp_reg_read3 = 1'b1;
                fp_reg_write = 1'b1;
            end
            
            FMSUB: begin
                // FMSUB: rd = (rs1 * rs2) - rs3
                is_fp_instr = 1'b1;
                fp_alu_control = FP_MSUB_OP;
                fp_reg_read1 = 1'b1;
                fp_reg_read2 = 1'b1;
                fp_reg_read3 = 1'b1;
                fp_reg_write = 1'b1;
            end
            
            FNMSUB: begin
                // FNMSUB: rd = -((rs1 * rs2) - rs3)
                is_fp_instr = 1'b1;
                fp_alu_control = FP_NMSUB_OP;
                fp_reg_read1 = 1'b1;
                fp_reg_read2 = 1'b1;
                fp_reg_read3 = 1'b1;
                fp_reg_write = 1'b1;
            end
            
            FNMADD: begin
                // FNMADD: rd = -((rs1 * rs2) + rs3)
                is_fp_instr = 1'b1;
                fp_alu_control = FP_NMADD_OP;
                fp_reg_read1 = 1'b1;
                fp_reg_read2 = 1'b1;
                fp_reg_read3 = 1'b1;
                fp_reg_write = 1'b1;
            end
            
            OP_FP: begin
                is_fp_instr = 1'b1;
                
                case (funct7)
                    FADD_S: begin
                        fp_alu_control = FP_ADD_OP;
                        fp_reg_read1 = 1'b1;
                        fp_reg_read2 = 1'b1;
                        fp_reg_write = 1'b1;
                    end
                    
                    FSUB_S: begin
                        fp_alu_control = FP_SUB_OP;
                        fp_reg_read1 = 1'b1;
                        fp_reg_read2 = 1'b1;
                        fp_reg_write = 1'b1;
                    end
                    
                    FMUL_S: begin
                        fp_alu_control = FP_MUL_OP;
                        fp_reg_read1 = 1'b1;
                        fp_reg_read2 = 1'b1;
                        fp_reg_write = 1'b1;
                    end
                    
                    FDIV_S: begin
                        fp_alu_control = FP_DIV_OP;
                        fp_reg_read1 = 1'b1;
                        fp_reg_read2 = 1'b1;
                        fp_reg_write = 1'b1;
                    end
                    
                    FSQRT_S: begin
                        fp_alu_control = FP_SQRT_OP;
                        fp_reg_read1 = 1'b1;
                        fp_reg_write = 1'b1;
                    end
                    
                    FSGNJ_S: begin
                        // Sign injection operations
                        fp_reg_read1 = 1'b1;
                        fp_reg_read2 = 1'b1;
                        fp_reg_write = 1'b1;
                        case (funct3)
                            3'b000: fp_alu_control = FP_SGNJ_OP;   // FSGNJ
                            3'b001: fp_alu_control = FP_SGNJN_OP;  // FSGNJN
                            3'b010: fp_alu_control = FP_SGNJX_OP;  // FSGNJX
                            default: unrecognized = 1'b1;
                        endcase
                    end
                    
                    FMINMAX_S: begin
                        fp_reg_read1 = 1'b1;
                        fp_reg_read2 = 1'b1;
                        fp_reg_write = 1'b1;
                        case (funct3)
                            3'b000: fp_alu_control = FP_MIN_OP;  // FMIN
                            3'b001: fp_alu_control = FP_MAX_OP;  // FMAX
                            default: unrecognized = 1'b1;
                        endcase
                    end
                    
                    FCVT_W_S: begin
                        // Float to integer conversion
                        fp_reg_read1 = 1'b1;
                        int_reg_write = 1'b1;
                        fp_to_int = 1'b1;
                        case (rs2_field)
                            5'b00000: fp_alu_control = FP_CVT_W_OP;   // FCVT.W.S
                            5'b00001: fp_alu_control = FP_CVT_WU_OP;  // FCVT.WU.S
                            default: unrecognized = 1'b1;
                        endcase
                    end
                    
                    FCVT_S_W: begin
                        // Integer to float conversion
                        int_reg_read = 1'b1;
                        fp_reg_write = 1'b1;
                        int_to_fp = 1'b1;
                        case (rs2_field)
                            5'b00000: fp_alu_control = FP_CVT_S_W_OP;   // FCVT.S.W
                            5'b00001: fp_alu_control = FP_CVT_S_WU_OP;  // FCVT.S.WU
                            default: unrecognized = 1'b1;
                        endcase
                    end
                    
                    FMV_X_W: begin
                        // Move from FP to integer register
                        if (funct3 == 3'b000) begin
                            fp_alu_control = FP_MV_X_W_OP;
                            fp_reg_read1 = 1'b1;
                            int_reg_write = 1'b1;
                            fp_to_int = 1'b1;
                        end
                        else if (funct3 == 3'b001 && rs2_field == 5'b00000) begin
                            // FCLASS.S
                            fp_alu_control = FP_CLASS_OP;
                            fp_reg_read1 = 1'b1;
                            int_reg_write = 1'b1;
                            fp_to_int = 1'b1;
                        end
                        else begin
                            unrecognized = 1'b1;
                        end
                    end
                    
                    FMV_W_X: begin
                        // Move from integer to FP register
                        if (funct3 == 3'b000) begin
                            fp_alu_control = FP_MV_W_X_OP;
                            int_reg_read = 1'b1;
                            fp_reg_write = 1'b1;
                            int_to_fp = 1'b1;
                        end
                        else begin
                            unrecognized = 1'b1;
                        end
                    end
                    
                    FCMP_S: begin
                        // Floating-point comparison
                        fp_reg_read1 = 1'b1;
                        fp_reg_read2 = 1'b1;
                        int_reg_write = 1'b1;
                        fp_to_int = 1'b1;
                        case (funct3)
                            3'b010: fp_alu_control = FP_EQ_OP;  // FEQ
                            3'b001: fp_alu_control = FP_LT_OP;  // FLT
                            3'b000: fp_alu_control = FP_LE_OP;  // FLE
                            default: unrecognized = 1'b1;
                        endcase
                    end
                    
                    default: begin
                        unrecognized = 1'b1;
                        is_fp_instr = 1'b0;
                    end
                endcase
            end
            
            default: begin
                is_fp_instr = 1'b0;
                unrecognized = 1'b0;  // Let integer control unit handle it
            end
        endcase
    end

endmodule
