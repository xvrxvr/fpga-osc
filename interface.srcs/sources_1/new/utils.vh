`define DLY_TGN(Type, Dst, Var, Gate, N) Type Dst;  utils_dly #(N, Type) Dst``_``Var``_delaymodule``N(.clk, .in(Var), .out(Dst), .ce(Gate), .out_scale())

`define DLY(Dst, Var)  `DLY_TGN(logic, Dst, Var, 1'b1, 1)
`define DLY2(Dst, Var) `DLY_TGN(logic, Dst, Var, 1'b1, 2)
`define DLY3(Dst, Var) `DLY_TGN(logic, Dst, Var, 1'b1, 3)
`define DLY4(Dst, Var) `DLY_TGN(logic, Dst, Var, 1'b1, 4)

`define DLY_T(Type, Dst, Var)  `DLY_TGN(Type, Dst, Var, 1'b1, 1)
`define DLY2_T(Type, Dst, Var) `DLY_TGN(Type, Dst, Var, 1'b1, 2)
`define DLY3_T(Type, Dst, Var) `DLY_TGN(Type, Dst, Var, 1'b1, 3)
`define DLY4_T(Type, Dst, Var) `DLY_TGN(Type, Dst, Var, 1'b1, 4)

`define DLY_G(Dst, Var, Gate)  `DLY_TGN(logic, Dst, Var, Gate, 1)
`define DLY2_G(Dst, Var, Gate) `DLY_TGN(logic, Dst, Var, Gate, 2)
`define DLY3_G(Dst, Var, Gate) `DLY_TGN(logic, Dst, Var, Gate, 3)
`define DLY4_G(Dst, Var, Gate) `DLY_TGN(logic, Dst, Var, Gate, 4)

`define DLY_TG(Type, Dst, Var, Gate)  `DLY_TGN(Type, Dst, Var, Gate, 1)
`define DLY2_TG(Type, Dst, Var, Gate) `DLY_TGN(Type, Dst, Var, Gate, 2)
`define DLY3_TG(Type, Dst, Var, Gate) `DLY_TGN(Type, Dst, Var, Gate, 3)
`define DLY4_TG(Type, Dst, Var, Gate) `DLY_TGN(Type, Dst, Var, Gate, 4)

`define PEDGE(Dst, Var) `DLY(Dst``_``Var``_dly, Var); wire Dst = Var & ~Dst``_``Var``_dly
`define NEDGE(Dst, Var) `DLY(Dst``_``Var``_dly, Var); wire Dst = ~Var & Dst``_``Var``_dly
`define EDGE(Dst, Var)  `DLY(Dst``_``Var``_dly, Var); wire Dst = Var ^ Dst``_``Var``_dly

`define UNUSED(Signal) unused _unused_modiule_inst```__LINE__ (&{1'b0,Signal,1'b0})

`define USED_PART(Type, Signal) `UNUSED(Signal[31:$bits(Type)])
