`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: INSTRUCTION_FETCH_POWER_OPT  
// Description: POWER-OPTIMIZED instruction fetch stage
//              Integrates power-optimized instruction memory
//////////////////////////////////////////////////////////////////////////////////

module INSTRUCTION_FETCH_POWER_OPT(
    input clk,
    input reset,
    input stall,
    input branch,
    input [31:0] branch_address,
    output reg [31:0] pc,
    output [31:0] instruction
);
    
    wire [31:0] next_pc;
    wire jump;
    wire [31:0] jump_address;
    wire mem_enable;
    
    // PC register
    always @(posedge clk) begin
        if (reset) 
            pc <= 0;
        else if (!stall) 
            pc <= next_pc;
    end
    
    // PC mux
    PC_MUX m1(
        .pc(pc),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch(branch),
        .jump(jump),
        .next_pc(next_pc)
    );
    
    // Jump detection
    jump_detector_and_jump_address j1(
        .pc(pc),
        .instruction(instruction),
        .jump(jump),
        .jump_address(jump_address)
    );
    
    // POWER OPT: Memory enable signal
    assign mem_enable = !stall && !branch;
    
    // POWER-OPTIMIZED instruction memory
    INSTRUCTION_MEMORY_POWER_OPT i_mem(
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .enable(mem_enable),
        .instruction(instruction)
    );
    
endmodule