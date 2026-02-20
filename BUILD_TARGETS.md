# RV32F Processor Build Targets

## File Structure Overview

Your project now has **complete separation** between simulation and synthesis:

### Simulation Files
```
RISC_V_RV32F_PROCESSOR.v       ← Simulation top module
├── FP_EXECUTE_STAGE.v          ← Simulation FP execution
│   └── FP_ALU.v                ← Functional model (uses real arithmetic)
└── (All other modules)
```

### Synthesis Files
```
RISC_V_RV32F_PROCESSOR_SYNTH.v ← Synthesis top module
├── FP_EXECUTE_STAGE_SYNTH.v    ← Synthesis FP execution
│   └── FP_ALU_SYNTH.v          ← Synthesizable placeholder/IP wrapper
└── (All other modules - shared)
```

---

## Build Targets

### 1. Simulation (Functional Verification)

**Target:** `sim_rv32f` or `sim_fp_debug`

**Top Module:** `RISC_V_RV32F_PROCESSOR` (original)

**FP Implementation:** `FP_ALU.v` with IEEE 754 functional arithmetic

**Features:**
- ✅ Full IEEE 754 single-precision arithmetic
- ✅ Accurate results for all FP operations
- ✅ Uses Verilog `real` type for computation
- ✅ Perfect for functional verification
- ❌ NOT synthesizable

**How to Run:**
```bash
# In Vivado/simulator
Target: sim_rv32f  # Regular simulation
Target: sim_fp_debug  # Detailed debug trace
```

---

### 2. Synthesis (FPGA Implementation)

**Target:** `synth_rv32f`

**Top Module:** `RISC_V_RV32F_PROCESSOR_SYNTH`

**FP Implementation:** `FP_ALU_SYNTH.v` with placeholder/IP cores

**Features:**
- ✅ Fully synthesizable
- ✅ No `real` type or unsynthesizable constructs
- ✅ Implements simple operations (move, sign injection)
- ⚠️ Arithmetic operations are PLACEHOLDERS
- ⚠️ Must add vendor FP IP for production

**How to Run:**
```tcl
# In Vivado
synth_design -top RISC_V_RV32F_PROCESSOR_SYNTH
```

---

## Key Differences

| Aspect | Simulation | Synthesis |
|--------|-----------|-----------|
| **Top Module** | RISC_V_RV32F_PROCESSOR | RISC_V_RV32F_PROCESSOR_SYNTH |
| **FP Execute** | FP_EXECUTE_STAGE | FP_EXECUTE_STAGE_SYNTH |
| **FP ALU** | FP_ALU.v (functional) | FP_ALU_SYNTH.v (placeholder) |
| **FP Operations** | Real IEEE 754 arithmetic | Placeholder (returns zeros) |
| **Purpose** | Verify correctness | Check synthesizability |
| **Output** | Correct FP results | Zeros for FP arithmetic |

---

## Files You Can Now Delete

These files are **NO LONGER NEEDED** (duplicates/old versions):

- ❌ `FP_ALU_FUNCTIONAL.v` - Duplicate of FP_ALU.v
- ❌ Any `*_updated.v`, `*_fixed.v` backup files

**Keep only:**
- ✅ `FP_ALU.v` - Simulation
- ✅ `FP_ALU_SYNTH.v` - Synthesis
- ✅ `FP_EXECUTE_STAGE.v` - Simulation
- ✅ `FP_EXECUTE_STAGE_SYNTH.v` - Synthesis
- ✅ `RISC_V_RV32F_PROCESSOR.v` - Simulation top
- ✅ `RISC_V_RV32F_PROCESSOR_SYNTH.v` - Synthesis top

---

## Workflow

### Development & Verification
```
1. Write RTL
2. Run: sim_fp_debug
3. Verify FP operations work correctly
4. Fix bugs if needed
5. Repeat until all tests pass
```

### Synthesis Check
```
1. Run: synth_rv32f
2. Check for synthesis errors
3. Review utilization report
4. Check timing (may fail - FP_ALU is placeholder)
5. Note warnings about placeholder FP operations
```

### Production FPGA Build
```
1. Add Xilinx Floating-Point IP cores
2. Modify FP_ALU_SYNTH.v to instantiate IP
3. Run: synth_rv32f
4. Verify timing closure
5. Run implementation
6. Generate bitstream
```

---

## Quick Commands

### Simulation
```tcl
# Run functional simulation
set_property top tb_RISC_V_RV32F_PROCESSOR [get_filesets sim_1]
launch_simulation

# Or run debug version
set_property top tb_FP_DEBUG [get_filesets sim_1]
launch_simulation
```

### Synthesis
```tcl
# Run synthesis
synth_design -top RISC_V_RV32F_PROCESSOR_SYNTH -part xc7a35tcpg236-1

# Check results
report_utilization
report_timing_summary
```

---

## Expected Results

### Simulation (sim_rv32f / sim_fp_debug)
```
f0 = 0x40400000 (3.0)   ✓
f1 = 0x40000000 (2.0)   ✓
f2 = 0x40A00000 (5.0)   ✓
f3 = 0x3F800000 (1.0)   ✓
f4 = 0x40C00000 (6.0)   ✓
```

### Synthesis (synth_rv32f with placeholder)
```
Synthesis: SUCCESS ✓
Warnings: FP arithmetic returns zeros (expected)
Utilization: ~2500 LUTs, ~1200 FFs
Timing: May not meet constraints (placeholder logic)
```

### Synthesis (synth_rv32f with Xilinx IP)
```
Synthesis: SUCCESS ✓
Utilization: ~8000-12000 LUTs, ~4000-6000 FFs, 5-10 DSP48
Timing: Should meet 100MHz+ (depending on FPGA)
```

---

## Troubleshooting

### "Duplicate module FP_ALU"
- ✅ **Fixed!** Now using separate top modules
- Simulation uses: RISC_V_RV32F_PROCESSOR
- Synthesis uses: RISC_V_RV32F_PROCESSOR_SYNTH

### "Non-constant real-valued expression"
- ✅ **Fixed!** FP_ALU_SYNTH doesn't use `real` type
- Only FP_ALU.v (simulation) uses `real`

### "FP operations return zeros in simulation"
- ❌ **Wrong target!** Use `sim_rv32f`, not `synth_rv32f`
- Synthesis target is for checking synthesizability only

---

## Next Steps

1. ✅ **Run simulation** with `sim_fp_debug` to verify FP forwarding fix
2. ✅ **Run synthesis** with `synth_rv32f` to verify it synthesizes
3. ⚠️ **Add Xilinx FP IP** to FP_ALU_SYNTH.v for production
4. ⚠️ **Re-synthesize** and verify timing closure

---

## File Summary

| File | Purpose | Used In |
|------|---------|---------|
| RISC_V_RV32F_PROCESSOR.v | Simulation top | sim_rv32f, sim_fp_debug |
| RISC_V_RV32F_PROCESSOR_SYNTH.v | Synthesis top | synth_rv32f |
| FP_EXECUTE_STAGE.v | Sim FP execution | Simulation only |
| FP_EXECUTE_STAGE_SYNTH.v | Synth FP execution | Synthesis only |
| FP_ALU.v | Functional FP ALU | Simulation only |
| FP_ALU_SYNTH.v | Synthesizable FP ALU | Synthesis only |
| FP_ALU_FUNCTIONAL.v | OLD duplicate | DELETE THIS |
| All other .v files | Core logic | Both sim and synth |

---

**You're now ready for both simulation AND synthesis!** 🚀

- **For testing:** Use `sim_fp_debug`
- **For synthesis:** Use `synth_rv32f`
