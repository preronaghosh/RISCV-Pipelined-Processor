module register_file (
    input wire clock,
    input wire [4:0] addr_rs1,
    input wire [4:0] addr_rs2,
    input wire [4:0] addr_rd,
    input wire [31:0] data_rd,
    input wire write_enable,
    output reg [31:0] data_rs1,
    output reg [31:0] data_rs2
);

reg [31:0] reg_file [31:0];
integer i;
integer j;

initial
begin
    // init reg file
    for(i = 0; i < 32; i = i + 1) begin
        for(j = 0; j < 32; j = j + 1) begin
            if (i==2) // x2
                reg_file[i] = 32'h01000000 + `MEM_DEPTH;
            else
                reg_file[i][j] = 0;
        end
    end
    data_rs1 = 0;
    data_rs2 = 0;
end

// read operation - combinational
always @(addr_rs1 or addr_rs2) 
begin
    reg_file[0] = 0; // x0 always 0
    data_rs1 = reg_file[addr_rs1];
    data_rs2 = reg_file[addr_rs2];
end

// write operation - sequential
always @(posedge clock) 
begin
    reg_file[0] = 0; // x0 always 0
    if (write_enable == 1'b1)
        reg_file[addr_rd] <= data_rd;
end

endmodule
