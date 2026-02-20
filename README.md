# Cognichip-RV32IF-PowerOptimized-RISC-V
Cognichip-assisted power-optimized 5-stage RV32IF RISC-V processor with integrated FPU, RTL refactoring, and FPGA validation on Zynq-7000.
Overview
This project presents a Cognichip-assisted, power-optimized RV32IF RISC-V processor based on a 5-stage in-order pipeline.
Starting from a baseline RV32I design, Cognichip was used to:
•	Integrate RV32F Floating-Point Unit (FPU)
•	Fix instruction encoding and writeback issues
•	Perform RTL refactoring and power optimization
•	Apply gating and control optimizations
•	Reduce LUT utilization and dynamic power
•	Generate bitstream and validate on FPGA (Zynq-7000 XC7Z020)
The final design is functionally correct, power-optimized, and FPGA-tested.

Architecture Overview
•	5-stage in-order pipeline: IF → ID → EX → MEM → WB
•	ISA Support:
o	Baseline: RV32I
o	Optimized: RV32I + RV32F (Floating Point)
•	Key Blocks:
o	Integer ALU + FP ALU
o	FP Register File
o	Forwarding Unit (INT + FP)
o	Control Unit + CSR
o	Instruction & Data Memory
•	Power-Optimized Variants:
o	*_POWER_OPT.v modules with gating and reduced switching activity

Repository Structure
 Core RTL
•	RISC_V_RV32F_PROCESSOR_POWER_OPT.v → Top power-optimized CPU
•	RISC_V_PROCESSOR.v → Baseline CPU
•	FPGA_TOP_MODULE.v → FPGA integration top module
•	main.v → Used for synthesis & bitstream generation
 Pipeline Stages
•	INSTRUCTION_FETCH.v, DECODE.v, EXECUTE_STAGE*.v, MEM_STAGE.v, MEM_WB.v, IF_ID.v, ID_EX.v, EX_MEM.v
ALU & FP Units
•	ALU.v, ALU_POWER_OPT.v, ALU_CONTROL.v
•	FP_ALU.v, FP_ALU_FUNCTIONAL.v, FP_ALU_SYNTH.v
•	FP_EXECUTE_STAGE*.v
•	FP_REGFILE.v, FP_REGFILE_POWER_OPT.v
•	FP_CONTROL_UNIT.v, FP_FORWARDING_UNIT.v, FP_FORWARDING_MUXES.v
Control & Support
•	CONTROL_UNIT.v, BRANCH_CONDITION_CHECKER.v, FORWARDING_UNIT.v
•	PC_MUX.v, MUX_3_TO_1.v, STALLING_UNIT.v, stalling_mux.v, SIGN_EXTEND.v, jump_detector.v
•	INSTRUCTION_MEMORY.v, INSTRUCTION_MEMORY_POWER_OPT.v
 Testbenches
•	tb_RISC_V_RV32F_PROCESSOR_POWER_OPT.v Main testbench after power optimization
•	tb_FP_DEBUG.v  FP debug testbench (prints results in TCL console)
 Constraints
•	rv32f_constraints.xdc → Zynq-7000 (XC7Z020CLG484-1) constraints
Docs & Guides
•	RV32F_FIXES_SUMMARY.md
•	POWER_OPTIMIZATION_GUIDE.md
•	POWER_OPT_INTEGRATION_QUICK_START.md
•	POWER_OPT_QUICK_START.md
•	SIMULATION_FIX_README.md
•	FP_DEBUG_GUIDE.md
•	RISC-V_INSTRUCTION_EXAMPLES.md

 How to Run Simulation (Vivado)
Option 1: Full CPU Test
1.	Open Vivado
2.	Add all .v files
3.	Set testbench:
tb_RISC_V_RV32F_PROCESSOR_POWER_OPT.v
4.	Run Behavioral Simulation
5.	Observe:
o	FP results in waveform
o	Correct writeback behavior
o	No unrecognized FP instructions
Option 2: FP Debug Test
1.	Set testbench:
tb_FP_DEBUG.v
2.	Run simulation
3.	Check TCL Console for FP operation outputs

How to Synthesize & Generate Bitstream
1.	Set top module:
main.v
or
FPGA_TOP_MODULE.v
2.	Add constraint file:
rv32f_constraints.xdc
3.	Run:
o	Synthesis
o	Implementation
o	Generate Bitstream
4.	Program FPGA:
o	Zynq-7000 XC7Z020 (ZedBoard / ZC702)

 Results Summary
Functional
•	All RV32F instructions (FADD, FSUB, FMUL, FDIV, FSQRT, FMADD, FCVT, FMV, comparisons) work correctly
•	Writeback and pipeline timing bugs fixed
•	Verified in:
o	Behavioral simulation
o	ILA
o	VIO
o	FPGA hardware
Power & Area
•	Slice LUTs reduced ~7–8% (≈19,355 → ≈17,911)
•	Dynamic power reduced significantly using gating
•	FP datapath only active during FP instructions
•	Better performance-per-area than baseline

 Cognichip Contributions
•	Automatic RV32F RTL generation
•	Instruction encoding fixes
•	Pipeline writeback bug fixes
•	Power-aware refactoring
•	Gated FP execution & operand isolation
•	Faster iteration: Design → Simulate → Synthesize → FPGA in < 1 day

 Tested On
•	Board: Zynq-7000 ZC702 / ZedBoard
•	FPGA: XC7Z020CLG484-1
•	Tool: Vivado 2023.x
