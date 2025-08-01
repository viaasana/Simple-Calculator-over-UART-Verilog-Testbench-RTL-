module simple_caculator #(
    parameter WIDTH = 8,
    parameter CLK_FREQ = 50000000,
    parameter BAUD = 9600
)(
    input wire E,
    input wire CLK,
    input wire RX,
    input wire RST,
    output wire TX
);

    reg [1:0] state, next_state;


    localparam  READ_OP1 = 3'b00,
                READ_OPCODE = 3'b01,
                READ_OP2 = 3'b10,
                SEND_RESULT = 3'b11,
                c_opcode_mul = "x",
                c_opcode_add = "+",
                c_opcode_sub = "-",
                c_opcode_div = "/";

    reg [WIDTH -1:0] i_op1, i_op2;
    wire [WIDTH -1:0] i_result, buffer;

    
    reg b_start_send = 0;
    wire b_error;
    wire b_interup;
    reg ACK;

    reg [1:0] b_opcode = 2'bx;

    ALU #(.WIDTH(WIDTH)) alu (.opcode(b_opcode), .op1(i_op1), .op2(i_op2), .result(i_result), .error(b_error));

    uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) uart (
        .CLK(CLK),
        .RST(RST),
        .RX(RX),
        .TX(TX),
        .TX_START(b_start_send),
        .TX_DATA(i_result),
        .RX_DATA(buffer),
        .value_intr(b_interup),
        .ACK(ACK)
    );



    // state update 
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            b_start_send <= 0;
            b_opcode <= 2'bx;
            i_op1 <= {WIDTH{1'b0}};
            i_op2 <= {WIDTH{1'b0}};
            state <= READ_OP1; // Start with reading the first operand
        end
        else begin
            state <= next_state;
            case (state)
                SEND_RESULT: b_start_send <= 1;
                default:     b_start_send <= 0;
            endcase
        end
    end

    // next state logic
    always @(*) begin
        case (state)

            READ_OP1: begin
                next_state = (b_interup)? READ_OPCODE: READ_OP1;
            end

            READ_OPCODE: begin
                next_state = (b_interup)? READ_OP2: READ_OPCODE;
            end

            READ_OP2: begin
                next_state = (b_interup)? SEND_RESULT: READ_OP2;
            end

            SEND_RESULT: begin
                next_state <= READ_OP1;
            end

            default: next_state = READ_OP1;



        endcase
    end

    // output logic
    always @(*) begin
        case (state)

            READ_OP1: begin
                b_start_send <= 0;
                i_op1 <= (b_interup)?buffer:i_op1;
            end

            READ_OPCODE: begin
                if(b_interup) begin
                    case (buffer)

                        c_opcode_add: b_opcode <= 2'b00;
                        c_opcode_sub: b_opcode <= 2'b01;
                        c_opcode_mul: b_opcode <= 2'b10;
                        c_opcode_div: b_opcode <= 2'b11;

                        default: b_opcode <= 2'bxx;


                    endcase
                    
                end else begin
                    b_opcode <= b_opcode; // reset opcode if not reading
                end
            end

            READ_OP2: begin
                i_op2 <= (b_interup)?buffer:i_op2;
            end

            SEND_RESULT: begin
                b_start_send <= 1;
            end

        endcase
    end

    // Acknowledge logic
    // This logic is used to acknowledge the read operations
    always @(posedge CLK) begin
        if (state == READ_OP1 && b_interup) begin
            $display("%0t Read Op1: %d", $time, buffer);
            ACK <= 1; // Acknowledge the read operation
        end else begin
            ACK <= 0; // Reset ACK if not in READ_OP1 or READ_OP2 state
        end
        if (state == READ_OPCODE && b_interup) begin
            $display("%0t Read Opcode: %s", $time, buffer);
            ACK <= 1; // Acknowledge the read operation
        end else begin
            ACK <= 0; // Reset ACK if not in READ_OPCODE state
        end
        if (state == READ_OP2 && b_interup) begin
            $display("%0t Read Op2: %d", $time, buffer);
            ACK <= 1; // Acknowledge the read operation
        end else begin
            ACK <= 0; // Reset ACK if not in READ_OP2 state
        end 
    end

    


endmodule
