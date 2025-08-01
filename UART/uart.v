module uart#(
    parameter CLK_FREQ = 50000000,
    parameter BAUD = 9600
)(
    input wire CLK,
    input wire RST,
    input wire RX,
    input wire TX_START,
    input wire [7:0] TX_DATA,
    input wire ACK,
    output reg TX,
    output reg [7:0] RX_DATA,
    output reg value_intr
);

    parameter BAUD_DIV = CLK_FREQ / BAUD; // this mean how many CLK then read/wire one bit;

    reg tx_baud_tick = 0;
    reg [15:0] tx_baud_cnt = 0;

    reg rx_baud_tick = 0;
    reg [15:0] rx_baud_cnt = 0;

    reg [1:0] tx_state = 2'b0;
    reg [2:0] tx_bit_cnt = 3'b0;
    reg [7:0] tx_buffer = 8'bz;

    reg [1:0] rx_state = 2'b0;
    reg [7:0] rx_buffer = 8'bz;
    reg [2:0] rx_bit_cnt = 3'b0;

    // reset logic
    always @(negedge RST) begin
        if(!RST) begin
            rx_buffer <= 8'bz;
            tx_buffer <= 8'bz;
        end else begin
            rx_buffer <= rx_buffer; 
            tx_buffer <= tx_buffer;
        end
    end



    // ACK logic - this is used to signal that the data has been received and processed by the receiver
    always @(posedge CLK) begin
        if (ACK) begin
            value_intr <= 0;
        end else begin
            value_intr <= value_intr; // keep the interrupt signal high until ACK is received
        end
    end



    //BAUD RATE GENERATOR
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            rx_baud_tick <=0;
            rx_baud_cnt <= 16'b0;
        end else if(rx_baud_cnt >= BAUD_DIV-1) begin
            rx_baud_cnt <= 16'b0;
            rx_baud_tick <= 1;
        end else begin
            rx_baud_tick <= 0;
            rx_baud_cnt <= rx_baud_cnt + 1;
        end
    end

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            tx_baud_tick <=0;
            tx_baud_cnt <= 16'b0;
        end else if(tx_baud_cnt >= BAUD_DIV-1) begin
            tx_baud_cnt <= 16'b0;
            tx_baud_tick <= 1;
        end else begin
            tx_baud_tick <= 0;
            tx_baud_cnt <= tx_baud_cnt + 1;
        end
    end


    //TX
    always @(posedge CLK) begin
        case (tx_state)

            0: if(TX_START) begin
                tx_baud_cnt <= BAUD_DIV >> 1;
                tx_baud_tick <= 0;
                tx_buffer <= TX_DATA;
                TX <= 0;
                tx_bit_cnt <= 0;
                tx_state <= 2'd1;
            end else
                TX <= 1;

            1: if(tx_baud_tick) begin
                TX <= tx_buffer[tx_bit_cnt];
                tx_bit_cnt <= tx_bit_cnt + 1;
                tx_state <= (tx_bit_cnt==7)? 2'd2: 2'd1;
            end

            2: if(tx_baud_tick) begin
                TX <= 1;
                tx_state <=2'd0;
            end

        endcase
    end


    //RX
    always @(posedge CLK) begin


        case (rx_state)

            0: if(~RX) begin
                rx_baud_cnt <= BAUD_DIV >> 1; // wait ahalf of bit
                rx_baud_tick <=0;
                rx_state <= 2'd1;
                rx_bit_cnt <= 3'd0;
                value_intr <= 0;
            end else begin
                value_intr <= 0;
            end

            1: if(rx_baud_tick) begin
                rx_buffer[rx_bit_cnt] <= RX;
                rx_bit_cnt <= rx_bit_cnt + 1;
                if(rx_bit_cnt == 7)
                    rx_state <= 2'd2;
            end

            2: if(rx_baud_tick) begin
                RX_DATA <= rx_buffer;
                rx_state <= RX?0:2;
                value_intr <= 1; // signal that we have a new value
            end

        endcase

    end



endmodule
