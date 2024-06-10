`timescale 1ps/1ps

`include "test_setup.vh"

module test_spi_fe #(parameter SPI_DLY=20) (input wire clk);

logic spi_clk;
logic spi_mosi;
logic spi_miso;
logic spi_cs;
logic spi_frame;
AXIStream interf_host2fpga(), interf_fpga2host();

logic spi_int;// Check in TB

logic [9:0] fpga2host_fifo_filled = '0; // 0-512   Set in TB
logic [9:0] host2fpga_fifo_empty ='0; // 0-512     Set in TB
    
logic err_outfifo_overflow_pulse; // Set in TB

spi_interface dut(.*);
adapter_master_spi #(SPI_DLY) spi_adapter(.*);
axi_master axi_m(.clk, .interf(interf_fpga2host));
axi_slave axi_s(.clk, .interf(interf_host2fpga));

`define R(func) spi_adapter.func(); axi_m.func(); axi_s.func()

task run();
    `START;

    $display("[SPI FE Test] %0t: Simple write", $time);
    spi_adapter.send({32'h01000000, 32'h0, 32'h0});
    axi_s.exp({32'h01000000, 32'h0, 32'h0});
    `TEST;

    `STOP;
endtask


endmodule
