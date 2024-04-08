/*
initial : 00

bypass_sel_rs1:
01 mx rs1
10 wx rs1

bypass_sel_rs2:
01 mx rs2
10 wx rs2
*/

module forwarding_logic (
    input wire [4:0] x_rs1,
    input wire [4:0] x_rs2,
    input wire [4:0] m_write_destination,
    input wire [4:0] w_write_destination,
    output reg [1:0] bypass_sel_rs1,
    output reg [1:0] bypass_sel_rs2
);

initial begin
    bypass_sel_rs1 = 0;
    bypass_sel_rs2 = 0;
end

always @(*) 
begin
    // MX bypassing for rs1
    if (m_write_destination == x_rs1 && x_rs1!=0) 
        bypass_sel_rs1 = 2'b01;

    // wx for rs1    
    else if (w_write_destination == x_rs1 && x_rs1!=0)
        bypass_sel_rs1 = 2'b10;
    // not required
    else 
        bypass_sel_rs1 = 2'b00;  
    
    // MX bypassing for rs2
    if (m_write_destination == x_rs2 && x_rs2!=0) 
        bypass_sel_rs2 = 2'b01;

    // wx for rs2
    else if (w_write_destination == x_rs2 && x_rs2!=0)
        bypass_sel_rs2 = 2'b10;

    // not required
    else 
        bypass_sel_rs2 = 2'b00; 

end

endmodule