`timescale 1ns / 1ps

module tb_tt_im_monishvr_fifo();

    parameter WIDTH = 4, DEPTH = 3;

    // Testbench Signals
    reg clk;
    reg rst_n;
    reg wr_rq, rd_rq;
    wire full, empty;
    reg [WIDTH-1:0] wdata;
    wire [WIDTH-1:0] rdata;

    // Internal FIFO variables for verification
    reg [WIDTH-1:0] fifo [0:DEPTH-1]; 
    reg [$clog2(DEPTH)-1:0] wptr = 0;
    reg [$clog2(DEPTH)-1:0] rptr = 0;

    // Clock divider signals
    wire w_clk;
    wire r_clk;

    // Instantiate the FIFO module with correct port mapping
    tt_um_reemashivva_fifo fifo_inst (
        .clk(clk),
        .rst_n(rst_n),
        .ui_in({4'b0000, wdata}),  // Assign write data to upper bits of ui_in
        .uo_out({full, empty, rdata}),  // Assign full, empty, and read data to output
        .uio_in(8'b0),  
        .uio_out(),
        .uio_oe(),
        .ena(1'b1)  // Always enabled
    );

    

    

    // Generate a clock (10 ns period = 100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        rst_n = 1;
        wr_rq = 0;
        rd_rq = 0;
        wdata = 0;
        
        // Reset sequence
        #10 rst_n = 0;  
        #20 rst_n = 1;  

        // Begin test after reset
        #13 wr_rq = 1;
        rd_rq = 1;

        fork
            // Write operation
            repeat (150) begin
                @(posedge w_clk);
                if (!full) begin
                    wdata = $random() % (2**WIDTH); // Generate random data           
                    fifo[wptr] = wdata;     
                    wptr = (wptr + 1) % DEPTH; 
                end
                #10; 
            end

            // Read operation
            forever begin
                @(posedge r_clk);
                if (!empty && rd_rq) begin               
                    rptr = (rptr + 1) % DEPTH; 
                end
            end
        join        
    end

    initial begin
        
        $dumpfile("fifo.vcd");
        $dumpvars;
    end



endmodule
