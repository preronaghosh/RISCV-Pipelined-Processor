module stalling (
    input wire [31:0] x_insn,
    input wire [31:0] d_insn,
    input wire [4:0] d_rs1,
    input wire [4:0] d_rs2,
    input wire [4:0] x_rd,
    input wire [4:0] w_rd,
    input wire branch_taken,
    output reg stall_load_use,
    output reg stall_wd
);

initial begin
    stall_load_use = 0;
    stall_wd = 0;
end

always @(*) 
begin
    // load-use case
    if (x_insn[6:0] == 7'b0000011) 
    begin
        if ((d_rs1 == x_rd) || ((d_rs2 == x_rd) && (d_insn[6:0] != 7'b0100011))) // not store insn
        begin
            stall_load_use = 1'b1;
        end
        else
            stall_load_use = 0;
    end
    else 
        stall_load_use = 0;

    // wd stall
    if (((w_rd == d_rs1) || (w_rd == d_rs2)) && (w_rd != 0)) 
    begin
        stall_wd = 1'b1; 
    end
    else 
        stall_wd = 0; 


    // no stalling if branch taken, jal and jalr
    if (branch_taken || x_insn[6:0] == 7'b1101111 || x_insn[6:0] == 7'b1100111) 
    begin
        stall_load_use = 0;
        stall_wd = 0;
    end
end

endmodule