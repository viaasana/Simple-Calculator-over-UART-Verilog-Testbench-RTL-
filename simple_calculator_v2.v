module simple_caculator_v2#(
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

    localparam  c_opcode_mul = "x",
                c_opcode_add = "+",
                c_opcode_sub = "-",
                c_opcode_div = "/";

    reg [1:0] state, next_state;
    reg wr_queue_reg = 0;
    reg read_queue = 0;
    wire [WIDTH-1:0] input_data_bus, internal_data_bus, result_data_bus;
    wire value_interup;
    wire ACK;
    
    wire fifo_enable;

    wire fifo_full, fifo_empty;

    /// pipe line stage valid flags and registers
    reg [2:0] assamble_counter = 0;
    reg [WIDTH-1:0] byte_buffer1, byte_buffer2, byte_buffer3;

    // stage 1 fetch operands and opcode
    reg stage1_valid = 0;
    reg [WIDTH-1:0] stage1_op1, stage1_op2;
    reg [1:0] stage1_opcode;
    reg waiting_flag = 0;

    // stage 2 execute operation
    reg stage2_valid = 0;
    reg [WIDTH-1:0] stage2_op1, stage2_op2;
    reg [1:0] stage2_opcode;
    wire [WIDTH-1:0] alu_result_stage2;
    reg [1:0] execute_counter = 0;
    reg wire_result = 0; // signal to write result to FIFO


    // send back result operatiopn
    wire result_fifo_empty;
    reg result_fifo_enable;
    wire tx_done;
    reg [1:0] send_counter = 0;
    reg b_start_send = 0;

    
    wire ALU_error;

    FIFO input_fifo (
        .CLK(CLK),
        .RST(RST),
        .E(fifo_enable),
        .DATA_IN(input_data_bus),
        .R_WR(wr_queue_reg),
        .DATA_OUT(internal_data_bus),
        .FULL(fifo_full),
        .EMPTY(fifo_empty)
    );

    uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) uart (
        .CLK(CLK),
        .RST(RST),
        .RX(RX),
        .TX(TX),
        .TX_START(b_start_send),
        .TX_DATA(result_data_bus),
        .RX_DATA(input_data_bus),
        .value_intr(value_interup),
        .tx_done(tx_done),
        .ACK(ACK)
    );

    ALU #(.WIDTH(WIDTH)) alu (.opcode(stage2_opcode), .op1(stage2_op1), .op2(stage2_op2), .result(alu_result_stage2), .error(ALU_error));

    FIFO resilt_fifo (
        .CLK(CLK),
        .RST(RST),
        .E(result_fifo_enable),
        .DATA_IN(alu_result_stage2),
        .R_WR(wire_result),
        .DATA_OUT(result_data_bus),
        .FULL(),
        .EMPTY(result_fifo_empty)
    );

    // Write to queue when value is received
    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            wr_queue_reg <= 0;
        end else begin
            if(value_interup) begin
                wr_queue_reg <= 1;
            end else begin
                wr_queue_reg <= 0;
            end
        end
    end

    


    assign fifo_enable = wr_queue_reg | read_queue;


    // stage 1 assamble 3 bytes into operands and opcode
    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            assamble_counter <= 0;
            stage1_valid <= 0;
            stage1_op1 <= {WIDTH{1'b0}};
            stage1_op2 <= {WIDTH{1'b0}};
            stage1_opcode <= 2'b0;
        end else begin
            read_queue <= 0;
            if(!stage1_valid) begin
                // if not holding data try to read from FIFO
                if(!wr_queue_reg) begin

                    case (assamble_counter)

                        0: begin
                            read_queue <= 1;
                            assamble_counter <= fifo_empty?0:1;
                            waiting_flag <= 0;
                        end

                        1: begin
                            read_queue <= 0;
                            assamble_counter <= 2;
                        end

                        2: begin
                            read_queue <= 1;
                            byte_buffer1 <= waiting_flag?byte_buffer1:internal_data_bus;
                            assamble_counter <= fifo_empty?2:3;
                            waiting_flag <= fifo_empty?0:1;
                        end

                        3: begin
                            assamble_counter <= 4;
                            read_queue <= 0;
                            waiting_flag <= 0;
                        end

                        4: begin
                            assamble_counter <= fifo_empty?4:5;
                            byte_buffer2 <= waiting_flag?byte_buffer2:internal_data_bus;
                            read_queue <= 1;
                            waiting_flag <= fifo_empty?0:1;
                        end

                        5: begin
                            read_queue <= 0;
                            assamble_counter <= 6;
                            waiting_flag <= 0;
                        end

                        6: begin
                            byte_buffer3 <= internal_data_bus;
                            assamble_counter <= 0; // reset counter for next read
                            stage1_op1 <= byte_buffer1;
                            stage1_op2 <= internal_data_bus; 
                            case (byte_buffer2)
                                c_opcode_add: stage1_opcode <= 2'b00;
                                c_opcode_sub: stage1_opcode <= 2'b01;
                                c_opcode_mul: stage1_opcode <= 2'b10;
                                c_opcode_div: stage1_opcode <= 2'b11;
                                default: stage1_opcode <= 2'bxx;
                            endcase
                            stage1_valid <= 1; // mark stage as valid
                        end
                        default: begin
                            // do nothing, wait for next byte
                        end
                    endcase
                end
            end
        end
    end

    // stage 2 execute operation
    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            stage2_valid <=0;
            stage2_op1 <= {WIDTH{1'b0}};
            stage2_op2 <= {WIDTH{1'b0}};
            stage2_opcode <=2'b0;
            execute_counter <= 0;
        end else begin
            
            if(stage1_valid || execute_counter) begin
                case (execute_counter) 
                    0: begin
                        if(!stage2_valid) begin
                            stage2_valid <= 1;
                            stage2_op1 <= stage1_op1;
                            stage2_op2 <= stage1_op2;
                            stage2_opcode <= stage1_opcode;
                            stage1_valid <= 0;
                            execute_counter <= 1; 
                        end else begin
                            // do nothing, wait for next clock cycle
                        end
                    end

                    1: begin
                        execute_counter <= 2; 
                        stage2_valid <= 0;
                        result_fifo_enable <= 1; // enable result FIFO
                        wire_result <= 1; // signal to write result
                    end

                    2: begin
                        result_fifo_enable <= 0; // enable result FIFO
                        wire_result <= 0; // signal to write result
                        execute_counter <= 0; // reset counter for next operation
                    end

                    default: begin
                        // do nothing, wait for next clock cycle
                    end

                endcase
            end
        end
    end

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin 

        end else begin
            if(!wire_result && (!result_fifo_empty || (send_counter>1))) begin
                case (send_counter)
                    0: begin
                        b_start_send <= 0; // start sending result
                        send_counter <= 1;
                        wire_result <= 0;
                        result_fifo_enable <= 1;
                    end

                    1: begin
                        result_fifo_enable <= 0;
                        send_counter <= 2;
                        b_start_send <= 1;
                    end

                    2: begin
                        if(tx_done) begin
                            send_counter <= 0; // reset counter for next operation
                            $display("%0t ns | Result sent from pipline: %d", $time, result_data_bus);
                        end
                    end

                    default: begin
                        send_counter <= 0; // reset counter for next operation
                    end

                endcase
            end else begin
                b_start_send <= 0; // stop sending result
            end
        end
    end


endmodule