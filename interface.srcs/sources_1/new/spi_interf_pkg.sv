package SPIInterf;

// Data word
// Command
typedef struct packed {
    logic [7:0] dest;   // Destination
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
    logic [8:0] padding;
    ErrorScale errors;
    logic buf_reg_filled; // Intermidiate buffer register filled
    logic [9:0] fpga2host_fifo_filled;
    logic [9:0] host2fpga_fifo_empty;
} StatusPayload;

// FIFO ctrl SPI data words
typedef struct packed {
    ErrorScale errors;
    logic buf_reg_filled; // Intermidiate buffer register filled
    logic [3:0] zero; // Should be 0
    logic one; // Should be 1
} FifoCtrlSPIW1;

typedef enum logic [5:0] {
    DST_SYSTEM,
    DST_LA,
    DST_SEQ,
    DST_OSC,
    DST_GEN
} DestTypes;

function automatic [7:0] get_dest(CmdPkt cmd);
    return cmd.dest;
endfunction 

const logic [29:0] OutESC = 30'h28C9484F;

typedef enum logic [1:0] {
    ET_Data,
    ET_Stat,
    ET_Wait,
    ET_Pkt
} SECTyope;

endpackage
