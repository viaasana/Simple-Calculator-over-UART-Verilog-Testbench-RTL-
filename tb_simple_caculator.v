`timescale 1ns/1ps
module tb_simple_caculator;

    parameter CLK_FREQ = 50000000;
    parameter BAUD     = 9600;
    parameter BAUD_DIV = CLK_FREQ / BAUD;
    parameter CLK_PERIOD = 0.02; // 50MHz => 20ns clock
    parameter BIT_DURATION = 104.167; // 1/(baud rate) 

    reg [7:0] tb_data;
    wire [7:0] tb_result_pipeline, tb_result_nonpipeline;
    reg TX_START, E, CLK;
    wire TX_LINE, RX_LINE_for_pipe_line, RX_LINE_for_nonpipeline;
    reg RST = 0;

    // UART for pipeline calculator
    uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) user_use_pipeline (
        .CLK(CLK),
        .RST(RST),
        .RX(RX_LINE_for_pipe_line),
        .TX(TX_LINE),
        .TX_START(TX_START),
        .TX_DATA(tb_data),
        .RX_DATA(tb_result_pipeline),
        .value_intr()
    );

    // UART for non-pipeline calculator
    uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) user_use_nonpipeline (
        .CLK(CLK),
        .RST(RST),
        .RX(RX_LINE_for_nonpipeline),
        .TX(TX_LINE),
        .TX_START(TX_START),
        .TX_DATA(tb_data),
        .RX_DATA(tb_result_nonpipeline),
        .value_intr()
    );

    // Pipeline calculator instance
    simple_caculator_v2 pipelineCalculator(
        .E(E),
        .CLK(CLK),
        .RX(TX_LINE),
        .RST(RST),
        .TX(RX_LINE_for_pipe_line)
    );

    // Non-pipeline calculator instance
    simple_caculator nonpipelineCalculator(
        .E(E),
        .CLK(CLK),
        .RX(TX_LINE),
        .RST(RST),
        .TX(RX_LINE_for_nonpipeline)
    );

    // Task to send UART data
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
        $monitor("%0t ns | Result sent from none-pipline: %d", $time, tb_result_nonpipeline);
        CLK = 0;
        RST = 0;
        TX_START = 0;
        #10;
        RST = 1;
        E = 1;
        #(BIT_DURATION);
        send(8'd5);
        #(BIT_DURATION*11);
        send("+");
        #(BIT_DURATION*15);
        send(8'd10);
        #(BIT_DURATION*16);
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
        #(BIT_DURATION*20);
        send(8'd0);
        #(BIT_DURATION*11);
        send(8'd5);
        #(BIT_DURATION*11);
        send("+");
        #(BIT_DURATION*15);
        send(8'd10);
        #(BIT_DURATION*16);
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
        #(BIT_DURATION*20);
        send(8'd0);
        #(BIT_DURATION*11);
        send(8'd5);
        #(BIT_DURATION*11);
        send("+");
        #(BIT_DURATION*15);
        send(8'd10);
        #(BIT_DURATION*16);
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
        #(BIT_DURATION*20);
        send(8'd0);
        #(BIT_DURATION*11);
        send(8'd5);
        #(BIT_DURATION*11);
        send("+");
        #(BIT_DURATION*15);
        send(8'd10);
        #(BIT_DURATION*16);
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
        #(BIT_DURATION*20);
        send(8'd0);
        #(BIT_DURATION*11);
        send(8'd5);
        #(BIT_DURATION*11);
        send("+");
        #(BIT_DURATION*15);
        send(8'd10);
        #(BIT_DURATION*16);
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
        #(BIT_DURATION*20);
        send(8'd0);
        #(BIT_DURATION*11);
        send(8'd5);
        #(BIT_DURATION*11);
        send("+");
        #(BIT_DURATION*15);
        send(8'd10);
        #(BIT_DURATION*16);
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
        #(BIT_DURATION*20);
        send(8'd0);
        #(BIT_DURATION*11);
    end

endmodule
