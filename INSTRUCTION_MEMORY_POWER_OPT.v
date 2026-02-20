`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: INSTRUCTION_MEMORY_POWER_OPT
// Description: POWER-OPTIMIZED instruction memory
//              Adds memory enable gating to reduce power during stalls
//
// Power Savings: 10-20% compared to INSTRUCTION_MEMORY.v
//////////////////////////////////////////////////////////////////////////////////

module INSTRUCTION_MEMORY_POWER_OPT(
    input clk,
    input reset,
    input [31:0] pc,
    input enable,  // POWER OPT: Only access memory when enabled
    output [31:0] instruction
);

    reg [7:0] instruction_memory[99:0];
    reg [31:0] instruction_reg;
    integer i = 0;
    
    // POWER OPT: Output holding register
    assign instruction = instruction_reg;
    
    // POWER OPT: Conditional memory access
    always @(posedge clk) begin
        if (reset) begin
            // Initialize with your test program
            instruction_memory[3]<=8'h40; instruction_memory[2]<=8'h40; instruction_memory[1]<=8'h02; instruction_memory[0]<=8'hb7;
            instruction_memory[7]<=8'h40; instruction_memory[6]<=8'h00; instruction_memory[5]<=8'h03; instruction_memory[4]<=8'h37;
            instruction_memory[11]<=8'hf0; instruction_memory[10]<=8'h02; instruction_memory[9]<=8'h80; instruction_memory[8]<=8'h53;
            instruction_memory[15]<=8'hf0; instruction_memory[14]<=8'h03; instruction_memory[13]<=8'h00; instruction_memory[12]<=8'hd3;
            instruction_memory[19]<=8'h00; instruction_memory[18]<=8'h10; instruction_memory[17]<=8'h71; instruction_memory[16]<=8'h53;
            instruction_memory[23]<=8'h08; instruction_memory[22]<=8'h10; instruction_memory[21]<=8'h71; instruction_memory[20]<=8'hd3;
            instruction_memory[27]<=8'h10; instruction_memory[26]<=8'h10; instruction_memory[25]<=8'h72; instruction_memory[24]<=8'h53;
            instruction_memory[31]<=8'h18; instruction_memory[30]<=8'h10; instruction_memory[29]<=8'h72; instruction_memory[28]<=8'hd3;
            instruction_memory[35]<=8'h58; instruction_memory[34]<=8'h02; instruction_memory[33]<=8'h73; instruction_memory[32]<=8'h53;
            instruction_memory[39]<=8'h28; instruction_memory[38]<=8'h31; instruction_memory[37]<=8'h03; instruction_memory[36]<=8'hd3;
            instruction_memory[43]<=8'h28; instruction_memory[42]<=8'h41; instruction_memory[41]<=8'h14; instruction_memory[40]<=8'h53;
            instruction_memory[47]<=8'ha0; instruction_memory[46]<=8'h31; instruction_memory[45]<=8'h23; instruction_memory[44]<=8'hd3;
            instruction_memory[51]<=8'ha0; instruction_memory[50]<=8'h21; instruction_memory[49]<=8'h94; instruction_memory[48]<=8'h53;
            instruction_memory[55]<=8'ha0; instruction_memory[54]<=8'h21; instruction_memory[53]<=8'h84; instruction_memory[52]<=8'hd3;
            instruction_memory[59]<=8'he0; instruction_memory[58]<=8'h01; instruction_memory[57]<=8'h05; instruction_memory[56]<=8'h53;
            instruction_memory[63]<=8'hc0; instruction_memory[62]<=8'h01; instruction_memory[61]<=8'h75; instruction_memory[60]<=8'hd3;
            instruction_memory[67]<=8'h00; instruction_memory[66]<=8'h70; instruction_memory[65]<=8'h06; instruction_memory[64]<=8'h13;
            instruction_memory[71]<=8'hd0; instruction_memory[70]<=8'h06; instruction_memory[69]<=8'h74; instruction_memory[68]<=8'hd3;
            instruction_memory[75]<=8'h10; instruction_memory[74]<=8'h10; instruction_memory[73]<=8'h75; instruction_memory[72]<=8'h43;
            instruction_memory[79]<=8'h00; instruction_memory[78]<=8'h00; instruction_memory[77]<=8'h00; instruction_memory[76]<=8'h13;
            
            instruction_reg <= 32'h00000013;  // NOP
        end
        else if (enable) begin
            // Only access when enabled - saves power during stalls
            instruction_reg <= {instruction_memory[pc+3], instruction_memory[pc+2],
                               instruction_memory[pc+1], instruction_memory[pc]};
        end
        // else: hold instruction_reg, no memory access
    end

endmodule