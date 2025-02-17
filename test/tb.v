`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
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

  // Replace tt_um_example with your module name:
  tt_um_monishvr_fio (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );
always #5 clk = ~clk;
    
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        ena = 1;
        ui_in = 0;
        uio_in = 0;
        
        // Reset sequence
        #10 rst_n = 1;
        #10 rst_n = 0;
        
        // Write data to FIFO
        ui_in[2] = 1;  // Write enable
        ui_in[3] = 0;  // Read disable
        ui_in[7:4] = 4'b1010; // Data to be written
        #10 ui_in[2] = 0; // Disable write
        
        // Read data from FIFO
        #20 ui_in[2] = 0;  // Write disable
        ui_in[3] = 1;  // Read enable
        #10 ui_in[3] = 0; // Disable read
        
        // Additional test cases
        #20 ui_in[2] = 1; ui_in[7:4] = 4'b1100; #10 ui_in[2] = 0; // Write another data
        #20 ui_in[3] = 1; #10 ui_in[3] = 0; // Read again
        
        // Finish simulation
        #50;
        $stop;
    end
    
    // Monitor output
    initial begin
        $monitor("Time=%0t, Write=%b, Read=%b, Data In=%b, Data Out=%b, Full=%b, Empty=%b", 
                 $time, ui_in[2], ui_in[3], ui_in[7:4], uo_out[5:2], uo_out[0], uo_out[1]);
    end

endmodule
endmodule
