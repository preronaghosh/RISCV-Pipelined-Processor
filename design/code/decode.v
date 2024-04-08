module decode (
    input wire clock,
    input wire [31:0] d_pc,
    input wire [31:0] inst,
    output reg [6:0] opcode,
    output reg [4:0] rd,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg [31:0] imm,
    output reg [4:0] shamt
);

initial 
begin
    opcode = 0;
    rd = 0;
    rs1 = 0;
    rs2 = 0;
    funct3 = 0;
    funct7 = 0;
    shamt = 0;
    imm = 0;
end

always @(inst or d_pc)
begin
    // fixed fields
    opcode = inst[6:0];
    rd = 0;
    rs1 = 0;
    rs2 = 0;
    funct3 = 0;
    funct7 = 0;
    shamt = 0;
    imm = 0;

    // handle the rest of the instructions based on formats
    case(opcode)
        7'b0110011 : // R type (register instructions)
        begin
            rd = inst[11:7];
            funct3 = inst[14:12];
            rs1 = inst[19:15];
            rs2 = inst[24:20];
            funct7 = inst[31:25];
            imm = 0; // no immediate values

            // default 
            shamt = 0;

            // Handle shift operations
            if((funct3 == 3'b001 && funct7 == 7'b0000000) ||  // SLL
                (funct3 == 3'b101 && funct7 == 7'b0000000) || // SRL
                (funct3 == 3'b101 && funct7 == 7'b0100000))   // SRA
            begin
                shamt = rs2[4:0]; 
            end
        end

        7'b0100011 : // S type (store instructions)
        begin
            imm[4:0] = inst[11:7];
            funct3 = inst[14:12];
            rs1 = inst[19:15];
            rs2 = inst[24:20];
            imm[11:5] = inst[31:25];
            
            // sign extension
            if(inst[31] == 1'b1) 
                imm[31:12] = 20'hFFFFF;
            else 
                imm[31:12] = 0;

            shamt = 0;
            rd = 0;
            funct7 = 0;
        end

        // B type (conditional branch instructions)
        7'b1100011 : 
        begin
            rd = 0;
            funct7 = 0;
            shamt = 0;
            funct3 = inst[14:12];
            rs1 = inst[19:15];
            rs2 = inst[24:20];

            // forming the immediates
            imm[0] = 0;
            imm[4:1] =  inst[11:8];
            imm[10:5] = inst[30:25];
            imm[11] = inst[7];
            imm[12] = inst[31];
            // sign extend
            if(inst[31] == 1'b1) 
                imm[31:13] = 19'h7FFFF;
            else 
                imm[31:13] = 0;
        end

        // U type lui
        7'b0110111 :
        begin
            rd = inst[11:7];
            funct3 = 0;
            funct7 = 0;
            rs1 = 0;
            rs2 = 0;
            shamt = 0;
            imm[31:12] = inst[31:12];
            imm[11:0] = 0; // zero extends
        end

        // U type auipc
        7'b0010111 : 
        begin
            rd = inst[11:7];
            funct3 = 0;
            funct7 = 0;
            rs1 = 0;
            rs2 = 0;
            shamt = 0;
            imm[31:12] = inst[31:12];
            imm[11:0] = 0; // zero extends
        end

        // J type - jal
        7'b1101111 :
        begin
            // unused fields
            rs1 = 0;
            rs2 = 0;
            funct3 = 0;
            funct7 = 0;
            shamt = 0;
            // used fields
            rd = inst[11:7];
            imm[19:12] =  inst[19:12];
            imm[11] =  inst[20];
            imm[10:1] = inst[30:21];
            imm[20] = inst[31];

            // Sign extension 
            if (imm[20] == 1'b1)
                imm[31:21] = 11'h7FF; // negative values
            else
                imm[31:21] = 0; // Zero-extend for positive values
        end

        // I type JALR
        7'b1100111 :
        begin
            funct7=0;
            rs2 = 0;
            rd = inst[11:7];
            funct3 = inst[14:12];
            rs1 = inst[19:15];
            imm[11:0] = inst[31:20]; 
            shamt = 0;
            // sign extension
            if(inst[31] == 1'b1) 
                imm[31:12] = 20'hFFFFF;
            else 
                imm[31:12] = 0;            
        end

        // I type - ECALL
        7'b1110011:
        begin
            funct7 = 0;
            rs2 = 0;
            shamt = 0;
            rd = 0;
            funct3 = 0;
            rs1 = 0;
            imm = 0; 
        end

        // I type - loads
        7'b0000011 :
        begin
            funct7 = 0;
            rs2 = 0;
            shamt = 0;
            rd = inst[11:7];
            funct3 = inst[14:12];
            rs1 = inst[19:15];
            imm[11:0] = inst[31:20]; 
            // sign extension
            if(inst[31] == 1'b1) 
                imm[31:12] = 20'hFFFFF;
            else 
                imm[31:12] = 0;  
        end

        // I type
        7'b0010011 :
        begin
            funct7 = inst[31:25]; 
            rs2 = 0; // unused
            rd = inst[11:7];
            funct3 = inst[14:12];
            rs1 = inst[19:15];
            imm = 0; // Initialize for unused cases 

            // shift insns
            if (funct3 == 3'b001 || (funct3 == 3'b101 && (funct7 == 7'b0000000 || funct7 == 7'b0100000))) // slli, srli, srai
            begin
                shamt = inst[24:20];
            end
            else // all other insns
            begin
                imm[11:0] = inst[31:20];
                // Sign extension
                if(inst[31] == 1'b1) 
                    imm[31:12] = 20'hFFFFF;
                else 
                    imm[31:12] = 0;
            end
        end

        default : 
        begin
            rd = 0;
            funct3 = 0;
            rs1 = 0;
            rs2 = 0;
            funct7 = 0;
            imm = 0;
            shamt = 0;
        end
    endcase
end

endmodule