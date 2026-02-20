# RV32F Floating-Point Debug Guide

## Problem Summary
You're seeing incorrect FP writeback data:
- Expected: Multiple FP results (0x40400000, 0x40000000, 0x40A00000, 0x3F800000, etc.)
- Actual: Only seeing 0x40400000, 0x00000000, 0x40400000, 0x00000000 pattern

## Diagnostic Steps

### Step 1: Run Debug Testbench
The `tb_FP_DEBUG.v` testbench I created provides cycle-by-cycle visibility into all pipeline stages.

**To run:**
```bash
# Using your simulator (Vivado, ModelSim, etc.)
# Simulate target: sim_fp_debug
```

### Step 2: What to Look For in Debug Output

The debug testbench prints detailed information for each cycle. Here's what each stage should show:

#### **Cycle 1-5: Reset**
- All stages should show zeros or X values
- FP register file should reset to all zeros

#### **Cycle ~10-15: First LUI instruction (load 3.0 into x5)**
```
[ID] Instr=404002b7  (LUI x5, 0x40400)
[WB] Eventually x5 should contain 0x40400000
```

#### **Cycle ~15-20: fmv.w.x f0, x5 (should transfer 3.0 to f0)**
```
[ID] Instr=f00280d3
     is_fp_instr=1  fp_reg_write_signal=1
     fp_alu_control=10011 (FP_MV_W_X)
     int_to_fp=1

[EX] is_fp_instr=1  fp_reg_write=1  fp_rd=0
     int_rs1=40400000  (source data from x5)
     fp_result=40400000  (should pass through)

[MEM] fp_reg_write=1  fp_rd=0  fp_result=40400000

[WB] fp_reg_write=1  fp_rd=0
     wb_fp_data=40400000
     
[FPREG] f0=40400000  <-- SHOULD SEE THIS!
```

#### **Cycle ~20-25: fadd.s f2, f0, f1 (3.0 + 2.0 = 5.0)**
```
[ID] Instr=001080d3
     is_fp_instr=1  fp_reg_write_signal=1
     fp_alu_control=00000 (FP_ADD)

[EX] is_fp_instr=1  fp_reg_write=1  fp_rd=2
     fp_rs1_fwd=40400000 (3.0)
     fp_rs2_fwd=40000000 (2.0)
     fp_result=40A00000 (5.0) <-- CHECK THIS!

[WB] fp_reg_write=1  fp_rd=2
     wb_fp_data=40A00000
     
[FPREG] f2=40A00000  <-- SHOULD SEE THIS!
```

### Step 3: Common Problems and What to Check

#### **Problem 1: is_fp_instr = 0 (FP instructions not recognized)**
**Symptoms:**
- `is_fp_instr=0` in ID stage for FP instructions
- `fp_reg_write_signal=0` even for FP instructions

**Check:**
1. Verify instruction encoding in `INSTRUCTION MEMORY.v` matches RV32F spec
2. Check FP_CONTROL_UNIT is recognizing opcode `1010011` (0x53)
3. Verify funct7 field is being decoded correctly

**Fix:** Instruction encodings or FP_CONTROL_UNIT decode logic

#### **Problem 2: fp_result is all zeros in EX stage**
**Symptoms:**
- `ex_is_fp_instr=1` but `ex_fp_result=00000000`
- FP_ALU enable might be 0

**Check:**
1. `enable` signal to FP_ALU (should be `ex_is_fp_instr`)
2. FP_ALU inputs (operand_a, operand_b)
3. fp_alu_control value

**Fix:** Check FP_EXECUTE_STAGE instantiation and enable connection

#### **Problem 3: wb_fp_data doesn't reach FP register file**
**Symptoms:**
- WB stage shows correct `wb_fp_data`
- But `[FPREG] f0=00000000` (not updated)

**Check:**
1. `wb_fp_reg_write` signal (should be 1)
2. `wb_fp_rd` value (should match target register)
3. FP_REGFILE instantiation - clock signal, write enable connection

**Fix:** Pipeline register or FP_REGFILE connection issue

#### **Problem 4: Incorrect mux selection in WB**
**Symptoms:**
- `wb_fp_data` is wrong even though `wb_fp_result` is correct
- Might be selecting `wb_fp_read_data` instead

**Check:**
1. `wb_fp_mem_op_reg` value (should be 0 for compute ops, 1 for FLW)
2. WB mux logic: `wb_fp_data = wb_fp_mem_op_reg ? wb_fp_read_data : wb_fp_result`

**Fix:** WB stage mux (already fixed in our changes)

### Step 4: Specific Checks for Your Symptoms

Based on your description (seeing 40400000, 00000000 pattern), likely issues:

#### **Theory 1: FP instructions after first one aren't being recognized**
**Evidence:** Only first `fmv.w.x` works, rest fail
**Check:** Look for `is_fp_instr=0` in ID stage for `fadd.s`, `fsub.s`, etc.
**Cause:** Possibly FP_CONTROL_UNIT not recognizing funct7 values

#### **Theory 2: FP register file not updating**
**Evidence:** `fp_wb_data_out` shows values, but operations use zeros
**Check:** FP register file contents - are values actually being written?
**Cause:** Write enable not active, or clock edge issue

#### **Theory 3: FP ALU not enabled**
**Evidence:** All FP compute operations return zero
**Check:** `enable` signal to FP_ALU in EX stage
**Cause:** `ex_is_fp_instr` not connected properly

### Step 5: Quick Verification Tests

Add these to your debug output to quickly identify the issue:

```verilog
// In testbench, at cycle where fadd.s is in EX stage
if (dut.ex_is_fp_instr && dut.ex_fp_alu_control == 5'b00000) begin
    $display("FADD.S IN EX STAGE:");
    $display("  enable to FP_ALU = %b", dut.fp_execute.enable);
    $display("  operand_a = %h", dut.fp_execute.fp_alu_inst.operand_a);
    $display("  operand_b = %h", dut.fp_execute.fp_alu_inst.operand_b);
    $display("  result = %h", dut.fp_execute.fp_alu_inst.result);
end
```

## Critical Signal Trace Checklist

For each FP instruction, verify this flow:

1. ☐ **ID Stage:**
   - `is_fp_instr = 1`
   - `fp_reg_write_signal = 1` (for most FP ops)
   - `fp_alu_control` has correct value

2. ☐ **EX Stage:**
   - `ex_is_fp_instr = 1`
   - `ex_fp_reg_write = 1`
   - `ex_fp_rd` = correct register number
   - `ex_fp_result` = correct computed value
   - FP_ALU `enable = 1`

3. ☐ **MEM Stage:**
   - `mem_fp_reg_write = 1`
   - `mem_fp_rd` = same as EX
   - `mem_fp_result` = same as EX

4. ☐ **WB Stage:**
   - `wb_fp_reg_write = 1`
   - `wb_fp_rd` = same as MEM
   - `wb_fp_result` = same as MEM
   - `wb_fp_mem_op_reg = 0` (for compute ops)
   - `wb_fp_data` = `wb_fp_result` (not `wb_fp_read_data`)

5. ☐ **FP Register File:**
   - On next negedge clock after WB, register should update
   - `FP_REG[rd]` should contain `wb_fp_data`

## Most Likely Issue

Based on your symptoms, I suspect **the FP_ALU is returning zeros because it's not enabled**.

**Quick Fix Test:**
Check line 462 in RISC_V_RV32F_PROCESSOR.v:
```verilog
FP_EXECUTE_STAGE fp_execute(
    // ... other ports ...
    .enable(ex_is_fp_instr),  // <-- This line
    // ... other ports ...
);
```

If this is missing or connected to the wrong signal, FP_ALU will output zeros.

## Running the Debug

1. Open your simulator
2. Load `sim_fp_debug` target from DEPS.yml
3. Run simulation
4. Search output for "FADD.S" or look at cycle ~25
5. Compare actual values to expected values in this guide
6. Identify which stage has incorrect values
7. Refer to "Common Problems" section for that stage

## Expected Complete Trace

Here's what a correctly working fadd.s should look like across all cycles:

```
Cycle 23: [ID] fadd.s decoded
Cycle 24: [EX] fadd.s executing, fp_result=40A00000
Cycle 25: [MEM] fadd.s in memory stage, fp_result=40A00000
Cycle 26: [WB] fadd.s writing back, wb_fp_data=40A00000
Cycle 27: [FPREG] f2=40A00000 (updated on negedge)
```

If any stage shows zeros or wrong values, that's where the bug is.
