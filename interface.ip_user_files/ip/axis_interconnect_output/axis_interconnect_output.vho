-- (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- (c) Copyright 2022-2024 Advanced Micro Devices, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of AMD and is protected under U.S. and international copyright
-- and other intellectual property laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- AMD, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) AMD shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or AMD had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- AMD products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of AMD products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.
-- IP VLNV: xilinx.com:ip:axis_interconnect:1.1
-- IP Revision: 22

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT axis_interconnect_output
  PORT (
    ACLK : IN STD_LOGIC;
    ARESETN : IN STD_LOGIC;
    S00_AXIS_ACLK : IN STD_LOGIC;
    S01_AXIS_ACLK : IN STD_LOGIC;
    S02_AXIS_ACLK : IN STD_LOGIC;
    S03_AXIS_ACLK : IN STD_LOGIC;
    S04_AXIS_ACLK : IN STD_LOGIC;
    S00_AXIS_ARESETN : IN STD_LOGIC;
    S01_AXIS_ARESETN : IN STD_LOGIC;
    S02_AXIS_ARESETN : IN STD_LOGIC;
    S03_AXIS_ARESETN : IN STD_LOGIC;
    S04_AXIS_ARESETN : IN STD_LOGIC;
    S00_AXIS_TVALID : IN STD_LOGIC;
    S01_AXIS_TVALID : IN STD_LOGIC;
    S02_AXIS_TVALID : IN STD_LOGIC;
    S03_AXIS_TVALID : IN STD_LOGIC;
    S04_AXIS_TVALID : IN STD_LOGIC;
    S00_AXIS_TREADY : OUT STD_LOGIC;
    S01_AXIS_TREADY : OUT STD_LOGIC;
    S02_AXIS_TREADY : OUT STD_LOGIC;
    S03_AXIS_TREADY : OUT STD_LOGIC;
    S04_AXIS_TREADY : OUT STD_LOGIC;
    S00_AXIS_TDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    S01_AXIS_TDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    S02_AXIS_TDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    S03_AXIS_TDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    S04_AXIS_TDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    S00_AXIS_TLAST : IN STD_LOGIC;
    S01_AXIS_TLAST : IN STD_LOGIC;
    S02_AXIS_TLAST : IN STD_LOGIC;
    S03_AXIS_TLAST : IN STD_LOGIC;
    S04_AXIS_TLAST : IN STD_LOGIC;
    S00_AXIS_TDEST : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S01_AXIS_TDEST : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S02_AXIS_TDEST : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S03_AXIS_TDEST : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S04_AXIS_TDEST : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    S00_AXIS_TUSER : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S01_AXIS_TUSER : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S02_AXIS_TUSER : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S03_AXIS_TUSER : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    S04_AXIS_TUSER : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    M00_AXIS_ACLK : IN STD_LOGIC;
    M00_AXIS_ARESETN : IN STD_LOGIC;
    M00_AXIS_TVALID : OUT STD_LOGIC;
    M00_AXIS_TREADY : IN STD_LOGIC;
    M00_AXIS_TDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    M00_AXIS_TLAST : OUT STD_LOGIC;
    M00_AXIS_TDEST : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M00_AXIS_TUSER : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    S00_ARB_REQ_SUPPRESS : IN STD_LOGIC;
    S01_ARB_REQ_SUPPRESS : IN STD_LOGIC;
    S02_ARB_REQ_SUPPRESS : IN STD_LOGIC;
    S03_ARB_REQ_SUPPRESS : IN STD_LOGIC;
    S04_ARB_REQ_SUPPRESS : IN STD_LOGIC;
    S00_DECODE_ERR : OUT STD_LOGIC;
    S01_DECODE_ERR : OUT STD_LOGIC;
    S02_DECODE_ERR : OUT STD_LOGIC;
    S03_DECODE_ERR : OUT STD_LOGIC;
    S04_DECODE_ERR : OUT STD_LOGIC;
    M00_FIFO_DATA_COUNT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : axis_interconnect_output
  PORT MAP (
    ACLK => ACLK,
    ARESETN => ARESETN,
    S00_AXIS_ACLK => S00_AXIS_ACLK,
    S01_AXIS_ACLK => S01_AXIS_ACLK,
    S02_AXIS_ACLK => S02_AXIS_ACLK,
    S03_AXIS_ACLK => S03_AXIS_ACLK,
    S04_AXIS_ACLK => S04_AXIS_ACLK,
    S00_AXIS_ARESETN => S00_AXIS_ARESETN,
    S01_AXIS_ARESETN => S01_AXIS_ARESETN,
    S02_AXIS_ARESETN => S02_AXIS_ARESETN,
    S03_AXIS_ARESETN => S03_AXIS_ARESETN,
    S04_AXIS_ARESETN => S04_AXIS_ARESETN,
    S00_AXIS_TVALID => S00_AXIS_TVALID,
    S01_AXIS_TVALID => S01_AXIS_TVALID,
    S02_AXIS_TVALID => S02_AXIS_TVALID,
    S03_AXIS_TVALID => S03_AXIS_TVALID,
    S04_AXIS_TVALID => S04_AXIS_TVALID,
    S00_AXIS_TREADY => S00_AXIS_TREADY,
    S01_AXIS_TREADY => S01_AXIS_TREADY,
    S02_AXIS_TREADY => S02_AXIS_TREADY,
    S03_AXIS_TREADY => S03_AXIS_TREADY,
    S04_AXIS_TREADY => S04_AXIS_TREADY,
    S00_AXIS_TDATA => S00_AXIS_TDATA,
    S01_AXIS_TDATA => S01_AXIS_TDATA,
    S02_AXIS_TDATA => S02_AXIS_TDATA,
    S03_AXIS_TDATA => S03_AXIS_TDATA,
    S04_AXIS_TDATA => S04_AXIS_TDATA,
    S00_AXIS_TLAST => S00_AXIS_TLAST,
    S01_AXIS_TLAST => S01_AXIS_TLAST,
    S02_AXIS_TLAST => S02_AXIS_TLAST,
    S03_AXIS_TLAST => S03_AXIS_TLAST,
    S04_AXIS_TLAST => S04_AXIS_TLAST,
    S00_AXIS_TDEST => S00_AXIS_TDEST,
    S01_AXIS_TDEST => S01_AXIS_TDEST,
    S02_AXIS_TDEST => S02_AXIS_TDEST,
    S03_AXIS_TDEST => S03_AXIS_TDEST,
    S04_AXIS_TDEST => S04_AXIS_TDEST,
    S00_AXIS_TUSER => S00_AXIS_TUSER,
    S01_AXIS_TUSER => S01_AXIS_TUSER,
    S02_AXIS_TUSER => S02_AXIS_TUSER,
    S03_AXIS_TUSER => S03_AXIS_TUSER,
    S04_AXIS_TUSER => S04_AXIS_TUSER,
    M00_AXIS_ACLK => M00_AXIS_ACLK,
    M00_AXIS_ARESETN => M00_AXIS_ARESETN,
    M00_AXIS_TVALID => M00_AXIS_TVALID,
    M00_AXIS_TREADY => M00_AXIS_TREADY,
    M00_AXIS_TDATA => M00_AXIS_TDATA,
    M00_AXIS_TLAST => M00_AXIS_TLAST,
    M00_AXIS_TDEST => M00_AXIS_TDEST,
    M00_AXIS_TUSER => M00_AXIS_TUSER,
    S00_ARB_REQ_SUPPRESS => S00_ARB_REQ_SUPPRESS,
    S01_ARB_REQ_SUPPRESS => S01_ARB_REQ_SUPPRESS,
    S02_ARB_REQ_SUPPRESS => S02_ARB_REQ_SUPPRESS,
    S03_ARB_REQ_SUPPRESS => S03_ARB_REQ_SUPPRESS,
    S04_ARB_REQ_SUPPRESS => S04_ARB_REQ_SUPPRESS,
    S00_DECODE_ERR => S00_DECODE_ERR,
    S01_DECODE_ERR => S01_DECODE_ERR,
    S02_DECODE_ERR => S02_DECODE_ERR,
    S03_DECODE_ERR => S03_DECODE_ERR,
    S04_DECODE_ERR => S04_DECODE_ERR,
    M00_FIFO_DATA_COUNT => M00_FIFO_DATA_COUNT
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file axis_interconnect_output.vhd when simulating
-- the core, axis_interconnect_output. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.



