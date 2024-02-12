/*
ASel:
10 = pc
11 = rs1
00 = 0
*/

/* 
BSel:
00 = shamt 
01 = rs2
10 = imm
*/

module mux_to_alu (
    input wire [1:0] ASel,
    input wire [1:0] BSel,
    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input wire [31:0] imm,
    input wire [31:0] pc,
    input wire [4:0] shamt,
    output reg [31:0] out1,
    output reg [31:0] out2
);

always @(ASel or BSel) 
begin
    if (ASel == 2'b00 && BSel == 2'b00) 
    begin
        out1 = 0;
        out2[4:0] = shamt;  
        out2[31:5] = 0;  
    end
    else if (ASel == 2'b00 && BSel == 2'b01)
    begin
        out1 = 0;
        out2 = rs2;
    end
    else if (ASel == 2'b00 && BSel == 2'b10) 
    begin
        out1 = 0;
        out2 = imm;
    end

    else if (ASel == 2'b10 && BSel == 2'b00) 
    begin
        out1 = pc;
        out2[4:0] = shamt;  
        out2[31:5] = 0;
    end
    else if (ASel == 2'b10 && BSel == 2'b01)
    begin
        out1 = pc;
        out2 = rs2;
    end
    else if (ASel == 2'b10 && BSel == 2'b10)
    begin
        out1 = pc;
        out2 = imm;
    end

    else if (ASel == 2'b11 && BSel == 2'b00) 
    begin
        out1 = rs1;
        out2[4:0] = shamt;  
        out2[31:5] = 0;
    end
    else if (ASel == 2'b11 && BSel == 2'b01)
    begin
        out1 = rs1;
        out2 = rs2;
    end
    else if (ASel == 2'b11 && BSel == 2'b10)
    begin
        out1 = rs1;
        out2 = imm;
    end
    else begin
        out1 = pc;
        out2 = imm;
    end

end

endmodule