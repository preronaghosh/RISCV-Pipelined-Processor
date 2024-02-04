/**
* The following code dumps the traces as patterns
*/
integer __dump_fd;
reg[128 * 2 - 1:0] pattern_dump;
initial begin
  __dump_fd = $fopen(`PATTERN_DUMP_FILE, "w");
end
always @(negedge clock) begin : pattern_dump_proc
  reg[127:0] stage;
  if(reset == 0) begin
    // F stage
    stage = 128'hxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    stage[`__F_PC] = dut.core.`F_PC;
    stage[`__F_INSN] = dut.core.`F_INSN;
    pattern_dump[`__F_RNG] = stage;
    
    // D stage
    stage = 128'hxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    stage[`__D_PC] = dut.core.`D_PC;
    stage[`__D_OPCODE] = dut.core.`D_OPCODE;
    stage[`__D_RD] = dut.core.`D_RD;
    stage[`__D_RS1] = dut.core.`D_RS1;
    stage[`__D_RS2] = dut.core.`D_RS2;
    stage[`__D_FUNCT3] = dut.core.`D_FUNCT3;
    stage[`__D_FUNCT7] = dut.core.`D_FUNCT7;
    stage[`__D_IMM] = dut.core.`D_IMM;
    stage[`__D_SHAMT] = dut.core.`D_SHAMT;
    pattern_dump[`__D_RNG] = stage;
    
    $fwrite(__dump_fd, "%0x\n", pattern_dump);
  end
end