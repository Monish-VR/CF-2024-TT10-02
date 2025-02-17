`timescale 1ns/1ps
`default_nettype none


// Define FIFO parameters


module tt_um_monishvr_fifo (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // Always 1 when the design is powered
    input  wire       clk,      // Clock signal
    input  wire       rst_n     // Active-low reset
);

parameter abits = 3; // Number of address bits
parameter dbits = 4; // Number of data bits

// FIFO control signals
wire full, empty;
wire wr = ui_in[2];  // Write signal
wire rd = ui_in[3];  // Read signal

// Data input register
reg [dbits-1:0] din;
wire [dbits-1:0] dout;

// Assign input data bits
always @(*) begin
    din[0] = ui_in[4];
    din[1] = ui_in[5];
    din[2] = ui_in[6];
    din[3] = ui_in[7];
end

// Assign unused IOs to prevent warnings
assign uio_out = 0;
assign uio_oe  = 0;
assign uo_out = {2'b00, dout[dbits-1:0], empty, full};

wire _unused = &{ena, ui_in[0], ui_in[1], uio_in[7:0]};

// Debounce logic for write and read signals
wire db_wr, db_rd;
wire wr_en, rd_en;
reg dffw1, dffw2, dffr1, dffr2;
reg [dbits-1:0] out;

// Debouncing write signal
always @ (posedge clk) dffw1 <= wr; 
always @ (posedge clk) dffw2 <= dffw1;
assign db_wr = ~dffw1 & dffw2;

// Debouncing read signal
always @ (posedge clk) dffr1 <= rd;
always @ (posedge clk) dffr2 <= dffr1;
assign db_rd = ~dffr1 & dffr2;

// FIFO memory and control registers
reg [dbits-1:0] regarray[2**abits-1:0]; // FIFO storage
reg [abits-1:0] wr_reg, wr_next, wr_succ; // Write pointer
reg [abits-1:0] rd_reg, rd_next, rd_succ; // Read pointer
reg full_reg, empty_reg, full_next, empty_next;

// Write enable condition
assign wr_en = db_wr & ~full;
assign rd_en = db_rd & ~empty;
// Write operation
always @ (posedge clk) begin
    if(wr_en)
        regarray[wr_reg] <= din;
end

// Read operation
always @ (posedge clk) begin
    if(rd_en)
        out <= regarray[rd_reg];
end

// Synchronous reset and FIFO state updates
always @ (posedge clk or posedge rst_n) begin
    if (rst_n) begin
        wr_reg <= 0;
        rd_reg <= 0;
        full_reg <= 1'b0;
        empty_reg <= 1'b1;
    end else begin
        wr_reg <= wr_next;
        rd_reg <= rd_next;
        full_reg <= full_next;
        empty_reg <= empty_next;
    end
end

// FIFO control logic
always @(*) begin
    // Default values
    wr_succ = wr_reg + 1;
    rd_succ = rd_reg + 1;
    wr_next = wr_reg;
    rd_next = rd_reg;
    full_next = full_reg;
    empty_next = empty_reg;
    
    case({db_wr, db_rd})
        2'b01: begin // Read operation
            if (~empty) begin
                rd_next = rd_succ;
                full_next = 1'b0;
                if (rd_succ == wr_reg)
                    empty_next = 1'b1; // FIFO becomes empty
            end
        end
        
        2'b10: begin // Write operation
            if (~full) begin
                wr_next = wr_succ;
                empty_next = 1'b0;
                if (wr_succ == (2**abits-1))
                    full_next = 1'b1; // FIFO becomes full
            end
        end
        
        2'b11: begin // Simultaneous read and write
            wr_next = wr_succ;
            rd_next = rd_succ;
        end
    endcase
end

// Output assignments
assign full = full_reg;
assign empty = empty_reg;
assign dout = out;

endmodule
