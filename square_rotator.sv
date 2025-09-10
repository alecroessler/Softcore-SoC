`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 01:08:27 PM
// Design Name: 
// Module Name: square_rotator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module square_rotator(
    input logic clk,
    input logic rst,
    input logic en,
    input logic cw,
    output logic [7:0] an,
    output logic [7:0] sseg
    );
    
    
    // Counter setup
    parameter N = 28; 
    logic [N-1:0] q_reg;
    logic [N-1:0] q_next;
    
    // N-bit counter
    always_ff @(posedge clk, posedge rst)
        if (rst)
            q_reg <= 0;
        else
            q_reg <= q_next;
    
    assign q_next = en ? q_reg + 1 : q_reg; // Increment q_next reg if enable pin is high 
    
    // LED States corresponding to two square combinations (active low) (dp,g,f,e,d,c,b,a)
    parameter sseg_top = 8'b10011100;
    parameter sseg_bottom = 8'b10100011;

    // 2 MSB's of counter to control state multiplexing
    // Has reversing functionality by bit-wise not
    logic [2:0] control;
    assign control = cw ? q_reg[N-1:N-3] : ~q_reg[N-1:N-3];
    always_comb
        case(control)
            3'b000:
                begin
                    sseg = sseg_top;
                    an = 4'b0111;
                end
            3'b001:
                begin
                    sseg = sseg_top;
                    an = 4'b1011;
                end
            3'b010:
                begin
                    sseg = sseg_top;
                    an = 4'b1101;
                end
            3'b011:
                begin
                    sseg = sseg_top;
                    an = 4'b1110;
                end
            3'b100:
                begin
                    sseg = sseg_bottom;
                    an = 4'b1110;
                end
            3'b101:
                begin
                    sseg = sseg_bottom;
                    an = 4'b1101;
                end
            3'b110:
                begin
                    sseg = sseg_bottom;
                    an = 4'b1011;
                end
            3'b111:
                begin
                    sseg = sseg_bottom;
                    an = 4'b0111;
                end
        endcase
    assign an[7:4] = 4'b1111; // Set other 4 sseg displays to off
endmodule
