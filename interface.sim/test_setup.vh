`ifndef _TEST_SETUP_w2376842376864_
`define _TEST_SETUP_w2376842376864_

const int VERB = 0;

typedef enum logic [31:0] {
    O_ESC_Data = 32'hA325213C,
    O_ESC_Stat,
    O_SEC_Wait,
    O_ESC_Pkt
} OutEscTest;

typedef enum logic [31:0] {
    I_ESC_Data = 32'hFF92909E,
    I_ESC_IET_Skip
} InEscTest;

// Common definition for all test modules
`define START `R(start)
`define STOP `R(stop)
`define TEST fork `R(run); join; `R(check_finish)

`endif
