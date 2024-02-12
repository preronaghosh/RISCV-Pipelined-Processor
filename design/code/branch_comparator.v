module branch_comp (
    input wire BrUn,
    output reg BrEq,
    output reg BrLT,
    input wire [31:0] rs1,
    input wire [31:0] rs2
);

initial 
begin
    BrEq = 0;    
    BrLT = 0;    
end

always @(rs1 or rs2 or BrUn) 
begin
    if (rs1 == rs2) // equal values
    begin
        BrEq = 1'b1;
        BrLT = 1'b0;
    end    
    else if (BrUn == 1'b1) // unsigned comparison
    begin
        if (rs1 < rs2) begin
            BrLT = 1'b1;
            BrEq = 1'b0;
        end
        else begin
            BrEq = 1'b0;
            BrLT = 1'b0;
        end
    end
    else if (BrUn == 1'b0) // signed compare
    begin
        if ($signed(rs1) < $signed(rs2)) begin 
            BrLT = 1'b1;
            BrEq = 1'b0;
        end
        else begin
            BrEq = 1'b0;
            BrLT = 1'b0;
        end
    end 
    else 
    begin
        BrEq = 1'b0;
        BrLT = 1'b0;
    end
end
    
endmodule