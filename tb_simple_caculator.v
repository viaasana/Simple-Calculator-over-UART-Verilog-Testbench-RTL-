`timescale 1ns/1ps
module tb_simple_caculator;

    parameter CLK_FREQ = 50000000;
    parameter BAUD     = 9600;
    parameter BAUD_DIV = CLK_FREQ / BAUD;
    parameter CLK_PERIOD = 0.02; // 50MHz => 20ns clock
    parameter BIT_DURATION = 104.167; // 1/(baud rate) 

    reg [7:0] tb_data;
    wire [7:0] tb_result;
    reg TX_START, E, CLK;
    wire TX_LINE, RX_LINE, error;
    reg RST = 0;



    uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) user (
        .CLK(CLK),
        .RST(RST),
        .RX(RX_LINE),
        .TX(TX_LINE),
        .TX_START(TX_START),
        .TX_DATA(tb_data),
        .RX_DATA(tb_result),
        .value_intr()
    );

    simple_caculator uut(
        .E(E),
        .CLK(CLK),
        .RX(TX_LINE),
        .RST(RST),
        .TX(RX_LINE)
    );

    // Task to send data
    task send;
        input [7:0] data;
        begin
            tb_data = data;
            TX_START = 1;
            #(BIT_DURATION);
            TX_START = 0;
        end
    endtask

    always #(CLK_PERIOD/2) CLK = ~CLK;

    initial begin
        $monitor("%0t Result send back: %d", $time, tb_result);
        CLK = 0;
        RST = 0;
        #10;
        RST = 1;
        E = 1;
        #(BIT_DURATION);
        send(8'd5);
        #(BIT_DURATION*11);
        send("+");
        #(BIT_DURATION*11);
        send(8'd10);
        #(BIT_DURATION*11);
        send(8'd30);
        #(BIT_DURATION*11);
        send("-");
        #(BIT_DURATION*11);
        send(8'd20);
        #(BIT_DURATION*11);
        send(8'd15);
        #(BIT_DURATION*11);
        send("x");
        #(BIT_DURATION*11);
        send(8'd10);
        #(BIT_DURATION*11);
        send(8'd50);
        #(BIT_DURATION*11);
        send("/");
        #(BIT_DURATION*11);
        send(8'd5);
        #(BIT_DURATION*11);
        send(8'd15);
        #(BIT_DURATION*11);
        send("/");
        #(BIT_DURATION*11);
        send(8'd0);
        

    end




endmodule
