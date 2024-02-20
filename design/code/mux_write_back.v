/**
    WBSel:
    00 mem
    01 alu_result
    10 next_pc
**/
module mux_write_back(
    input wire [1:0] WBSel, 
    input wire [31:0] mem,
    input wire [31:0] alu_result,
    input wire [31:0] next_pc,
    output reg [31:0] wb_result
);

initial begin
    wb_result = 0;
end

always @(*) 
begin
    if (WBSel == 2'b00) 
        wb_result = mem;

    else if (WBSel == 2'b01)
        wb_result = alu_result;

    else if (WBSel == 2'b10)
        wb_result = next_pc;

    else 
        wb_result = 0;
end

endmodule