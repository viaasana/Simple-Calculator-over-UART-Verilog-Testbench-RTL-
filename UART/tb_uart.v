    `timescale 1us / 1ns

module uart_tb;

    // Parameters
    parameter CLK_FREQ = 50000000;
    parameter BAUD     = 9600;
    parameter BAUD_DIV = CLK_FREQ / BAUD;
    parameter CLK_PERIOD = 0.02; // 50MHz => 20ns clock
    parameter BIT_DURATION = 104.167; // 1/(baud rate) 

    // Clock and Reset
    reg CLK = 0;
    reg RST = 0;

    // Wires between UART0 (TX) and UART1 (RX)
    wire TX_LINE;
    wire [7:0] RX_DATA;

    // TX control
    reg TX_START = 0;
    reg [7:0] TX_DATA;

    // UART TX
    uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) uartTX (
        .CLK(CLK),
        .RST(RST),
        .RX(),
        .TX(TX_LINE),
        .TX_START(TX_START),
        .TX_DATA(TX_DATA),
        .RX_DATA()
    );


    // UART RX
    uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) uartRX (
        .CLK(CLK),
        .RST(RST),
        .RX(TX_LINE),     // RX connected to TX
        .TX(),            // TX unused here
        .TX_START(1'b0),
        .TX_DATA(),
        .RX_DATA(RX_DATA)
    );


    // Task to send data
    task send;
        input [7:0] data;
        begin
            TX_DATA = data;
            TX_START = 1;
            #(BIT_DURATION);
            TX_START = 0;
        end
    endtask

    // Clock generator
    always #(CLK_PERIOD/2) CLK = ~CLK;



    // Test logic
    initial begin
        $monitor("%c", RX_DATA);
        // Initial reset
        RST <= 0;
        #20;
        RST <= 1;

        #(BIT_DURATION);
        send("V");
        #(BIT_DURATION*11);
        send("i");
        #(BIT_DURATION*11);
        send("a");
        #(BIT_DURATION*11);
        send("s");
        #(BIT_DURATION*11);
        send("a");
        #(BIT_DURATION*11);
        send("n");
        #(BIT_DURATION*11);
        send("a");
    end





endmodule
