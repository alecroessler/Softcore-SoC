


module spi(
    input logic clk, reset,
    input logic [7:0] din,
    input logic [15:0] dvsr, // 0.5 * (# clk in SCK period)
    input logic start, cpol, cpha,
    output logic [7:0] dout,
    output logic spi_done_tick, ready,
    output logic sclk, mosi,
    input logic miso
    );
    
    // fsm state type
    typedef cnum {idle, cpha_delay, p0, p1} state_type;
    
    // delaration
    state_type state_reg, state_max;
    logic p_clk;
    logic [15:0] c_reg, c_next;
    logic spi_clk_reg, ready_i, spi_done_tick_i;
    logic spi_clk_next
endmodule
