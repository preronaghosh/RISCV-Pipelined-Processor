module register_file (
    input wire clock,
    input wire [4:0] addr_rs1,
    input wire [4:0] addr_rs2,
    input wire [4:0] addr_rd,
    input wire [31:0] data_rd,
    output reg [31:0] data_rs1,
    output reg [31:0] data_rs2,
    input wire write_enable,
    input wire reset
);

reg [31:0] reg_file [31:0];
integer i;

initial
begin
    // init reg file
    for(i = 0; i < 32; i = i + 1)
        reg_file[i] = (i == 2) ? (32'h01000000 + `MEM_DEPTH) : 0;
    data_rs1 = 0;
    data_rs2 = 0;
end

// read operation - combinational
always @(addr_rs1 or addr_rs2) 
begin
    data_rs1 = reg_file[addr_rs1];
    data_rs2 = reg_file[addr_rs2];
end

// write operation - sequential
always @(posedge clock) 
begin        
    if(reset) // reset all registers
    begin
        for(i = 0; i < 32; i = i + 1) begin
            reg_file[i] <= 0;
        end
        reg_file[2] <= 32'h01000000 + `MEM_DEPTH;
    end
    else if ((write_enable == 1'b1) && (addr_rd != 0)) // wb data
    begin
        reg_file[addr_rd] <= data_rd;
    end
end

endmodule
