module FIFO#(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
)(
    input wire CLK,
    input wire RST,
    input wire E,
    input wire [DATA_WIDTH-1:0] DATA_IN,
    input wire R_WR, // 1 for write, 0 for read
    output reg [DATA_WIDTH-1:0] DATA_OUT,
    output reg FULL,
    output reg EMPTY
);

    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [$clog2(FIFO_DEPTH)-1:0] top_ptr, bottom_ptr;


    // write to FIFO

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            top_ptr <= 0;
            FULL <=0;
            EMPTY <= 1;
        end else if(E && R_WR && !FULL) begin
            fifo_mem[top_ptr] <= DATA_IN;
            top_ptr <= (top_ptr + 1) % FIFO_DEPTH;
            FULL <= ((top_ptr + 1) % FIFO_DEPTH == bottom_ptr);
            EMPTY <= 0;
        end
    end


    // read from FIFO
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            bottom_ptr <= 0;
            EMPTY <=1;
            FULL <= 0;
        end else if(E && !R_WR && !EMPTY) begin
            DATA_OUT <= fifo_mem[bottom_ptr];
            bottom_ptr <= (bottom_ptr + 1) % FIFO_DEPTH;
            EMPTY <= (((bottom_ptr + 1) % FIFO_DEPTH) == top_ptr);
            FULL <= 0;
        end
    end



endmodule;