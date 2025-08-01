// 00: add
// 01: sub
// 10: mul
// 11: div

module ALU #(
    parameter WIDTH = 8
)(
    input [1:0] opcode,
    input signed [WIDTH-1:0] op1,
    input signed [WIDTH-1:0] op2,
    output reg signed [WIDTH-1:0] result,
    output reg error
);


    always @(*) begin

        error <= 0;

        case (opcode)

            2'b00: result <= op1 + op2;
            2'b01: result <= op1 - op2;
            2'b10: result <= op1 * op2;
            2'b11: begin
                if(op2 == 0) begin
                    error <= 1;
                    result <= {WIDTH{1'bx}};
                end else begin
                    error <= 0;
                    result <= op1 / op2;
                end
            end

            default: begin
                error <= 1;
                result <= {WIDTH{1'bx}};
            end

        endcase
    end




endmodule
