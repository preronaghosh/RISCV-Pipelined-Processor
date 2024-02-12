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
  else if (PCSel == 1'b1)
    f_pc <= e_alu_res; // from ALU
  else begin
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

// decode stage + immediate generator
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

// control signals
reg [31:0] e_alu_res;
reg [31:0] e_pc = f_pc;
reg BrEq;
reg BrUn;
reg BrLT;
reg e_br_taken;
reg PCSel;
reg [1:0] ASel;
reg [1:0] BSel;
reg [3:0] ALUSel;

reg r_write_enable;
reg [31:0] r_read_rs1_data;
reg [31:0] r_read_rs2_data;
reg [4:0] r_read_rs1 = d_rs1;
reg [4:0] r_read_rs2 = d_rs2;
reg [4:0] r_write_destination = d_rd;
reg [31:0] r_write_data;

control_signals control_signals_0 (
  .inst(f_insn),
  .BrEq(BrEq),
  .BrLT(BrLT),
  .ASel(ASel),
  .BSel(BSel),
  .ALUSel(ALUSel),
  .PCSel(PCSel),
  .write_enable(r_write_enable),
  .branch_taken(e_br_taken)
);

// Register file
register_file register_file_0(
  .clock(clock),
  .addr_rs1(r_read_rs1),
  .addr_rs2(r_read_rs2),
  .addr_rd(r_write_destination),
  .data_rd(r_write_data),
  .write_enable(r_write_enable),
  .data_rs1(r_read_rs1_data),
  .data_rs2(r_read_rs2_data)
);

// Execute stage

// set BrUn for branch instructions
always @(f_insn) begin
  if (f_insn[6:0] == 7'b1100011) begin
    if (f_insn[14:12] == 3'b100) // blt
      BrUn = 0;
    else if (f_insn[14:12] == 3'b110) // bltu
      BrUn = 1'b1;
    else if (f_insn[14:12] == 3'b101) // bge
      BrUn = 0;
    else if (f_insn[14:12] == 3'b111) // bgeu
      BrUn = 1'b1;
    else // default case
      BrUn = 0;
  end
  else // for non branch instructions
    BrUn = 0;
end


// Branch comparator
branch_comp branch_comp_0 (
  .BrUn(BrUn),
  .BrEq(BrEq),
  .BrLT(BrLT),
  .rs1(r_read_rs1_data),
  .rs2(r_read_rs2_data)
);

// Alu input mux
reg [31:0] out1;
reg [31:0] out2;

// ALU
alu alu_0 (
  .inp1(out1),
  .inp2(out2),
  .ALUSel(ALUSel),
  .out(e_alu_res)
);

mux_to_alu mux_to_alu_0 (
  .ASel(ASel),
  .BSel(BSel),
  .rs1(r_read_rs1_data),
  .rs2(r_read_rs2_data),
  .imm(d_imm),
  .pc(e_pc),
  .shamt(d_shamt),
  .out1(out1),
  .out2(out2)
);

endmodule
