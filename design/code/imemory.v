module imemory (
    input wire clock,
    input wire [31:0] address,
    output reg [31:0] data_out,
    input wire read_write
);

integer line_ctr; // i
integer ctr; // j
integer i; // k
reg [31:0] start_addr = 32'h01000000;
reg [31:0] pc;
reg [31:0] temp_arr_ins [0:`LINE_COUNT-1];
reg [7:0] memory_ins [0:`MEM_DEPTH-1];

initial 
begin
    $readmemh(`MEM_PATH, temp_arr_ins);
    for(line_ctr = 0; line_ctr < `LINE_COUNT; line_ctr = line_ctr + 1) 
    begin
        i = line_ctr*4; 
        // first byte 
        for(ctr = 0; ctr < 8; ctr = ctr+1) begin
            memory_ins[i][ctr] = temp_arr_ins[line_ctr][ctr];
        end
        // second byte 
        for(ctr = 0; ctr < 8; ctr=ctr+1) begin
            memory_ins[i+1][ctr] = temp_arr_ins[line_ctr][ctr+8];
        end
        // third byte 
        for(ctr = 0; ctr < 8; ctr=ctr+1) begin
            memory_ins[i+2][ctr] = temp_arr_ins[line_ctr][ctr+16];
        end
        // fetch fourth byte 
        for(ctr = 0; ctr < 8; ctr=ctr+1) begin
            memory_ins[i+3][ctr] = temp_arr_ins[line_ctr][ctr+24];
        end
    end
end

always @(address)
begin   
    pc = address - start_addr;
    data_out = 0;
    if (read_write == 0) begin // Read operation
        if (pc > (`LINE_COUNT-1)*4) begin
            $finish;
        end
        else begin
            for(ctr = 0; ctr < 8; ctr = ctr + 1) begin
                data_out[ctr] = memory_ins[pc][ctr];
            end

            for(ctr = 0; ctr < 8; ctr = ctr + 1) begin
                data_out[ctr+8] = memory_ins[pc+1][ctr];
            end

            for(ctr = 0; ctr < 8; ctr = ctr + 1) begin
                data_out[ctr+16] = memory_ins[pc+2][ctr];
            end

            for(ctr = 0; ctr < 8; ctr = ctr + 1) begin
                data_out[ctr+24] = memory_ins[pc+3][ctr];
            end
        end
    end
    // else if (read_write == 1) begin    // write operation
    //     // write the first byte from data_in into memory_ins
    //     for(ctr=0; ctr<8; ctr=ctr+1) begin
    //         memory_ins[pc][ctr] <= data_in[ctr];
    //     end

    //     // write the second byte from data_in into memory_ins
    //     for(ctr=0; ctr<8; ctr=ctr+1) begin
    //         memory_ins[pc+1][ctr] <= data_in[ctr+8];
    //     end

    //     // write the third byte from data_in into memory_ins
    //     for(ctr=0; ctr<8; ctr=ctr+1) begin
    //         memory_ins[pc+2][ctr] <= data_in[ctr+16];
    //     end

    //     // write the fourth byte from data_in into memory_ins
    //     for(ctr=0; ctr<8; ctr=ctr+1) begin
    //         memory_ins[pc+3][ctr] <= data_in[ctr+24];
    //     end
    // end
end


endmodule
