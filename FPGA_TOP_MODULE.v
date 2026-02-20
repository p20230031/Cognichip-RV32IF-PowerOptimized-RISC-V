`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: FPGA_TOP_MODULE
// Description: Top-level FPGA wrapper for RISC-V RV32F processor
//              Includes VIO, ILA, and LED blinking demo
//
// Features:
// - VIO for runtime control (reset, enable)
// - ILA for signal capture and debugging
// - LED blinking driven by processor data bus
// - Complete debug infrastructure
//
// Target: Xilinx FPGAs (Artix-7, Zynq, etc.)
//////////////////////////////////////////////////////////////////////////////////

module FPGA_TOP_MODULE(
    input wire clk_100mhz,          // 100MHz input clock from FPGA board
    input wire btn_reset,           // External reset button (active high)
    output wire [7:0] led           // 8 LEDs for visual feedback
);

    //=========================================================================
    // CLOCK AND RESET MANAGEMENT
    //=========================================================================
    wire clk;                       // System clock (can be same as input or divided)
    wire reset_external;            // External reset (from button)
    wire reset_vio;                 // VIO-controlled reset
    wire reset;                     // Combined reset signal
    wire proc_enable_vio;           // VIO-controlled processor enable
    
    // Use 100MHz directly (or add clock divider if needed)
    assign clk = clk_100mhz;
    
    // Debounce external reset button
    reg [19:0] reset_debounce_counter = 0;
    reg reset_debounced = 0;
    
    always @(posedge clk) begin
        if (btn_reset) begin
            reset_debounce_counter <= 20'hFFFFF;
            reset_debounced <= 1'b1;
        end else if (reset_debounce_counter != 0) begin
            reset_debounce_counter <= reset_debounce_counter - 1;
            reset_debounced <= 1'b1;
        end else begin
            reset_debounced <= 1'b0;
        end
    end
    
    assign reset_external = reset_debounced;
    assign reset = reset_external | reset_vio;
    
    //=========================================================================
    // PROCESSOR INSTANTIATION
    //=========================================================================
    wire int_unrecognized;
    wire fp_unrecognized;
    wire [31:0] int_wb_data;
    wire [31:0] fp_wb_data_out;
    wire [4:0] fp_flags_out;
    
    RISC_V_RV32F_PROCESSOR_POWER_OPT processor (
        .clk(clk),
        .reset(reset),
        .int_unrecognized(int_unrecognized),
        .fp_unrecognized(fp_unrecognized),
        .int_wb_data(int_wb_data),
        .fp_wb_data_out(fp_wb_data_out),
        .fp_flags_out(fp_flags_out)
    );
    
    //=========================================================================
    // LED BLINKING CONTROLLER
    //=========================================================================
    // Create a heartbeat LED and data-driven LEDs
    
    // Heartbeat counter (blink LED at ~1Hz)
    reg [26:0] heartbeat_counter = 0;
    reg heartbeat_led = 0;
    
    always @(posedge clk) begin
        if (reset) begin
            heartbeat_counter <= 0;
            heartbeat_led <= 0;
        end else begin
            heartbeat_counter <= heartbeat_counter + 1;
            if (heartbeat_counter == 27'd50_000_000) begin  // Toggle every 0.5s at 100MHz
                heartbeat_counter <= 0;
                heartbeat_led <= ~heartbeat_led;
            end
        end
    end
    
    // Data-driven LEDs (lower 7 bits from writeback data)
    // This creates a visual display of processor activity
    wire [6:0] data_leds;
    assign data_leds = int_wb_data[6:0];
    
    // LED assignment
    assign led[7] = heartbeat_led;                      // LED7: Heartbeat (system alive)
    assign led[6:0] = data_leds;                        // LED6-0: Data from processor
    
    //=========================================================================
    // SIGNAL PROBES FOR ILA (All processor I/O + internal signals)
    //=========================================================================
    wire [255:0] ila_probe;
    
    // Pack all interesting signals into ILA probe
    assign ila_probe[0] = clk;
    assign ila_probe[1] = reset;
    assign ila_probe[2] = int_unrecognized;
    assign ila_probe[3] = fp_unrecognized;
    assign ila_probe[35:4] = int_wb_data;               // [35:4]
    assign ila_probe[67:36] = fp_wb_data_out;           // [67:36]
    assign ila_probe[72:68] = fp_flags_out;             // [72:68]
    assign ila_probe[73] = heartbeat_led;
    assign ila_probe[81:74] = led;                      // [81:74]
    assign ila_probe[82] = proc_enable_vio;
    assign ila_probe[83] = reset_vio;
    assign ila_probe[84] = reset_external;
    assign ila_probe[255:85] = 171'b0;                  // Unused, pad to 256 bits
    
    //=========================================================================
    // VIO (Virtual Input/Output) - Runtime Control
    //=========================================================================
    // VIO provides:
    // - Output probes: View signals in hardware
    // - Input probes: Control signals from Vivado hardware manager
    
    vio_0 vio_inst (
        .clk(clk),
        
        // VIO Outputs (control signals - driven from Vivado)
        .probe_out0(reset_vio),                         // 1-bit: VIO reset control
        .probe_out1(proc_enable_vio),                   // 1-bit: Processor enable
        
        // VIO Inputs (monitoring - visible in Vivado)
        .probe_in0(int_wb_data),                        // 32-bit: Integer writeback data
        .probe_in1(fp_wb_data_out),                     // 32-bit: FP writeback data
        .probe_in2(fp_flags_out),                       // 5-bit: FP flags
        .probe_in3({31'b0, int_unrecognized}),          // 32-bit: Int unrecognized flag
        .probe_in4({31'b0, fp_unrecognized}),           // 32-bit: FP unrecognized flag
        .probe_in5({24'b0, led}),                       // 32-bit: LED status
        .probe_in6({31'b0, heartbeat_led}),             // 32-bit: Heartbeat
        .probe_in7({31'b0, reset})                      // 32-bit: Reset status
    );
    
    //=========================================================================
    // ILA (Integrated Logic Analyzer) - Signal Capture
    //=========================================================================
    // ILA provides waveform capture of all processor signals
    
    ila_0 ila_inst (
        .clk(clk),
        .probe0(ila_probe)                              // 256-bit probe bus
    );
    
    

endmodule
