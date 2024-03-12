`timescale 1ns / 1ps
`default_nettype none

module cdc_sync #(parameter MODE="PLAIN", STAGES=3) (
    input wire clk,
    input wire in,
    output wire out
);
(* ASYNC_REG = "TRUE" *) logic [STAGES-1:0] dly = '0;

always_ff @(posedge clk) dly <= (dly << 1) | in;
wire dly_end = dly[STAGES-1];

if (MODE == "PLAIN")
    assign out = dly_end;
    
if (MODE != "PLAIN") begin
    logic d2 = '0;
    always_ff @(posedge clk) d2 <= dly_end;
    
    if (MODE == "TOGGLE") assign out = d2 ^ dly_end;
    else assign out = dly & ~d2; 
end 

endmodule

module cdc_multi_sync #(parameter WIDTH=32, parameter MODE="PLAIN", STAGES=3) (
    input wire clk,
    input wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);

for(genvar i=0; i<WIDTH; i++) cdc_sync #(MODE, STAGES) inst(.clk(clk), .in(in[i]), .out(out[i]));

endmodule
