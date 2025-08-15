module tb_FIFO;

    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;

    reg CLK;
    reg RST;
    reg [DATA_WIDTH-1:0] DATA_IN;
    reg WRITE_EN;
    wire [DATA_WIDTH-1:0] DATA_OUT;
    reg READ_EN;
    wire FULL;
    wire EMPTY;

    FIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) uut (
        .CLK(CLK),
        .RST(RST),
        .E(1'b1), // Enable FIFO
        .DATA_IN(DATA_IN),
        .R_WR(WRITE_EN),
        .DATA_OUT(DATA_OUT),
        .FULL(FULL),
        .EMPTY(EMPTY)
    );

    initial begin
        CLK = 0;
        RST = 0;
        WRITE_EN = 0;
        DATA_IN = 0;

        #5 RST = 1; // Release reset
        #5 WRITE_EN = 1; DATA_IN = 8'hA5; CLK = 1; // Write data
        #5 CLK = 0; // Clock cycle
        #5 WRITE_EN = 1; DATA_IN = 8'h5A; CLK = 1; // Write more data
        #5 CLK = 0; // Clock cycle
        #5 WRITE_EN = 1; DATA_IN = 8'h6A; CLK = 1; // Write more data
        #5 CLK = 0; // Clock cycle
        #5 WRITE_EN = 1; DATA_IN = 8'hA6; CLK = 1; // Write more data
        #5 CLK = 0; // Clock cycle
        #5 WRITE_EN = 1; DATA_IN = 8'h99; CLK = 1; // Write more data
        #5 CLK = 0; // Clock cycle
        #10 WRITE_EN = 0; CLK = 1; // Stop writing
        #5 CLK = 0; // Clock cycle
        #5 CLK = 1;
        #5 CLK = 0; // Clock cycle
        #5 CLK = 1;
        #5 CLK = 0; // Clock cycle
        #5 CLK = 1;

        #20;
    end


endmodule;