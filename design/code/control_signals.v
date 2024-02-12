/*
PCSel : pc+1 or ALU 
*/

module control_signals (
  input wire [31:0] inst,
  input wire BrEq,
  input wire BrLT,
  output reg [1:0] ASel,
  output reg [1:0] BSel,
  output reg [3:0] ALUSel,
  output reg PCSel,
  output reg write_enable,
  output reg branch_taken
);

reg [6:0] opcode;

initial 
begin
  opcode = 0;
  ASel = 0;
  BSel = 0;
  ALUSel = 0;
  PCSel = 0;
  write_enable = 0;
  branch_taken = 0;
end

always @(inst or BrEq or BrLT) 
begin
    opcode = inst[6:0];
    branch_taken = 0;
    write_enable = 0;
    ALUSel = 0;
    case(opcode)
      // R type
      7'b0110011 : 
      begin
        PCSel = 0;
        ASel = 2'b11; // rs1
        BSel = 2'b01; // rs2
        write_enable = 1'b0;

        if (inst[14:12] == 3'b000 && inst[30] == 0) // add
          ALUSel = 4'b0000;
        
        else if (inst[14:12] == 3'b000 && inst[30] == 0) // sub 
          ALUSel = 4'b0001;

        else if (inst[14:12] == 3'b100) // xor
          ALUSel = 4'b0110;

        else if (inst[14:12] == 3'b110) // or
          ALUSel = 4'b0011;

        else if (inst[14:12] == 3'b111) // and
          ALUSel = 4'b0010;

        else if (inst[14:12] == 3'b001) // sll (logical)
          ALUSel = 4'b0100;

        else if(inst[14:12] == 3'b101 && inst[30] == 0) // srl
          ALUSel = 4'b0101;

        else if (inst[14:12] == 3'b101 && inst[30] == 1'b1) // sra
          ALUSel = 4'b1010;

        else if (inst[14:12] == 3'b010) // slt
          ALUSel = 4'b0111;

        else if (inst[14:12] == 3'b011) // sltu
          ALUSel = 4'b1000;

        else 
          ALUSel = 4'b0000;
      end

      // S type
      7'b0100011 :
      begin
        PCSel = 0;
        ALUSel = 4'b0000;
        ASel = 2'b11;
        BSel = 2'b10;
        write_enable = 1'b0;
      end

      // B type
      7'b1100011 :
      begin
        ASel = 2'b10;
        BSel = 2'b10;
        write_enable = 1'b0;
        ALUSel = 4'b0000;
        
        if (inst[14:12] == 3'b000) // beq  
        begin
          if (BrEq == 1'b1) 
          begin
            PCSel = 1'b1;
            branch_taken = 1'b1;
          end
          else begin
            PCSel = 1'b0;
            branch_taken = 1'b0;
          end
        end

        else if (inst[14:12] == 3'b001) // bne
        begin
          if (BrEq == 0)
          begin
            PCSel = 1'b1;
            branch_taken = 1'b1;
          end
          else begin
            PCSel = 0;
            branch_taken = 0;
          end
        end

        else if (inst[14:12] == 3'b100) // blt
        begin
          if (BrLT == 1'b1) 
          begin
            PCSel = 1'b1;
            branch_taken = 1'b1;
          end
          else begin
            PCSel = 1'b0;
            branch_taken = 1'b0;
          end
        end

        else if (inst[14:12] == 3'b101) // bge
        begin
          if (BrLT == 0) begin
            PCSel = 1'b1;
            branch_taken = 1'b1;
          end
          else begin
            PCSel = 1'b0;
            branch_taken = 1'b0;
          end
        end

        else if(inst[14:12] == 3'b110)  // bltu
        begin
          if(BrLT == 1'b1) 
          begin
            PCSel = 1'b1;
            branch_taken = 1'b1;
          end
          else begin
            PCSel = 0;
            branch_taken = 0;
          end
        end

        else if(inst[14:12] == 3'b111) // bgeu
        begin
          if(BrLT == 0) 
          begin
            PCSel = 1'b1;
            branch_taken = 1'b1;
          end
          else 
          begin
            PCSel = 1'b0;
            branch_taken = 1'b0;
          end
        end

        else begin
          PCSel = 1'b0;
          branch_taken = 1'b0;
        end
      end

      // U type - lui
      7'b0110111 :
      begin
        ASel = 0;
        BSel = 2'b10;
        PCSel = 0;
        ALUSel = 4'b0000;
        write_enable = 1'b0;
      end

      // U type - auipc
      7'b0010111 :
      begin
        ASel = 2'b10;
        BSel = 2'b10;
        PCSel = 0;
        ALUSel = 4'b0000;
        write_enable = 1'b0;
      end

      // J type jal
      7'b1101111 :
      begin
        ASel = 2'b10;
        BSel = 2'b10;
        PCSel = 1'b1;
        write_enable = 1'b0; 
        ALUSel = 4'b0000;
      end

      // I type 
      7'b0010011 :
      begin
        ASel = 2'b11;
        BSel = 2'b10;
        write_enable = 1'b0;
        PCSel = 1'b0;
        ALUSel = 0;
        if (inst[14:12] == 3'b000) // addi
        begin
          ALUSel = 4'b0000;
        end

        else if (inst[14:12] == 3'b100) // xori
        begin
          ALUSel = 4'b0110;
        end

        else if (inst[14:12] == 3'b110) // ori
        begin
          ALUSel = 4'b0011;
        end

        else if (inst[14:12] == 3'b111) // andi
        begin
          ALUSel = 4'b0010;
        end

        else if (inst[14:12] == 3'b001) // slli
        begin
          BSel = 2'b00;
          ALUSel = 4'b0100;
        end

        else if (inst[14:12] == 3'b010) // slti signed
        begin
          ALUSel = 4'b0111;
        end

        else if (inst[14:12] == 3'b011) // sltiu
        begin
          ALUSel = 4'b1000;
        end

        else if (inst[14:12] == 3'b101) // funct3 = 0x5
        begin
          BSel = 0; // shamt
          if (inst[30] == 1'b0) // srli
            ALUSel = 4'b0101;
          else if (inst[30] == 1'b1) // srai
            ALUSel = 4'b1010;
        end

        else 
          ALUSel = 4'b0000;
      end

      // I type - loads
      7'b0000011 : 
      begin
        ASel = 2'b11;
        BSel = 2'b10;
        PCSel = 1'b0;
        write_enable = 1'b0; 
        ALUSel = 4'b0000;
      end
      
      // I type - jalr
      7'b1100111 :
      begin
        ASel = 2'b11;
        BSel = 2'b10;
        PCSel = 1'b1;  
        write_enable = 1'b0; 
        ALUSel = 4'b0000;
      end

      default :
      begin
        ASel = 0;
        BSel = 0;
        PCSel = 0;
        write_enable = 1'b0;
        ALUSel = 0;
      end
    endcase
end

endmodule