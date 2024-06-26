`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2024 19:59:25
// Design Name: 
// Module Name: sim_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim_top();

logic clk = '0;

test_spi_fe t_spi(.clk);

initial begin
    forever begin
        #5 clk <= ~clk;
    end
end

initial begin
    #200;
    t_spi.run();
    $stop();
end


endmodule
