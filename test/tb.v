`timescale 1ns/1ps

module tb();

    // Testbench signals
    reg [7:0] ui_inn;
    wire [7:0] uo_output;
    reg [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg clk, rst_n;
    reg ena;

`ifdef GL_TEST
      .VPWR(1'b1),
      .VGND(1'b0),
`endif
    // Instantiate the FIFO module
    tt_um_monishvr_fifo dut (
        .ui_in(ui_inn),
        .uo_out(uo_output),
        .uio_in(8'b0),
        .uio_out(),
        .uio_oe(),
        .ena(1'b1),
        .clk(clk),
        .rst_n(rst_n)
    );

    
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        ui_in = 0;
        uio_inn = 0;
        
        // Reset sequence
        #10 rst_n = 1;
        #10 rst_n = 0;
        
        // Write data to FIFO
        ui_inn[2] = 1;  // Write enable
        ui_inn[3] = 0;  // Read disable
        ui_inn[7:4] = 4'b1010; // Data to be written
        #10 ui_inn[2] = 0; // Disable write
        
        // Read data from FIFO
        #20 ui_inn[2] = 0;  // Write disable
        ui_inn[3] = 1;  // Read enable
        #10 ui_inn[3] = 0; // Disable read
        
        // Additional test cases
        #20 ui_inn[2] = 1; ui_inn[7:4] = 4'b1100; #10 ui_inn[2] = 0; // Write another data
        #20 ui_inn[3] = 1; #10 ui_inn[3] = 0; // Read again
        
        // Finish simulation
        #50;
        $stop;
    end
    
    // Monitor output
    initial begin
       $dumpfile("syncFifo.vcd");
       $dumpvars(0, tb);    
    end

endmodule
