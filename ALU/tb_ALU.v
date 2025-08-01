module tb_ALU;

    reg signed [15:0] tb_op1, tb_op2;
    wire signed [15:0] tb_result;
    reg [1:0] tb_opcode;
    wire tb_error;

    ALU uut (.opcode(tb_opcode), .op1(tb_op1), .op2(tb_op2), .result(tb_result), .error(tb_error));

    initial begin
        tb_op1 = 16'd15;
        tb_op2 = 16'd5;
        tb_opcode = 2'b00;
        #5;
        tb_opcode = 2'b01;
        #5;
        tb_opcode = 2'b10;
        #5;
        tb_opcode = 2'b11;
        #5;

    end


endmodule
