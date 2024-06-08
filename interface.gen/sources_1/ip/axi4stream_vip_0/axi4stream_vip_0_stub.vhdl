-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.2.2 (win64) Build 4126759 Thu Feb  8 23:53:51 MST 2024
-- Date        : Sat Jun  8 21:04:57 2024
-- Host        : Desktop-XVRi running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               w:/home/roman/sito/FPGA-HAT/fw/interface/interface.gen/sources_1/ip/axi4stream_vip_0/axi4stream_vip_0_stub.vhdl
-- Design      : axi4stream_vip_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7s6ftgb196-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axi4stream_vip_0 is
  Port ( 
    aclk : in STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tready : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_tlast : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_tdest : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tuser : out STD_LOGIC_VECTOR ( 3 downto 0 )
  );

end axi4stream_vip_0;

architecture stub of axi4stream_vip_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "aclk,m_axis_tvalid[0:0],m_axis_tready[0:0],m_axis_tdata[31:0],m_axis_tlast[0:0],m_axis_tdest[7:0],m_axis_tuser[3:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "axi4stream_vip_v1_1_16_top,Vivado 2023.2.2";
begin
end;
