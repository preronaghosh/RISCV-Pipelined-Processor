/** access size:
00 - 1 byte
01 - 2 bytes
10 - 4 bytes
**/
/** read_write 
0 - read
1 - write 
**/
/**
UnsignedSel:
unsigned - 1
signed - 0
**/

module dmemory (
    input wire clock,
    input wire [31:0] addr,
    input wire [31:0] data_in,
    input wire [1:0] access_size,
    input wire UnsignedSel,
    input wire read_write,
    output reg [31:0] data_out
);

reg [31:0] temp_arr_data [0:`LINE_COUNT-1];
reg [7:0] memory_data [0:`MEM_DEPTH-1];
reg [31:0] start_addr;
integer line_ctr;
integer ctr;
integer i;

initial
begin
    $readmemh(`MEM_PATH, temp_arr_data);
    // byte addressable
    for(line_ctr = 0; line_ctr < `LINE_COUNT; line_ctr = line_ctr + 1) 
    begin
        i = line_ctr * 4; 
        // first byte 
        for(ctr = 0; ctr < 8; ctr = ctr+1) begin
            memory_data[i][ctr] = temp_arr_data[line_ctr][ctr];
        end
        // second byte 
        for(ctr = 0; ctr < 8; ctr=ctr+1) begin
            memory_data[i+1][ctr] = temp_arr_data[line_ctr][ctr+8];
        end
        // third byte 
        for(ctr = 0; ctr < 8; ctr=ctr+1) begin
            memory_data[i+2][ctr] = temp_arr_data[line_ctr][ctr+16];
        end
        // fetch fourth byte 
        for(ctr = 0; ctr < 8; ctr=ctr+1) begin
            memory_data[i+3][ctr] = temp_arr_data[line_ctr][ctr+24];
        end
    end

    start_addr = (32'h01000000 + `MEM_DEPTH);
    data_out = 0;
end

// load instructions
always @(*)
begin
    if (read_write == 0) 
    begin
        // unsigned loads
        if (UnsignedSel == 1'b1)
        begin
            // lbu
            if(access_size == 2'b00) begin
                data_out[7:0] = memory_data[addr];
                data_out[31:8] = 0;
            end
            // lhu
            else if (access_size == 2'b01) begin
                data_out[7:0] = memory_data[addr];
                data_out[15:8] = memory_data[addr + 1];
                data_out[31:16] = 0;
            end
            // lw
            else if (access_size == 2'b10) begin
                data_out[7:0] = memory_data[addr];
                data_out[15:8] = memory_data[addr + 1];
                data_out[23:16] = memory_data[addr + 2];
                data_out[31:24] = memory_data[addr + 3];
            end
            else 
                data_out = 0;
        end

        // signed loads
        else 
        begin
            // lb
            if(access_size == 2'b00) 
            begin
                data_out[7:0] = memory_data[addr];
                // sign extension
                if (memory_data[addr][7] == 1'b0)
                    data_out[31:8] = 0;
                else
                    data_out[31:8] = 24'hFFFFFF;
            end

            // lh
            else if (access_size == 2'b01) 
            begin
                data_out[7:0] = memory_data[addr];
                data_out[15:8] = memory_data[addr + 1];
                // sign extension
                if (memory_data[addr + 1][7] == 1'b0)
                    data_out[31:16] = 0;
                else
                    data_out[31:16] = 16'hFFFF;
            end

            // lw
            else if (access_size == 2'b10) begin
                data_out[7:0] = memory_data[addr];
                data_out[15:8] = memory_data[addr + 1];
                data_out[23:16] = memory_data[addr + 2];
                data_out[31:24] = memory_data[addr + 3];
            end

            else
                data_out = 0;
        end
    end
    else 
        data_out = 0;
end

// store instructions
always @(posedge clock) 
begin
    if (read_write == 1'b1) 
    begin
        // sb
        if(access_size == 2'b00)
            memory_data[addr] <= data_in[7:0];

        else if (access_size == 2'b01) // sh
        begin
            memory_data[addr] <= data_in[7:0];
            memory_data[addr + 1] <= data_in[15:8];
        end

        else if (access_size == 2'b10) // sw
        begin
            memory_data[addr] <= data_in[7:0];
            memory_data[addr + 1] <= data_in[15:8];
            memory_data[addr + 2] <= data_in[23:16];
            memory_data[addr + 3] <= data_in[31:24];
        end
    end
end

endmodule
