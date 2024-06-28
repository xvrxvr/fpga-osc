`timescale 1ps/1ps

`include "test_setup.vh"

import axi4stream_vip_pkg::*;
import axi4stream_vip_1_pkg::*;

module axi_slave(input wire clk, AXIStream.slave interf);

axi4stream_vip_1 axi_stream_vip (
  .aclk(clk),                    // input wire aclk
  .s_axis_tvalid(interf.TVALID),  // output wire [0 : 0] m_axis_tvalid
  .s_axis_tready(interf.TREADY),  // input wire [0 : 0] m_axis_tready
  .s_axis_tdata(interf.TDATA),    // output wire [31 : 0] m_axis_tdata
  .s_axis_tlast(interf.TLAST),    // output wire [0 : 0] m_axis_tlast
  .s_axis_tdest(interf.TDEST),    // output wire [7 : 0] m_axis_tdest
  .s_axis_tuser(interf.TUSER)    // output wire [3 : 0] m_axis_tuser
);


axi4stream_vip_1_slv_t axi4stream_vip_agent;
axi4stream_ready_gen ready_gen;
logic [31:0] data[$];


initial begin : START_axi4stream_vip_SLAVE
    axi4stream_vip_agent = new("axi_slave_vip", axi_stream_vip.inst.IF);
    axi4stream_vip_agent.set_verbosity(VERB ? 400 : 0);

end

task check_finish();
    if (data.size() != 0) begin
        $error("[AXI Slave] <%m> %0t : Transaction not finished", $time);
        $stop();
    end
endtask

task start();
    axi4stream_vip_agent.start_slave();
    ready_gen = axi4stream_vip_agent.driver.create_ready("ready_gen");
    ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE); //XIL_AXI4STREAM_READY_GEN_OSC); 
    //ready_gen.set_low_time(1);
    //ready_gen.set_high_time(2);
    axi4stream_vip_agent.driver.send_tready(ready_gen);
endtask

task stop();
    check_finish();
    axi4stream_vip_agent.stop_slave();
endtask

task exp(input logic [31:0] data_[]);
    for(int i=0; i < data_.size(); ++i) data.push_back(data_[i]);
endtask

task run();

    automatic axi4stream_monitor_transaction trans;
    automatic logic first = 1'b1;
    automatic logic [7:0] dest = data[0][31 -: 8];

    while(data.size()) begin
        //automatic axi4stream_monitor_transaction org = axi4stream_vip_agent.driver.create_transaction("gold");
        automatic axi4stream_transaction org = new("gold",
            axi4stream_vip_agent.driver.C_XIL_AXI4STREAM_SIGNAL_SET,
            axi4stream_vip_agent.driver.C_XIL_AXI4STREAM_DATA_WIDTH,
            axi4stream_vip_agent.driver.C_XIL_AXI4STREAM_USER_WIDTH,
            axi4stream_vip_agent.driver.C_XIL_AXI4STREAM_USER_BITS_PER_BYTE,
            axi4stream_vip_agent.driver.C_XIL_AXI4STREAM_ID_WIDTH,
            axi4stream_vip_agent.driver.C_XIL_AXI4STREAM_DEST_WIDTH);

        org.set_data_beat(data.pop_front);
        org.set_dest(dest);
        org.set_last(data.size() == 0);
        org.set_user_beat({3'b0, first});
        first = '0;

        axi4stream_vip_agent.monitor.item_collected_port.get(trans);
        if (trans.do_compare(org)) begin
            $error("[AXI Slave] <%m> %0t : Transaction missmatch: expected %0s, got %0s", $time, org.convert2string(), trans.convert2string());
            $stop();
        end
    end
endtask

endmodule

