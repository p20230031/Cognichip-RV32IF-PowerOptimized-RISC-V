`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2024 05:09:52 AM
// Design Name: 
// Module Name: INSTRUCTION MEMORY
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module INSTRUCTION_MEMORY(
input clk, //clk is taken as input cause asynchrous reset is reported to cause problems
input reset,
input [31:0]pc,
output [31:0]instruction
    );

reg [7:0]instruction_memory[99:0]; // Expanded memory for FP instructions

integer i=0;

assign instruction={instruction_memory[pc+3],instruction_memory[pc+2],instruction_memory[pc+1],instruction_memory[pc]} ; //big endian



//initialize memory using reset --helpful in fpga implementation
always @(posedge clk)
begin
if(reset)
begin





// ===== Integer Instructions (PC 0-19) =====
// 0x00: addi x4,x0,40        (0x02800213)
//instruction_memory[3]<=8'h02;instruction_memory[2]<=8'h80;instruction_memory[1]<=8'h02;instruction_memory[0]<=8'h13;
// 0x04: addi x1,x1,4         (0x00408093)
//instruction_memory[7]<=8'h00;instruction_memory[6]<=8'h40;instruction_memory[5]<=8'h80;instruction_memory[4]<=8'h93;
// 0x08: lw x3,0(x1)          (0x0000a183)
//instruction_memory[11]<=8'h00;instruction_memory[10]<=8'h00;instruction_memory[9]<=8'ha1;instruction_memory[8]<=8'h83;
// 0x0C: sw x3,4(x1)          (0x00312223)
//instruction_memory[15]<=8'h00;instruction_memory[14]<=8'h30;instruction_memory[13]<=8'ha2;instruction_memory[12]<=8'h23;
// 0x10: bne x1,x4,loop       (0xfe409ae3)
//instruction_memory[19]<=8'hfe;instruction_memory[18]<=8'h40;instruction_memory[17]<=8'h9a;instruction_memory[16]<=8'he3;

// ===== Floating-Point Instructions (PC 0x14+) =====

// 0x14: LUI x5, 0x40400   -> 0x404002B7
instruction_memory[3] <= 8'h40;
instruction_memory[2] <= 8'h40;
instruction_memory[1] <= 8'h02;
instruction_memory[0] <= 8'hb7;

// 0x18: LUI x6, 0x40000   -> 0x40000337
instruction_memory[7] <= 8'h40;
instruction_memory[6] <= 8'h00;
instruction_memory[5] <= 8'h03;
instruction_memory[4] <= 8'h37;

// 0x1C: fmv.w.x f0, x5    -> 0xF0028053
instruction_memory[11] <= 8'hf0;
instruction_memory[10] <= 8'h02;
instruction_memory[9]  <= 8'h80;
instruction_memory[8]  <= 8'h53;

// 0x20: fmv.w.x f1, x6    -> 0xF00300d3
instruction_memory[15] <= 8'hf0;
instruction_memory[14] <= 8'h03;
instruction_memory[13] <= 8'h00;
instruction_memory[12] <= 8'hd3;

// 0x24: fadd.s f2, f0, f1 -> 0x00107153
instruction_memory[19] <= 8'h00;
instruction_memory[18] <= 8'h10;
instruction_memory[17] <= 8'h71;
instruction_memory[16] <= 8'h53;

// 0x28: fsub.s f3, f0, f1 -> 0x081071D3
instruction_memory[23] <= 8'h08;
instruction_memory[22] <= 8'h10;
instruction_memory[21] <= 8'h71;
instruction_memory[20] <= 8'hd3;

// 0x2C: fmul.s f4, f0, f1 -> 0x10107253
instruction_memory[27] <= 8'h10;
instruction_memory[26] <= 8'h10;
instruction_memory[25] <= 8'h72;
instruction_memory[24] <= 8'h53;

// 0x30: fdiv.s f5, f0, f1 -> 0x181072D3
instruction_memory[31] <= 8'h18;
instruction_memory[30] <= 8'h10;
instruction_memory[29] <= 8'h72;
instruction_memory[28] <= 8'hd3;

// 0x34: fsqrt.s f6, f4    -> 0x58027353
instruction_memory[35] <= 8'h58;
instruction_memory[34] <= 8'h02;
instruction_memory[33] <= 8'h73;
instruction_memory[32] <= 8'h53;

// 0x38: fmin.s f7, f2, f3 -> 0x283103D3
instruction_memory[39] <= 8'h28;
instruction_memory[38] <= 8'h31;
instruction_memory[37] <= 8'h03;
instruction_memory[36] <= 8'hd3;

// 0x3C: fmax.s f8, f2, f4 -> 0x28411453
instruction_memory[43] <= 8'h28;
instruction_memory[42] <= 8'h41;
instruction_memory[41] <= 8'h14;
instruction_memory[40] <= 8'h53;

// 0x40: feq.s x7, f2, f3  -> 0xA03123D3
instruction_memory[47] <= 8'ha0;
instruction_memory[46] <= 8'h31;
instruction_memory[45] <= 8'h23;
instruction_memory[44] <= 8'hd3;

// 0x44: flt.s x8, f3, f2  -> 0xA0219453
instruction_memory[51] <= 8'ha0;
instruction_memory[50] <= 8'h21;
instruction_memory[49] <= 8'h94;
instruction_memory[48] <= 8'h53;

// 0x48: fle.s x9, f3, f2  -> 0xA02184D3
instruction_memory[55] <= 8'ha0;
instruction_memory[54] <= 8'h21;
instruction_memory[53] <= 8'h84;
instruction_memory[52] <= 8'hd3;

// 0x4C: fmv.x.w x10, f2   -> 0xE0010553 
instruction_memory[59] <= 8'he0;
instruction_memory[58] <= 8'h01;
instruction_memory[57] <= 8'h05;
instruction_memory[56] <= 8'h53;

// 0x50: fcvt.w.s x11, f2  -> 0xc00175d3 
instruction_memory[63] <= 8'hc0;
instruction_memory[62] <= 8'h01;
instruction_memory[61] <= 8'h75;
instruction_memory[60] <= 8'hd3;

// 0x54: addi x12, x0, 7   -> 0x00700613 
instruction_memory[67] <= 8'h00;
instruction_memory[66] <= 8'h70;
instruction_memory[65] <= 8'h06;
instruction_memory[64] <= 8'h13;

// 0x58: fcvt.s.w f9, x12  -> 0xd00674d3
instruction_memory[71] <= 8'hd0;
instruction_memory[70] <= 8'h06;
instruction_memory[69] <= 8'h74;
instruction_memory[68] <= 8'hd3;

// 0x5C: fmadd.s f10, f0, f1, f2 -> 0x10107543
instruction_memory[75] <= 8'h10;
instruction_memory[74] <= 8'h10;
instruction_memory[73] <= 8'h75;
instruction_memory[72] <= 8'h43;

// 0x60: NOP (addi x0, x0, 0) -> 0x00000013
instruction_memory[79] <= 8'h00;
instruction_memory[78] <= 8'h00;
instruction_memory[77] <= 8'h00;
instruction_memory[76] <= 8'h13;

end
end        
endmodule

// ===== Instruction Summary =====
// Integer Instructions:
// 0x00: addi x4,x0,40        - Initialize loop counter
// 0x04: addi x1,x1,4         - Increment pointer
// 0x08: lw x3,0(x1)          - Load word
// 0x0C: sw x3,4(x1)          - Store word
// 0x10: bne x1,x4,loop       - Branch if not equal
//
// Floating-Point Instructions:
// 0x14: li x5, 0x40400000    - Load 3.0 (FP format)
// 0x18: li x6, 0x40000000    - Load 2.0 (FP format)
// 0x1C: fmv.w.x f0, x5       - Move 3.0 to FP reg f0
// 0x20: fmv.w.x f1, x6       - Move 2.0 to FP reg f1
// 0x24: fadd.s f2, f0, f1    - f2 = 3.0 + 2.0 = 5.0
// 0x28: fsub.s f3, f0, f1    - f3 = 3.0 - 2.0 = 1.0
// 0x2C: fmul.s f4, f0, f1    - f4 = 3.0 * 2.0 = 6.0
// 0x30: fdiv.s f5, f0, f1    - f5 = 3.0 / 2.0 = 1.5
// 0x34: fsqrt.s f6, f4       - f6 = sqrt(6.0)
// 0x38: fmin.s f7, f2, f3    - f7 = min(5.0, 1.0)
// 0x3C: fmax.s f8, f2, f4    - f8 = max(5.0, 6.0)
// 0x40: feq.s x7, f2, f3     - x7 = (5.0 == 1.0)
// 0x44: flt.s x8, f3, f2     - x8 = (1.0 < 5.0)
// 0x48: fle.s x9, f3, f2     - x9 = (1.0 <= 5.0)
// 0x4C: fmv.x.w x10, f2      - Move f2 to integer reg
// 0x50: fcvt.w.s x11, f2     - Convert f2 to integer
// 0x54: li x12, 7            - Load integer 7
// 0x58: fcvt.s.w f9, x12     - Convert int to float
// 0x5C: fmadd.s f10, f0, f1, f2 - Fused multiply-add
// 0x60: nop                  - No operation
