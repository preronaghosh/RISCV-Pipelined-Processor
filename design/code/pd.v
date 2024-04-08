module pd(
  input clock,
  input reset
);

reg [31:0] f_pc = 32'h01000000;
reg [31:0] d_pc;
reg [31:0] e_pc;
reg [31:0] m_pc;
reg [31:0] w_pc;

reg [4:0] x_rs1;
reg [4:0] x_rs2;

reg [31:0] f_insn;
reg [31:0] d_insn;
reg [31:0] x_insn;
reg [31:0] m_insn;
reg [31:0] w_insn;

reg [31:0] m_alu_res;
reg [31:0] x_read_rs1_data;
reg [31:0] x_read_rs2_data;
reg [31:0] x_imm;
reg [4:0] x_shamt;
wire read_write;


always @(posedge clock) 
begin
    if(reset != 1'b1) 
    begin
      
      // pc
      // for jump or branch taken, flush all instructions in pipeline
      if(x_insn[6:0] == 7'b1101111 || x_insn[6:0] == 7'b1100111 || e_br_taken) 
      begin
        d_pc <= 0;
        e_pc <= 0;
        m_pc <= e_pc;
        w_pc <= m_pc;
      end  
      else if (!stall_load_use && !stall_wd) 
      begin
        d_pc <= f_pc;
        e_pc <= d_pc;
        m_pc <= e_pc;
        w_pc <= m_pc;
      end
      else 
      begin
        e_pc <= 0; 
        m_pc <= e_pc;
        w_pc <= m_pc;
      end

      // rs1 and rs2
      if(!stall_load_use && !stall_wd)
      begin
        x_rs1 <= d_rs1;
        x_rs2 <= d_rs2;
      end
      else begin
        x_rs1 <= 0;
        x_rs2 <= 0;
      end

      // if jump/branch, 0 for insn in all following stages
      if(x_insn[6:0] == 7'b1101111 || x_insn[6:0] == 7'b1100111 || e_br_taken) 
      begin
        // flushing to complete zero - not the same as trace files though
        d_insn <= 0;
        x_insn <= 0;
        m_insn <= x_insn;
        w_insn <= m_insn;
      end
      else if(!stall_load_use && !stall_wd) begin
        d_insn <= f_insn;
        x_insn <= d_insn;
        m_insn <= x_insn;
        w_insn <= m_insn;
      end
      else begin
        x_insn <= 0;
        m_insn <= x_insn;
        w_insn <= m_insn;
      end

      // data
      if(!stall_load_use && !stall_wd) begin
        x_read_rs1_data <= r_read_rs1_data;
        x_read_rs2_data <= x_read_rs2_data_selected;
        x_imm <= d_imm;
        x_shamt <= d_shamt;
      end
      else begin
        x_read_rs1_data <= 0;
        x_read_rs2_data <= 0;
        x_imm <= 0;
        x_shamt <= 0;
      end

      if(!stall_load_use && !stall_wd) 
        x_write_destination <= r_write_destination;
      else 
        x_write_destination <= 0;

      // forwarding remaining control logic and data
      m_write_destination <= x_write_destination;
      w_write_destination <= m_write_destination;

      m_write_enable <= r_write_enable;
      w_write_enable <= m_write_enable;
      
      m_alu_res <= e_alu_res;
      m_access_size <= access_size;
      m_read_unsign_sel <= read_unsign_sel;
      m_dmem_rw <= dmem_rw;
      m_WBSel <= WBSel;
      w_write_data <= m_write_data;
    end

    // ecall
    if(w_insn[6:0] == 7'b1110011) 
      $finish;
end

always @(posedge clock) 
begin
  if(reset)
    f_pc <= 32'h01000000;
  else if (PCSel == 1'b1) 
  begin
    if(!stall_load_use && !stall_wd) 
      f_pc <= e_alu_res;
  end
  else 
  begin
    if(!stall_load_use && !stall_wd)
      f_pc <= f_pc + 4;
  end
end

imemory imemory_0 (
  .clock(clock),
  .address(f_pc),
  .data_out(f_insn),
  .read_write(read_write)
);

// decode stage
reg [6:0] d_opcode;
reg [4:0] d_rd;
reg [4:0] d_rs1;
reg [4:0] d_rs2;
reg [2:0] d_funct3;
reg [6:0] d_funct7;
reg [31:0] d_imm;
reg [4:0] d_shamt;

decode decode_0(
  .clock(clock),
  .d_pc(d_pc),
  .inst(d_insn),
  .opcode(d_opcode),
  .rd(d_rd),
  .rs1(d_rs1),
  .rs2(d_rs2),
  .funct3(d_funct3),
  .funct7(d_funct7),
  .imm(d_imm),
  .shamt(d_shamt)
);

// register file

register_file register_file_0(
    .clock(clock),
    .addr_rs1(r_read_rs1),
    .addr_rs2(r_read_rs2),
    .addr_rd(m_write_destination),
    .data_rd(m_write_data),
    .data_rs1(r_read_rs1_data),
    .data_rs2(r_read_rs2_data),
    .write_enable(m_write_enable),
    .reset(reset)
);

// control logic
reg PCSel;
reg [31:0] e_alu_res;

reg r_write_enable;
reg m_write_enable;
reg w_write_enable;
reg [4:0] r_write_destination = d_rd;
reg [4:0] x_write_destination;
reg [4:0] m_write_destination;
reg [4:0] w_write_destination;
/* verilator lint_off UNOPTFLAT */
reg [31:0] m_write_data;
reg [31:0] w_write_data;
reg [31:0] r_write_data = w_write_data;
reg [4:0] r_read_rs1 = d_rs1;
reg [4:0] r_read_rs2 = d_rs2;
reg [31:0] r_read_rs1_data;
reg [31:0] r_read_rs2_data;

reg BrUn;
reg BrEq;
reg BrLT;
reg e_br_taken;

reg [1:0] ASel;
reg [1:0] BSel;
reg [3:0] ALUSel;
reg [31:0] inp1;
reg [31:0] inp2;

reg [1:0] access_size;
reg [1:0] m_access_size;
reg read_unsign_sel;
reg m_read_unsign_sel;
reg dmem_rw;
reg m_dmem_rw;
/* verilator lint_off UNOPTFLAT */
reg [31:0] mem_data;
reg [1:0] WBSel;
reg [1:0] m_WBSel;

reg [31:0] m_address = m_alu_res;

control_signals control_signals_0(
    .inst(x_insn),
    .BrEq(BrEq),
    .BrLT(BrLT),
    .ASel(ASel),
    .BSel(BSel),
    .ALUSel(ALUSel),
    .PCSel(PCSel),
    .write_enable(r_write_enable),
    .branch_taken(e_br_taken),
    .access_size(access_size),
    .UnsignedSel(read_unsign_sel),
    .dmem_rw(dmem_rw),
    .WBSel(WBSel)
);

// Stall unit
reg stall_load_use;
reg stall_wd;

stalling stalling_0(
  .x_insn(x_insn),
  .d_insn(d_insn),
  .d_rs1(d_rs1),
  .d_rs2(d_rs2),
  .x_rd(x_write_destination),
  .w_rd(w_write_destination),
  .branch_taken(e_br_taken),
  .stall_load_use(stall_load_use),
  .stall_wd(stall_wd)
);

// to differentiate between signed and unsigned comparisons
always @(x_insn) 
begin
  if(x_insn[6:0] == 7'b1100011) 
  begin
    if(x_insn[14:12] == 3'b110) // bltu
      BrUn = 1'b1;
    else if(x_insn[14:12] == 3'b111) // bgeu
      BrUn = 1'b1;
    else 
      BrUn = 0;       
  end
  else 
    BrUn = 0;
end

// branch comparator unit
branch_comp branch_comp_0(
  .BrUn(BrUn),
  .rs1(x_read_rs1_data),
  .rs2(x_read_rs2_data),
  .mx_bypass_res(m_alu_res),
  .wx_bypass_res(w_write_data),
  .bypass_sel_rs1(bypass_sel_rs1),
  .bypass_sel_rs2(bypass_sel_rs2),
  .BrEq(BrEq),
  .BrLT(BrLT)
);

alu alu_0(
  .inp1(inp1),
  .inp2(inp2),
  .ALUSel(ALUSel),
  .out(e_alu_res)
);

reg [1:0] bypass_sel_rs1;
reg [1:0] bypass_sel_rs2;

forwarding_logic forwarding_0(
  .x_rs1(x_rs1),
  .x_rs2(x_rs2),
  .m_write_destination(m_write_destination),
  .w_write_destination(w_write_destination),
  .bypass_sel_rs1(bypass_sel_rs1),
  .bypass_sel_rs2(bypass_sel_rs2)
);

mux_to_alu mux_to_alu_0(
  .ASel(ASel),
  .BSel(BSel),
  .pc(e_pc),
  .rs1(x_read_rs1_data),
  .rs2(x_read_rs2_data),
  .bypass_sel_rs1(bypass_sel_rs1),
  .bypass_sel_rs2(bypass_sel_rs2),
  .mx_bypass_res(m_alu_res),
  .wx_bypass_res(w_write_data),
  .m_write_enable(m_write_enable),
  .w_write_enable(w_write_enable),
  .imm(x_imm),
  .shamt(x_shamt),
  .out1(inp1),
  .out2(inp2)
);

// WM bypass
reg [31:0] dmem_data_in;
always @(*) begin
  if(m_write_destination == x_rs2 && m_write_destination!= 0 && m_write_enable) begin
    dmem_data_in = m_write_data;
  end
  else begin
    dmem_data_in = x_read_rs2_data;
  end
end

// WX bypass
reg [31:0] x_read_rs2_data_selected;
always @(*) begin
  if(m_write_destination == d_rs2 && m_write_destination!= 0 && m_write_enable) begin
    x_read_rs2_data_selected = m_write_data;
  end
  else begin
    x_read_rs2_data_selected = r_read_rs2_data;
  end
end

dmemory dmemory_0(
  .clock(clock),
  .addr(e_alu_res),
  .data_in(dmem_data_in),
  .access_size(access_size),
  .UnsignedSel(read_unsign_sel),
  .read_write(dmem_rw),
  .data_out(mem_data)
);

mux_write_back mux_write_back_0(
  .WBSel(m_WBSel), 
  .mem(mem_data),
  .alu_result(m_alu_res),
  .next_pc(m_pc + 4),
  .wb_result(m_write_data)
);


endmodule
