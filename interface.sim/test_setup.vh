`ifndef _TEST_SETUP_w2376842376864_
`define _TEST_SETUP_w2376842376864_

const int VERB = 0;


// Common definition for all test modules
`define START `R(start)
`define STOP `R(stop)
`define TEST fork `R(run); join; `R(check_finish)

`endif
