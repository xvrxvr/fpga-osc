`timescale 1ps/1ps

`include "test_setup.vh"

import axi4stream_vip_pkg::*;
import axi4stream_vip_0_pkg::*;

module axi_master(input wire clk, AXIStream.master interf);

axi4stream_vip_0 axi_stream_vip (
  .aclk(clk),                    // input wire aclk
  .m_axis_tvalid(interf.TVALID),  // output wire [0 : 0] m_axis_tvalid
  .m_axis_tready(interf.TREADY),  // input wire [0 : 0] m_axis_tready
  .m_axis_tdata(interf.TDATA),    // output wire [31 : 0] m_axis_tdata
  .m_axis_tlast(interf.TLAST),    // output wire [0 : 0] m_axis_tlast
  .m_axis_tdest(interf.TDEST),    // output wire [7 : 0] m_axis_tdest
  .m_axis_tuser(interf.TUSER)    // output wire [3 : 0] m_axis_tuser
);

logic [31:0] data [$];

axi4stream_vip_0_mst_t axi4stream_vip_agent;

initial begin : START_axi4stream_vip_MASTER
  axi4stream_vip_agent = new("axi_master_vip", axi_stream_vip.inst.IF);
  axi4stream_vip_agent.set_verbosity(VERB ? 400 : 0);
end

task check_finish();
    if (data.size() != 0) begin
        $error("[AXI Master] <%m> %0t : Transaction not finished", $time);
        $stop();
    end
endtask

task start();
    axi4stream_vip_agent.start_master();
endtask

task stop();
    check_finish();
    axi4stream_vip_agent.stop_master();
endtask


task send(input logic [31:0] data_);
    data.push_back(data_);
endtask

task send_array(input logic [31:0] data_[]);
    for(int i=0; i < data_.size(); ++i) send(data_[i]);
endtask

task run();
    automatic logic first = 1'b1;
    automatic logic [7:0] dest = data[0][31 -: 8];
    automatic axi4stream_transaction wr_transaction;

    while(data.size()) begin
        wr_transaction = axi4stream_vip_agent.driver.create_transaction("write transaction");
        wr_transaction.set_data_beat(data.pop_front);
        wr_transaction.set_dest(dest);
        wr_transaction.set_last(data.size() == 0);
        wr_transaction.set_user({3'b0, first});
        first = '0;
        axi4stream_vip_agent.driver.send(wr_transaction);
    end
endtask

endmodule

