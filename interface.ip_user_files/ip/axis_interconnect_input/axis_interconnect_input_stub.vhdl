-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.2.2 (win64) Build 4126759 Thu Feb  8 23:53:51 MST 2024
-- Date        : Tue Mar 12 11:50:59 2024
-- Host        : DESKTOP-JRU94P5 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               w:/home/roman/FPGA-HAT/fw/interface/interface.gen/sources_1/ip/axis_interconnect_input/axis_interconnect_input_stub.vhdl
-- Design      : axis_interconnect_input
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7s6ftgb196-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axis_interconnect_input is
  Port ( 
    ACLK : in STD_LOGIC;
    ARESETN : in STD_LOGIC;
    S00_AXIS_ACLK : in STD_LOGIC;
    S00_AXIS_ARESETN : in STD_LOGIC;
    S00_AXIS_TVALID : in STD_LOGIC;
    S00_AXIS_TREADY : out STD_LOGIC;
    S00_AXIS_TDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXIS_TLAST : in STD_LOGIC;
    S00_AXIS_TDEST : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S00_AXIS_TUSER : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXIS_ACLK : in STD_LOGIC;
    M01_AXIS_ACLK : in STD_LOGIC;
    M02_AXIS_ACLK : in STD_LOGIC;
    M03_AXIS_ACLK : in STD_LOGIC;
    M04_AXIS_ACLK : in STD_LOGIC;
    M00_AXIS_ARESETN : in STD_LOGIC;
    M01_AXIS_ARESETN : in STD_LOGIC;
    M02_AXIS_ARESETN : in STD_LOGIC;
    M03_AXIS_ARESETN : in STD_LOGIC;
    M04_AXIS_ARESETN : in STD_LOGIC;
    M00_AXIS_TVALID : out STD_LOGIC;
    M01_AXIS_TVALID : out STD_LOGIC;
    M02_AXIS_TVALID : out STD_LOGIC;
    M03_AXIS_TVALID : out STD_LOGIC;
    M04_AXIS_TVALID : out STD_LOGIC;
    M00_AXIS_TREADY : in STD_LOGIC;
    M01_AXIS_TREADY : in STD_LOGIC;
    M02_AXIS_TREADY : in STD_LOGIC;
    M03_AXIS_TREADY : in STD_LOGIC;
    M04_AXIS_TREADY : in STD_LOGIC;
    M00_AXIS_TDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M01_AXIS_TDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M02_AXIS_TDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M03_AXIS_TDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M04_AXIS_TDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXIS_TLAST : out STD_LOGIC;
    M01_AXIS_TLAST : out STD_LOGIC;
    M02_AXIS_TLAST : out STD_LOGIC;
    M03_AXIS_TLAST : out STD_LOGIC;
    M04_AXIS_TLAST : out STD_LOGIC;
    M00_AXIS_TDEST : out STD_LOGIC_VECTOR ( 5 downto 0 );
    M01_AXIS_TDEST : out STD_LOGIC_VECTOR ( 5 downto 0 );
    M02_AXIS_TDEST : out STD_LOGIC_VECTOR ( 5 downto 0 );
    M03_AXIS_TDEST : out STD_LOGIC_VECTOR ( 5 downto 0 );
    M04_AXIS_TDEST : out STD_LOGIC_VECTOR ( 5 downto 0 );
    M00_AXIS_TUSER : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M01_AXIS_TUSER : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M02_AXIS_TUSER : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M03_AXIS_TUSER : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M04_AXIS_TUSER : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_DECODE_ERR : out STD_LOGIC;
    S00_FIFO_DATA_COUNT : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M01_SPARSE_TKEEP_REMOVED : out STD_LOGIC;
    M02_SPARSE_TKEEP_REMOVED : out STD_LOGIC;
    M03_SPARSE_TKEEP_REMOVED : out STD_LOGIC;
    M04_SPARSE_TKEEP_REMOVED : out STD_LOGIC
  );

end axis_interconnect_input;

architecture stub of axis_interconnect_input is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "ACLK,ARESETN,S00_AXIS_ACLK,S00_AXIS_ARESETN,S00_AXIS_TVALID,S00_AXIS_TREADY,S00_AXIS_TDATA[31:0],S00_AXIS_TLAST,S00_AXIS_TDEST[5:0],S00_AXIS_TUSER[3:0],M00_AXIS_ACLK,M01_AXIS_ACLK,M02_AXIS_ACLK,M03_AXIS_ACLK,M04_AXIS_ACLK,M00_AXIS_ARESETN,M01_AXIS_ARESETN,M02_AXIS_ARESETN,M03_AXIS_ARESETN,M04_AXIS_ARESETN,M00_AXIS_TVALID,M01_AXIS_TVALID,M02_AXIS_TVALID,M03_AXIS_TVALID,M04_AXIS_TVALID,M00_AXIS_TREADY,M01_AXIS_TREADY,M02_AXIS_TREADY,M03_AXIS_TREADY,M04_AXIS_TREADY,M00_AXIS_TDATA[31:0],M01_AXIS_TDATA[31:0],M02_AXIS_TDATA[31:0],M03_AXIS_TDATA[31:0],M04_AXIS_TDATA[31:0],M00_AXIS_TLAST,M01_AXIS_TLAST,M02_AXIS_TLAST,M03_AXIS_TLAST,M04_AXIS_TLAST,M00_AXIS_TDEST[5:0],M01_AXIS_TDEST[5:0],M02_AXIS_TDEST[5:0],M03_AXIS_TDEST[5:0],M04_AXIS_TDEST[5:0],M00_AXIS_TUSER[3:0],M01_AXIS_TUSER[3:0],M02_AXIS_TUSER[3:0],M03_AXIS_TUSER[3:0],M04_AXIS_TUSER[3:0],S00_DECODE_ERR,S00_FIFO_DATA_COUNT[31:0],M01_SPARSE_TKEEP_REMOVED,M02_SPARSE_TKEEP_REMOVED,M03_SPARSE_TKEEP_REMOVED,M04_SPARSE_TKEEP_REMOVED";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "axis_interconnect_v1_1_22_axis_interconnect_16x16_top,Vivado 2023.2.2";
begin
end;
