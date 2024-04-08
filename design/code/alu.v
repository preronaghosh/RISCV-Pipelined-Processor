module alu (
    input wire [31:0] inp1, // rs1 or pc
    input wire [31:0] inp2, // rs2 or imm
    input wire [3:0] ALUSel,
    output reg [31:0] out
);

always @(inp1 or inp2) 
begin
    case(ALUSel)
        4'b0000 : // add
            out = $signed(inp1) + $signed(inp2);

        // sub
        4'b0001 :
            out = $signed(inp1) - $signed(inp2);

        // and
        4'b0010 :
            out = inp1 & inp2;

        // or
        4'b0011 :
            out = inp1 | inp2;

        // logical left shift (sll)
        4'b0100 :
            out = inp1 << inp2[4:0];

        // logical right shift (sra)
        4'b0101 :
            out = inp1 >> inp2[4:0];

        // xor
        4'b0110:
            out = inp1 ^ inp2;

        // set less than signed 
        4'b0111:
            if($signed(inp1) < $signed(inp2)) 
            begin
                out = 32'h00000001;
            end
            else 
            begin
                out = 0;
            end

        // set less than unsigned
        4'b1000:
            if(inp1 < inp2) 
            begin
                out = 32'h00000001;
            end
            else 
            begin
                out = 0;
            end

        // arithmetic right shift
        4'b1010:
            out = $signed(inp1) >>> inp2[4:0];

        default :
            out = 0;
    endcase
end

endmodule