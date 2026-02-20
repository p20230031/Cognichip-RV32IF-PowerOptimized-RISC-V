# RISC-V Instruction Examples: I-Type and F-Type

## I-Type Instructions (Integer Immediate Operations)

I-Type instructions have the format: `opcode[6:0] | rd[4:0] | funct3[2:0] | rs1[4:0] | imm[11:0]`

### Examples with Encoding:

#### 1. ADDI (Add Immediate)
```assembly
addi x5, x0, 10      # x5 = x0 + 10 = 10
```
**Encoding:** `0x00A00293`
```
imm[11:0]  | rs1 | f3  | rd  | opcode
000000001010|00000|000|00101|0010011
```
**Hex bytes:** `93 02 A0 00`

#### 2. SLTI (Set Less Than Immediate)
```assembly
slti x6, x5, 20      # x6 = (x5 < 20) ? 1 : 0
```
**Encoding:** `0x0142A313`
```
imm[11:0]  | rs1 | f3  | rd  | opcode
000000010100|00101|010|00110|0010011
```
**Hex bytes:** `13 A3 42 01`

#### 3. XORI (XOR Immediate)
```assembly
xori x7, x5, 15      # x7 = x5 ^ 15
```
**Encoding:** `0x00F2C393`
```
imm[11:0]  | rs1 | f3  | rd  | opcode
000000001111|00101|100|00111|0010011
```
**Hex bytes:** `93 C3 F2 00`

#### 4. ORI (OR Immediate)
```assembly
ori x8, x5, 255      # x8 = x5 | 255
```
**Encoding:** `0x0FF2E413`
```
imm[11:0]  | rs1 | f3  | rd  | opcode
000011111111|00101|110|01000|0010011
```
**Hex bytes:** `13 E4 F2 0F`

#### 5. ANDI (AND Immediate)
```assembly
andi x9, x5, 127     # x9 = x5 & 127
```
**Encoding:** `0x07F2F493`
```
imm[11:0]  | rs1 | f3  | rd  | opcode
000001111111|00101|111|01001|0010011
```
**Hex bytes:** `93 F4 F2 07`

#### 6. SLLI (Shift Left Logical Immediate)
```assembly
slli x10, x5, 2      # x10 = x5 << 2
```
**Encoding:** `0x00229513`
```
imm[11:0]  | rs1 | f3  | rd  | opcode
000000000010|00101|001|01010|0010011
```
**Hex bytes:** `13 95 22 00`

#### 7. SRLI (Shift Right Logical Immediate)
```assembly
srli x11, x5, 3      # x11 = x5 >> 3 (logical)
```
**Encoding:** `0x0032D593`
```
imm[11:0]  | rs1 | f3  | rd  | opcode
000000000011|00101|101|01011|0010011
```
**Hex bytes:** `93 D5 32 00`

#### 8. SRAI (Shift Right Arithmetic Immediate)
```assembly
srai x12, x5, 1      # x12 = x5 >>> 1 (arithmetic)
```
**Encoding:** `0x4012D613`
```
imm[11:0]  | rs1 | f3  | rd  | opcode
010000000001|00101|101|01100|0010011
```
**Hex bytes:** `13 D6 12 40`

#### 9. LW (Load Word) - I-Type Load
```assembly
lw x13, 8(x5)        # x13 = Memory[x5 + 8]
```
**Encoding:** `0x0082A683`
```
imm[11:0]  | rs1 | f3  | rd  | opcode
000000001000|00101|010|01101|0000011
```
**Hex bytes:** `83 A6 82 00`

#### 10. JALR (Jump and Link Register) - I-Type Jump
```assembly
jalr x14, 4(x5)      # x14 = PC+4; PC = x5 + 4
```
**Encoding:** `0x00428707`
```
imm[11:0]  | rs1 | f3  | rd  | opcode
000000000100|00101|000|01110|1100111
```
**Hex bytes:** `67 87 42 00`

---

## F-Type Instructions (Floating-Point Operations)

### F-Type Computational (R-Type format)
Format: `funct7[6:0] | rs2[4:0] | rs1[4:0] | funct3[2:0] | rd[4:0] | opcode[6:0]`

### Examples with Encoding:

#### 1. FADD.S (FP Add Single)
```assembly
fadd.s f2, f0, f1    # f2 = f0 + f1
```
**Encoding:** `0x001080D3`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
0000000|00001|00000|000|00010|1010011
```
**Hex bytes:** `D3 80 10 00`

#### 2. FSUB.S (FP Subtract Single)
```assembly
fsub.s f3, f0, f1    # f3 = f0 - f1
```
**Encoding:** `0x081081D3`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
0000100|00001|00000|000|00011|1010011
```
**Hex bytes:** `D3 81 10 08`

#### 3. FMUL.S (FP Multiply Single)
```assembly
fmul.s f4, f0, f1    # f4 = f0 * f1
```
**Encoding:** `0x101082D3`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
0001000|00001|00000|000|00100|1010011
```
**Hex bytes:** `D3 82 10 10`

#### 4. FDIV.S (FP Divide Single)
```assembly
fdiv.s f5, f0, f1    # f5 = f0 / f1
```
**Encoding:** `0x181083D3`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
0001100|00001|00000|000|00101|1010011
```
**Hex bytes:** `D3 83 10 18`

#### 5. FSQRT.S (FP Square Root Single)
```assembly
fsqrt.s f6, f4       # f6 = sqrt(f4)
```
**Encoding:** `0x58020353`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
0101100|00000|00100|000|00110|1010011
```
**Hex bytes:** `53 03 02 58`

#### 6. FMIN.S (FP Minimum)
```assembly
fmin.s f7, f2, f3    # f7 = min(f2, f3)
```
**Encoding:** `0x283103D3`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
0010100|00011|00010|000|00111|1010011
```
**Hex bytes:** `D3 03 31 28`

#### 7. FMAX.S (FP Maximum)
```assembly
fmax.s f8, f2, f4    # f8 = max(f2, f4)
```
**Encoding:** `0x28414453`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
0010100|00100|00010|001|01000|1010011
```
**Hex bytes:** `53 44 41 28`

### F-Type Comparison (Results go to integer register)

#### 8. FEQ.S (FP Equal)
```assembly
feq.s x7, f2, f3     # x7 = (f2 == f3) ? 1 : 0
```
**Encoding:** `0xA03123D3`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
1010000|00011|00010|010|00111|1010011
```
**Hex bytes:** `D3 23 31 A0`

#### 9. FLT.S (FP Less Than)
```assembly
flt.s x8, f3, f2     # x8 = (f3 < f2) ? 1 : 0
```
**Encoding:** `0xA0219453`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
1010000|00010|00011|001|01000|1010011
```
**Hex bytes:** `53 94 21 A0`

#### 10. FLE.S (FP Less Than or Equal)
```assembly
fle.s x9, f3, f2     # x9 = (f3 <= f2) ? 1 : 0
```
**Encoding:** `0xA02184D3`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
1010000|00010|00011|000|01001|1010011
```
**Hex bytes:** `D3 84 21 A0`

### F-Type Conversion

#### 11. FCVT.W.S (FP to Signed Integer)
```assembly
fcvt.w.s x11, f2     # x11 = (int)f2
```
**Encoding:** `0xC00105D3`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
1100000|00000|00010|000|01011|1010011
```
**Hex bytes:** `D3 05 01 C0`

#### 12. FCVT.S.W (Signed Integer to FP)
```assembly
fcvt.s.w f9, x12     # f9 = (float)x12
```
**Encoding:** `0xD0060493`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
1101000|00000|01100|000|01001|1010011
```
**Hex bytes:** `93 04 06 D0`

### F-Type Data Movement

#### 13. FMV.W.X (Move from Integer to FP Register)
```assembly
fmv.w.x f0, x5       # f0 = x5 (bitwise copy)
```
**Encoding:** `0xF00280D3`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
1111000|00000|00101|000|00000|1010011
```
**Hex bytes:** `D3 80 02 F0`

#### 14. FMV.X.W (Move from FP to Integer Register)
```assembly
fmv.x.w x10, f2      # x10 = f2 (bitwise copy)
```
**Encoding:** `0xE0010553`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
1110000|00000|00010|000|01010|1010011
```
**Hex bytes:** `53 05 01 E0`

### F-Type Sign Injection

#### 15. FSGNJ.S (FP Sign Injection)
```assembly
fsgnj.s f10, f0, f1  # f10 = {sign(f1), magnitude(f0)}
```
**Encoding:** `0x20108513`
```
funct7  | rs2  | rs1  | f3  | rd   | opcode
0010000|00001|00000|000|01010|1010011
```
**Hex bytes:** `13 85 10 20`

### F-Type Fused Multiply-Add

#### 16. FMADD.S (Fused Multiply-Add)
```assembly
fmadd.s f10, f0, f1, f2  # f10 = (f0 * f1) + f2
```
**Encoding:** `0x10108543`
```
rs3  |f2|rs2  | rs1  | f3  | rd   | opcode
00010|00|00001|00000|000|01010|1000011
```
**Hex bytes:** `43 85 10 10`

---

## Complete Instruction Memory Example

### Program: Integer and FP Operations

```verilog
// Integer I-Type Instructions
instruction_memory[3:0]   = 32'h00A00293;  // addi x5, x0, 10
instruction_memory[7:4]   = 32'h01400313;  // addi x6, x0, 20
instruction_memory[11:8]  = 32'h006283B3;  // add x7, x5, x6
instruction_memory[15:12] = 32'h40628433;  // sub x8, x5, x6

// Load FP values to integer registers (using LUI)
instruction_memory[19:16] = 32'h404002B7;  // lui x5, 0x40400 (3.0 in FP)
instruction_memory[23:20] = 32'h40000337;  // lui x6, 0x40000 (2.0 in FP)

// Move to FP registers
instruction_memory[27:24] = 32'hF00280D3;  // fmv.w.x f0, x5
instruction_memory[31:28] = 32'hF0030153;  // fmv.w.x f1, x6

// FP Arithmetic
instruction_memory[35:32] = 32'h001080D3;  // fadd.s f2, f0, f1
instruction_memory[39:36] = 32'h081081D3;  // fsub.s f3, f0, f1
instruction_memory[43:40] = 32'h101082D3;  // fmul.s f4, f0, f1
instruction_memory[47:44] = 32'h181083D3;  // fdiv.s f5, f0, f1

// FP Comparisons
instruction_memory[51:48] = 32'hA03123D3;  // feq.s x7, f2, f3
instruction_memory[55:52] = 32'hA0219453;  // flt.s x8, f3, f2

// Conversions
instruction_memory[59:56] = 32'hC00105D3;  // fcvt.w.s x11, f2
instruction_memory[63:60] = 32'hD0060493;  // fcvt.s.w f9, x12
```

---

## Quick Reference Tables

### I-Type Opcodes:
| Instruction Type | Opcode | Example |
|-----------------|--------|---------|
| ADDI, SLTI, XORI, ORI, ANDI, SLLI, SRLI, SRAI | 0010011 | addi x1, x0, 10 |
| LW, LH, LB, LHU, LBU | 0000011 | lw x2, 0(x1) |
| JALR | 1100111 | jalr x1, 0(x2) |

### F-Type Opcodes:
| Instruction Type | Opcode | Example |
|-----------------|--------|---------|
| FADD, FSUB, FMUL, FDIV, etc. | 1010011 | fadd.s f1, f0, f2 |
| FLW (FP Load) | 0000111 | flw f0, 0(x1) |
| FSW (FP Store) | 0100111 | fsw f0, 0(x1) |
| FMADD.S | 1000011 | fmadd.s f3, f0, f1, f2 |
| FMSUB.S | 1000111 | fmsub.s f3, f0, f1, f2 |
| FNMSUB.S | 1001011 | fnmsub.s f3, f0, f1, f2 |
| FNMADD.S | 1001111 | fnmadd.s f3, f0, f1, f2 |

### Funct3 Values for I-Type (OPCODE=0010011):
| funct3 | Instruction |
|--------|-------------|
| 000 | ADDI |
| 010 | SLTI |
| 011 | SLTIU |
| 100 | XORI |
| 110 | ORI |
| 111 | ANDI |
| 001 | SLLI |
| 101 | SRLI/SRAI (bit 30 distinguishes) |

### Funct7 Values for F-Type (OPCODE=1010011):
| funct7 | Instruction |
|--------|-------------|
| 0000000 | FADD.S |
| 0000100 | FSUB.S |
| 0001000 | FMUL.S |
| 0001100 | FDIV.S |
| 0101100 | FSQRT.S |
| 0010000 | FSGNJ.S/FSGNJN.S/FSGNJX.S |
| 0010100 | FMIN.S/FMAX.S |
| 1100000 | FCVT.W.S/FCVT.WU.S |
| 1101000 | FCVT.S.W/FCVT.S.WU |
| 1110000 | FMV.X.W/FCLASS.S |
| 1111000 | FMV.W.X |
| 1010000 | FEQ.S/FLT.S/FLE.S |

---

## IEEE 754 Single-Precision Common Values

| Value | IEEE 754 Hex | Binary Representation |
|-------|--------------|----------------------|
| 0.0 | 0x00000000 | 0 00000000 00000000000000000000000 |
| 1.0 | 0x3F800000 | 0 01111111 00000000000000000000000 |
| 2.0 | 0x40000000 | 0 10000000 00000000000000000000000 |
| 3.0 | 0x40400000 | 0 10000000 10000000000000000000000 |
| -1.0 | 0xBF800000 | 1 01111111 00000000000000000000000 |
| 0.5 | 0x3F000000 | 0 01111110 00000000000000000000000 |
| +Inf | 0x7F800000 | 0 11111111 00000000000000000000000 |
| -Inf | 0xFF800000 | 1 11111111 00000000000000000000000 |
| NaN | 0x7FC00000 | 0 11111111 10000000000000000000000 |

---

## Usage in Instruction Memory

To add these to your INSTRUCTION_MEMORY.v module, use:

```verilog
// I-Type: ADDI x5, x0, 10 (0x00A00293)
instruction_memory[3]<=8'h00;
instruction_memory[2]<=8'hA0;
instruction_memory[1]<=8'h02;
instruction_memory[0]<=8'h93;

// F-Type: FADD.S f2, f0, f1 (0x001080D3)
instruction_memory[7]<=8'h00;
instruction_memory[6]<=8'h10;
instruction_memory[5]<=8'h80;
instruction_memory[4]<=8'hD3;
```

Remember: Your instruction memory uses **big-endian** byte ordering!
