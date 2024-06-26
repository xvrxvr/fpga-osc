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
    logic [9:0] padding;
    ErrorScale errors;
    logic [9:0] fpga2host_fifo_filled;
    logic [9:0] host2fpga_fifo_empty;
} StatusPayload;

typedef enum logic [7:0] {
    DST_SYSTEM,
    DST_LA,
    DST_SEQ,
    DST_OSC,
    DST_GEN
} DestTypes;

const logic [31:0] FIFO_SIZE = 32;

function automatic [7:0] get_dest(CmdPkt cmd);
    return cmd.dest;
endfunction 

const logic [29:0] OutESC = 30'h28C9484F;
const logic [30:0] InESC =  31'h7FC9484F;

typedef enum logic [1:0] {
    ET_Data,
    ET_Stat,
    ET_Wait,
    ET_Pkt
} SECType;

typedef enum logic {
    IET_Data,
    IET_Skip
} SECInType;

typedef struct packed {
    logic [5:0] unused;
    logic use_in_esc;
} SPI_FIFO_Ctrl;

endpackage
