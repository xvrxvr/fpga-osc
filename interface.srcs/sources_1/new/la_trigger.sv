`timescale 1ns / 1ps
`default_nettype none

module la_trigger(
    input wire clk,
    input wire [31:0] ram_data,
    input wire [8:0] ram_addr,
    input wire ram_wr_en,
    
    input wire [31:0] in_data,
    input wire in_data_stb,
    
    input wire[3:0] ext_trigger,
    output wire start,
    output wire stop,
    
    input wire reset
);
`UNUSED(ram_data[31:29]);

logic [3:0] w;
logic [2:0] state = '0;
logic [4:0] encoder_ram_out;
logic [1:0] d1 = '0;
logic [1:0] d2 = '0;
wire [1:0] dd = d1 & ~d2;
assign start = dd[0];
assign stop = dd[1];

l1_m2 m1(.clk, .data(in_data), .ext_sync(ext_trigger[1:0]), .out(w[0]), .wr_addr(ram_addr[5:0]), .wr_data(ram_data[28:0]), .wr_en(ram_wr_en && ram_addr[8:6] == 0));   
l1_m2 m2(.clk, .data(in_data), .ext_sync(ext_trigger[2:1]), .out(w[1]), .wr_addr(ram_addr[5:0]), .wr_data(ram_data[28:0]), .wr_en(ram_wr_en && ram_addr[8:6] == 1));   
l1_m2 m3(.clk, .data(in_data), .ext_sync(ext_trigger[3:2]), .out(w[2]), .wr_addr(ram_addr[5:0]), .wr_data(ram_data[28:0]), .wr_en(ram_wr_en && ram_addr[8:6] == 2));   
l1_m2 m4(.clk, .data(in_data), .ext_sync({ext_trigger[3],ext_trigger[0]}), .out(w[3]), .wr_addr(ram_addr[5:0]), .wr_data(ram_data[28:0]), .wr_en(ram_wr_en && ram_addr[8:6] == 3));   

la_ram #(7, 5) mram(.clk, .rd_addr({state, w}), .rd_data(encoder_ram_out), .wr_addr(ram_addr[6:0]), .wr_data(ram_data[4:0]), .wr_en(ram_wr_en && ram_addr[8:7] == 2)); // ram_addr[8:6] is 4 and 5

always_ff @(posedge clk)
    if (reset) begin state <= '0; d1 <= '0; d2 <='0; end else
    if (in_data_stb) begin
        state <= encoder_ram_out[4:2];
        d2 <= d1;
        d1 <= encoder_ram_out[1:0];
    end

endmodule

module la_ram #(parameter AWIDTH=6, DWIDTH=1) (
    input wire clk,
    
    // Async read part
    input wire [AWIDTH-1:0] rd_addr,
    output wire [DWIDTH-1:0] rd_data,
    
    // Sync write part
    input wire [AWIDTH-1:0] wr_addr,
    input wire [DWIDTH-1:0] wr_data,
    input wire wr_en
);
localparam SIZE = 1 << AWIDTH;

logic [DWIDTH-1:0] ram [SIZE-1:0];

assign rd_data = ram[rd_addr];
always_ff @(posedge clk) if (wr_en) ram[wr_addr] <= wr_data;
endmodule

module la_m1(
    input wire clk,
    input wire [31:0] data,
    output wire out,
    
    input wire [5:0] wr_addr,
    input wire [6:0] wr_data,
    input wire wr_en
);

logic [5:0] w;

la_ram r1(.clk, .rd_addr(data[5:0]), .rd_data(w[0]), .wr_addr, .wr_data(wr_data[0]), .wr_en);
la_ram r2(.clk, .rd_addr(data[10:5]), .rd_data(w[1]), .wr_addr, .wr_data(wr_data[1]), .wr_en);
la_ram r3(.clk, .rd_addr({data[14:11], data[6:5]}), .rd_data(w[2]), .wr_addr, .wr_data(wr_data[2]), .wr_en);
la_ram r4(.clk, .rd_addr({data[19:15], data[7]}), .rd_data(w[3]), .wr_addr, .wr_data(wr_data[3]), .wr_en);
la_ram r5(.clk, .rd_addr(data[25:20]), .rd_data(w[4]), .wr_addr, .wr_data(wr_data[4]), .wr_en);
la_ram r6(.clk, .rd_addr(data[31:26]), .rd_data(w[5]), .wr_addr, .wr_data(wr_data[5]), .wr_en);
la_ram o(.clk, .rd_addr(w), .rd_data(out), .wr_addr, .wr_data(wr_data[6]), .wr_en);

endmodule

module l1_m2(
    input wire clk,
    input wire [31:0] data,
    input wire [1:0] ext_sync,
    output wire out,
    
    input wire [5:0] wr_addr,
    input wire [28:0] wr_data,
    input wire wr_en
);
logic [3:0] w;

la_m1 m1(.clk, .data, .out(w[0]), .wr_addr, .wr_data(wr_data[6:0]), .wr_en);
la_m1 m2(.clk, .data, .out(w[1]), .wr_addr, .wr_data(wr_data[13:7]), .wr_en);
la_m1 m3(.clk, .data, .out(w[2]), .wr_addr, .wr_data(wr_data[20:14]), .wr_en);
la_m1 m4(.clk, .data, .out(w[3]), .wr_addr, .wr_data(wr_data[27:21]), .wr_en);
la_ram o(.clk, .rd_addr({ext_sync, w}), .rd_data(out), .wr_addr, .wr_data(wr_data[28]), .wr_en); 

endmodule

