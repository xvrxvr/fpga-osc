package SPIInterf;

// Data word
typedef struct packed {
    logic data_tag; // Must be 1
    logic [30:0] data;
} DataPkt;

// High bits packet
typedef struct packed {
    logic [1:0] bs_tag; // Must be 01
    logic [29:0] high_bits; 
} BitStuffPkt;

// Command
typedef struct packed {
    logic [1:0] cmd_tag; // Must be 00
    logic [5:0] dest;   // Destination
    logic [23:0] payload;
} CmdPkt;

// 'payload' field for Register/BRAM access
typedef struct packed {
    logic [3:0] section;
    logic [19:0] address;
} RegRAMPayload;

// Status packet format
typedef struct packed {
    logic host2fpga_overflow;
    logic fpga2host_overflow;
} ErrorScale;

typedef struct packed {
    logic [4:0] padding;
    logic buf_reg_filled; // Intermidiate buffer register filled
    ErrorScale errors;
    logic oob_answer; // This is answer to OOB request
    logic delimiter; // This is Packet Delimiter (previous Packet done)
    logic [7:0] fpga2host_fifo_filled;
    logic [7:0] hos3fpgat_fifo_empty;
} StatusPayload;

typedef union packed {
    DataPkt data;
    BitStuffPkt bit_stuf;
    CmdPkt cmd;
} Pkt;

typedef enum logic [1:0] {
    PT_BitStuff = 2'b01,
    PT_Cmd = 2'b00
} PktType;

typedef enum logic [5:0] {
    DST_SYSTEM,
    DST_LA,
    DST_SEQ,
    DST_OSC,
    DST_GEN
} DestTypes;

function automatic [1:0] get_tag(CmdPkt cmd);
    return cmd.cmd_tag;
endfunction 

function automatic [1:0] get_dest(CmdPkt cmd);
    return cmd.dest;
endfunction 

endpackage
