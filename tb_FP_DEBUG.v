`timescale 1ns / 1ps

module tb_FP_DEBUG;

    reg clk, reset;
    wire int_unrecognized, fp_unrecognized;
    wire [31:0] int_wb_data, fp_wb_data_out;
    wire [4:0] fp_flags_out;
    
    // DUT
    
     RISC_V_RV32F_PROCESSOR_POWER_OPT dut (
        .clk(clk),
        .reset(reset),
        .int_unrecognized(int_unrecognized),
        .fp_unrecognized(fp_unrecognized),
        .int_wb_data(int_wb_data),
        .fp_wb_data_out(fp_wb_data_out),
        .fp_flags_out(fp_flags_out)
    );
   /* RISC_V_RV32F_PROCESSOR dut (
        .clk(clk),
        .reset(reset),
        .int_unrecognized(int_unrecognized),
        .fp_unrecognized(fp_unrecognized),
        .int_wb_data(int_wb_data),
        .fp_wb_data_out(fp_wb_data_out),
        .fp_flags_out(fp_flags_out)
    );*/
    
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;
    
    // Monitor all critical signals
    always @(posedge clk) begin
        $display("================== CYCLE @ %0t ==================", $time);
        
        // IF Stage
        $display("[IF] PC=%h  Instr=%h", dut.if_pc, dut.if_instruction);
        
        // Pipeline control
        $display("[CTRL] stall=%b  mem_branch=%b", dut.stall, dut.mem_branch);
        
        // ID Stage
        $display("[ID] PC=%h  Instr=%h", dut.id_pc, dut.id_instruction);
        $display("     is_fp_instr=%b  fp_reg_write_signal=%b", 
                 dut.id_is_fp_instr, dut.id_fp_reg_write_signal);
        $display("     fp_alu_control=%b  int_to_fp=%b  fp_to_int=%b",
                 dut.id_fp_alu_control, dut.id_int_to_fp, dut.id_fp_to_int);
        
        // EX Stage
        $display("[EX] is_fp_instr=%b  fp_reg_write=%b  fp_rd=%d  int_rd=%d",
                 dut.ex_is_fp_instr, dut.ex_fp_reg_write, dut.ex_fp_rd, dut.ex_rd);
        $display("     fp_result=%h  int_rs1=%h",
                 dut.ex_fp_result, dut.ex_input1);
        $display("     fp_rd_reg=%d  id_fp_rd=%d",
                 dut.ex_fp_rd_reg, dut.id_fp_rd);
        $display("     fp_rs1_fwd=%h  fp_rs2_fwd=%h  fp_rs3_fwd=%h",
                 dut.ex_fp_rs1_fwd, dut.ex_fp_rs2_fwd, dut.ex_fp_rs3_fwd);
        $display("     forward_fp_rs1=%b  forward_fp_rs2=%b  forward_fp_rs3=%b",
                 dut.forward_fp_rs1, dut.forward_fp_rs2, dut.forward_fp_rs3);
        
        // MEM Stage
        $display("[MEM] fp_reg_write=%b  fp_rd=%d  fp_result=%h",
                 dut.mem_fp_reg_write, dut.mem_fp_rd, dut.mem_fp_result);
        $display("      fp_mem_op=%b", dut.mem_fp_mem_op);
        
        // WB Stage
        $display("[WB] fp_reg_write=%b  fp_rd=%d", 
                 dut.wb_fp_reg_write, dut.wb_fp_rd);
        $display("     fp_result=%h  fp_read_data=%h  fp_mem_op=%b",
                 dut.wb_fp_result, dut.wb_fp_read_data, dut.wb_fp_mem_op_reg);
        $display("     wb_fp_data=%h  fp_wb_data_out=%h",
                 dut.wb_fp_data, dut.fp_wb_data_out);
        
        // FP Register File (first 4 registers)
        $display("[FPREG] f0=%h  f1=%h  f2=%h  f3=%h",
                 dut.fp_regfile.FP_REG[0], dut.fp_regfile.FP_REG[1],
                 dut.fp_regfile.FP_REG[2], dut.fp_regfile.FP_REG[3]);
        
        // INT Register File (x5, x6 used for loading)
        $display("[INTREG] x5=%h  x6=%h  x10=%h  x11=%h",
                 dut.int_regfile.GPP[5], dut.int_regfile.GPP[6],
                 dut.int_regfile.GPP[10], dut.int_regfile.GPP[11]);
        
        $display("");
    end
    
    initial begin
        $display("\n===== FP DATAPATH DEBUG TEST =====\n");
        
        reset = 1;
        repeat(3) @(posedge clk);
        reset = 0;
        
        $display("\nReleasing reset, starting execution...\n");
        
        // Run for enough cycles to see several instructions complete
        repeat(50) @(posedge clk);
        
        $display("\n===== FINAL FP REGISTER STATE =====");
        $display("f0 (should be 0x40400000 = 3.0) = %h", dut.fp_regfile.FP_REG[0]);
        $display("f1 (should be 0x40000000 = 2.0) = %h", dut.fp_regfile.FP_REG[1]);
        $display("f2 (should be 0x40A00000 = 5.0) = %h", dut.fp_regfile.FP_REG[2]);
        $display("f3 (should be 0x3F800000 = 1.0) = %h", dut.fp_regfile.FP_REG[3]);
        $display("f4 (should be 0x40C00000 = 6.0) = %h", dut.fp_regfile.FP_REG[4]);
        
        $finish;
    end
    
    // Waveform dump
    initial begin
        $dumpfile("fp_debug.fst");
        $dumpvars(0, tb_FP_DEBUG);
    end

endmodule
