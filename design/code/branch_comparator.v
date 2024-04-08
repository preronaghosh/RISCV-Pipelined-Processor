module branch_comp (
    input wire BrUn,
    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input wire [31:0] mx_bypass_res,
    input wire [31:0] wx_bypass_res,
    input wire [1:0] bypass_sel_rs1,
    input wire [1:0] bypass_sel_rs2,
    output reg BrEq,
    output reg BrLT
);

reg [31:0] compare_rs1;
reg [31:0] compare_rs2;

initial 
begin
    BrEq = 0;    
    BrLT = 0;    
    compare_rs1 = 0;
    compare_rs2 = 0;
end

always @(*) 
begin
    // select bypass result for rs1
    if (bypass_sel_rs1 == 2'b01)  // mx
        compare_rs1 = mx_bypass_res;
    else if (bypass_sel_rs1 == 2'b10) // wx
        compare_rs1 = wx_bypass_res;
    else 
        compare_rs1 = rs1;

    // bypass result for rs2
    if (bypass_sel_rs2 == 2'b01) // mx
        compare_rs2 = mx_bypass_res;
    else if (bypass_sel_rs2 == 2'b10) // wx
        compare_rs2 = wx_bypass_res;
    else 
        compare_rs2 = rs2;

    // set output based on bypassing results
    if (compare_rs1 == compare_rs2) // equal values
    begin
        BrEq = 1'b1;
        BrLT = 1'b0;
    end    
    else if (BrUn == 1'b1) // unsigned comparison
    begin
        if (compare_rs1 < compare_rs2) begin
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
        if ($signed(compare_rs1) < $signed(compare_rs2)) begin 
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
