// (c) Copyright 2023 Advanced Micro Devices, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
////////////////////////////////////////////////////////////
#include "axi_stream_vip.h"
#include <sstream>

axi_stream_vip::axi_stream_vip(sc_core::sc_module_name module_name,xsc::common_cpp::properties model_param_props) :
	sc_module(module_name), S_TARGET_socket(nullptr), M_INITIATOR_socket(nullptr), sim_ipc_multi_intf(nullptr) {
    int reset_cycles=0;
    model_param_props.addLong("C_INIT_RESET_CYCLES", std::to_string(reset_cycles));
    int int_type=model_param_props.getLongLong("C_AXI4STREAM_INTERFACE_MODE");
    int data_width=model_param_props.getLongLong("C_AXI4STREAM_DATA_WIDTH");
    if(int_type==1) {
       int NUM_MI=1;
       int NUM_SI=1;
       model_param_props.addLong("C_NUM_MI", std::to_string(NUM_MI));
       model_param_props.addLong("C_NUM_SI", std::to_string(NUM_SI));
       model_param_props.addLong("C_M00_AXIS_TDATA_WIDTH", std::to_string(data_width/8));
       model_param_props.addLong("C_S00_AXIS_TDATA_WIDTH", std::to_string(data_width/8));

		   M_INITIATOR_socket = new xtlm::xtlm_axis_initiator_socket("initiator_rd_socket",32);
	 	   S_TARGET_socket = new xtlm::xtlm_axis_target_socket("target_rd_socket",32);
       initiator_util_0 = new xtlm::xtlm_axis_initiator_socket_util("initiator_util_0",
			 xtlm::axis::TRANSACTION, 32);
       target_util_0 = new xtlm::xtlm_axis_target_socket_util("target_util_0",
			 xtlm::axis::TRANSACTION, 32);
	     //binding of sockets
	     S_TARGET_socket->bind(target_util_0->stream_socket);
       initiator_util_0->stream_socket.bind(*M_INITIATOR_socket);

       sim_ipc_multi_intf = new sim_ipc_axis_multi_intf(this->name(),
					model_param_props);
       sim_ipc_multi_intf->clk(aclk);
			 sim_ipc_multi_intf->aresetn(aresetn);


       initiator_util_1 = new xtlm::xtlm_axis_initiator_socket_util("initiator_util_1",
			 xtlm::axis::TRANSACTION, 32);
       target_util_1 = new xtlm::xtlm_axis_target_socket_util("target_util_1",
			 xtlm::axis::TRANSACTION, 32);
       sim_ipc_multi_intf->m_initiator_sockets[0]->bind(target_util_1->stream_socket);
       initiator_util_1->stream_socket.bind(*sim_ipc_multi_intf->m_target_sockets[0]);
       SC_METHOD(trans_handler);
	     sensitive << target_util_0->transaction_available;
       sensitive << initiator_util_1->transfer_done;
       sensitive << initiator_util_0->transfer_done;
       sensitive << target_util_1->transaction_available;
       dont_initialize();
 
    }
    if(int_type==0) {
       int NUM_MI=1;
       int NUM_SI=0;
       model_param_props.addLong("C_NUM_MI", std::to_string(NUM_MI));
       model_param_props.addLong("C_NUM_SI", std::to_string(NUM_SI));
       model_param_props.addLong("C_M00_AXIS_TDATA_WIDTH", std::to_string(data_width/8));
       model_param_props.addLong("C_S00_AXIS_TDATA_WIDTH", std::to_string(NUM_SI));

       M_INITIATOR_socket = new xtlm::xtlm_axis_initiator_socket("initiator_rd_socket",32);
       sim_ipc_multi_intf = new sim_ipc_axis_multi_intf(this->name(),
					model_param_props);
       sim_ipc_multi_intf->clk(aclk);
			 sim_ipc_multi_intf->aresetn(aresetn);
       sim_ipc_multi_intf->m_initiator_sockets[0]->bind(*M_INITIATOR_socket);

    }
    if(int_type==2) {
       int NUM_MI=0;
       int NUM_SI=1;
       model_param_props.addLong("C_NUM_MI", std::to_string(NUM_MI));
       model_param_props.addLong("C_NUM_SI", std::to_string(NUM_SI));
       model_param_props.addLong("C_M00_AXIS_TDATA_WIDTH", std::to_string(NUM_MI));
       model_param_props.addLong("C_S00_AXIS_TDATA_WIDTH", std::to_string(data_width/8));
       S_TARGET_socket = new xtlm::xtlm_axis_target_socket("target_rd_socket",32);
       sim_ipc_multi_intf = new sim_ipc_axis_multi_intf(this->name(),
					model_param_props);
       sim_ipc_multi_intf->clk(aclk);
			 sim_ipc_multi_intf->aresetn(aresetn);
       S_TARGET_socket->bind(*sim_ipc_multi_intf->m_target_sockets[0]);
    }
}

axi_stream_vip::~axi_stream_vip() {
	delete M_INITIATOR_socket;
	delete S_TARGET_socket;

}

void axi_stream_vip::trans_handler() {
    // Checking to see the ipc_connection is there
    bool ipc_connected = (sim_ipc_multi_intf->is_external_proc_connected());
    if(!ipc_connected) {
       // For no IPC connection Direct transfer from slave to master in passthrough mode
        if(initiator_util_0->is_transfer_done() && 
            target_util_0->is_transaction_available() )
      {
          auto m_trans = target_util_0->sample_transaction();
          sc_core::sc_time zero_delay = SC_ZERO_TIME;
          initiator_util_0->transport(m_trans,
				  zero_delay);
      } 
    } else {
       // For IPC connection Direct transfer from slave to IPC slave and then IPC master to master in passthrough mode
        if(initiator_util_1->is_transfer_done() && 
            target_util_0->is_transaction_available() )
       {
          auto m_trans = target_util_0->sample_transaction();
          sc_core::sc_time zero_delay = SC_ZERO_TIME;
          initiator_util_1->transport(m_trans,
	  		  zero_delay);

       }
       // For IPC connection Direct transfer from slave to IPC slave and then IPC master to master in passthrough mode
        if(initiator_util_0->is_transfer_done() && 
            target_util_1->is_transaction_available() )
        {
          auto m_trans = target_util_1->sample_transaction();
          sc_core::sc_time zero_delay = SC_ZERO_TIME;
          initiator_util_0->transport(m_trans,
	  		  zero_delay);
       }
    }
}
