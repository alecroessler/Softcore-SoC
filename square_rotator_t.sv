`timescale 1ns / 1ps

module square_rotator_t;

parameter N = 4; // Low for simulation purposes (one "slowed tick" cycle equals 4 real clk cycles)
logic clk, rst, en, cw;
logic [7:0] an; // enable display
logic [7:0] sseg;  // led segments

// Instantiate our module
square_rotator#(.N(N)) dut(.*);
   
// Start clock
initial begin
    clk = 0;
    forever
    #5 clk =~ clk;
end

// Testing
initial begin
    rst = 0; 
    cw = 1; 
    en = 0;
    
    // Period = 10ps
    #20 en = 1;
    rst = 1; // reset to start
    #10
    rst = 0;
    #160 // ensure full clockwise rotation of squares 
    cw = 0; // reverse direction
    #160;
    #40;
    $finish; 
    end 
endmodule
    