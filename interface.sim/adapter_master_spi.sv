`timescale 1ns / 1ps
`default_nettype none

`define VERB

module adapter_master_spi #(parameter DLY = 20)
(
   output reg spi_clk,
   output reg spi_mosi,
   input wire spi_miso,
   output reg spi_cs,
   output reg spi_frame
);

logic [7:0] queue_oob [$];
logic [7:0] queue_exp_oob [$];
logic [31:0] queue [$];
logic [31:0] queue_exp [$];

initial begin
	spi_clk = 1'b0;
	spi_cs = 1'b1;
    spi_frame = 1'b1;
    spi_mosi = 1'b0;
end

task xchg(input logic [7:0] data_in, output logic [7:0] data_out);
    automatic logic [7:0] acc = '0;
    automatic logic [7:0] shift = data_in;
    spi_cs <= 1'b0;
    #DLY;
    for(int i=0 ;<8; ++i) begin
        spi_mosi = shift[0];
        shift = shift >> 1;
        #DLY;
        spi_clk <= 1'b1;
        acc = (acc >> 1) | (spi_miso ? 8'h80 : 8'h00);
        #DLY;
        spi_clk <= 1'b0;        
    end
    data_out = acc;
`ifdef VERB
    $display("[SPI Master] %0t : OOB send %x, recv %x", $time, data_in, acc);
`endif
endtask

task xchg4(input logic[31:0] data_in, output logic [31:0] data_out);
    for(int i=0; i<4; ++i) xchg(data_in[i*8-1 -: 7], data_out[i*8-1 -: 7]);
endtask

task send(input logic[31:0] data);
    if (queue_oob.size()) begin
        $error("[SPI Master] %0t : Mix OOB and Normal data", $time);
        $stop();
    end
    queue.push_back(data);
`ifdef VERB
    $display("[SPI Master] %0t : Send %X, recv %X", $time, data_in, acc);
`endif
endtask

task send_oob(input logic[7:0] data);
    if (queue.size()) begin
        $error("[SPI Master] %0t : Mix OOB and Normal data", $time);
        $stop();
    end
    queue_oob.push_back(data);
endtask

task expect(input logic [31:0] data);
    if (queue_oob.size() || queue_exp_oob.size()) begin
        $error("[SPI Master] %0t : Mix OOB and Normal data", $time);
        $stop();
    end
    queue_exp.push_back(data);
endtask

task expect_oob(input logic [7:0] data);
    if (queue.size() || queue_exp.size()) begin
        $error("[SPI Master] %0t : Mix OOB and Normal data", $time);
        $stop();
    end
    queue_exp_oob.push_back(data);
endtask

task run();
    if (queue.size()) begin
        if (queue.size() != queue_exp.size()) begin
            $error("[SPI Master] %0t : Queue size (%0d) not equel to Exp size (%0d)", $time, queue.size(), queue_exp.size());
            $stop();
        end
        spi_frame <= 1'b0;
        #DLY;
        while(queue.size()) begin
            automatic logic [31:0] exp;
            automatic logic [31:0] data;
            automatic logic [31:0] real;
            data = queue.pop_front();
            exp = queue_exp.pop_front();
            xchg4(data, real);
            if (real != exp) begin
                $error("[SPI Master] %0t : Expected data missmatch - expected %X got %X", $time, exp, real);
                $stop();
            end
        end
        #DLY;
        spi_frame <= 1'b1;
    end else begin
        while(queue.size()) begin
            automatic logic [7:0] exp;
            automatic logic [7:0] data;
            automatic logic [7:0] real;
            data = queue_oob.pop_front();
            exp = queue_exp_oob.pop_front();
            xchg(data, real);
            if (real != exp) begin
                $error("[SPI Master] %0t : Expected OOB data missmatch - expected %X got %X", $time, exp, real);
                $stop();
            end
        end
    end
endtask

endmodule
