module pd(
  input clock,
  input reset
);

// fetch stage
wire [31:0] data_in;
reg [31:0] f_insn;
reg [31:0] f_pc = 32'h01000000;
wire read_write;

// update pc
always @(posedge clock) begin
  if (reset) 
    f_pc <= 32'h01000000;
  else 
  begin
    f_pc <= f_pc + 4;
  end
end

// instantiate memory module
imemory imemory_0(
  .clock(clock),
  .address(f_pc),
  .data_in(data_in),
  .data_out(f_insn),
  .read_write(read_write)
);

// decode stage
reg [31:0] d_pc;
reg [6:0] d_opcode;
reg [4:0] d_rd;
reg [4:0] d_rs1;
reg [4:0] d_rs2;
reg [2:0] d_funct3;
reg [6:0] d_funct7;
reg [31:0] d_imm;
reg [4:0] d_shamt;

decode decode_0 (
  .clock(clock),
  .f_pc(f_pc),
  .inst(f_insn),
  .d_pc(d_pc),
  .opcode(d_opcode),
  .rd(d_rd),
  .rs1(d_rs1),
  .rs2(d_rs2),
  .funct3(d_funct3),
  .funct7(d_funct7),
  .imm(d_imm),
  .shamt(d_shamt)
);

endmodule
