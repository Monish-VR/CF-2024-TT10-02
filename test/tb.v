`default_nettype none
`timescale 1ns / 1ps

/* Testbench for tt_um_monishvr_fifo module */
module tb ();

  // Dump the signals to a VCD file for waveform analysis
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Clock and reset signals
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Instantiate the FIFO module
  tt_um_monishvr_fifo user_project (
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // Enable signal
      .clk    (clk),      // Clock signal
      .rst_n  (rst_n)     // Active-low reset
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    // Initialize signals
    clk = 0;
    rst_n = 0;
    ena = 1;
    ui_in = 0;
    uio_in = 0;

    // Reset sequence
    #10 rst_n = 1;
    #10;

    // Write data to FIFO
    ui_in = 8'b00011100; // Enable write signal with data bits
    #10 ui_in[2] = 1; // Write pulse
    #10 ui_in[2] = 0;
    #20;

    // Read data from FIFO
    ui_in[3] = 1; // Read pulse
    #10 ui_in[3] = 0;
    #20;

    // Finish simulation
    #100;
    $finish;
  end

endmodule
