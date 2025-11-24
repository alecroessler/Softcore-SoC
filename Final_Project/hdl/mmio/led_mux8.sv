module led_mux8
   (
    input  logic clk, reset,
    input  logic [7:0] in3, in2, in1, in0,
    input  logic [7:0] in7, in6, in5, in4,
    input logic [2:0] active_segment, ///////////////////////////////////////////////////////
    input logic seg_enable,
    output logic [7:0] an,   // enable, 1-out-of-8 asserted low
    output logic [7:0] sseg  // led segments
   );

   // constant declaration
   // refreshing rate around 1600 Hz (100MHz/2^16) 
   // 24 bits for around 7 Hz will use above as well (bits 17-15)
   localparam N = 24;            ////////////////////////////////////////////

   // declaration
   logic [N-1:0] q_reg, q_next;

   // N-bit counter
   // register
   always_ff @(posedge clk,  posedge reset)
      if (reset)
         q_reg <= 0;
      else
         q_reg <= q_next;

   // next-state logic
   assign q_next = q_reg + 1;

   // 3 bits of counter to control 8-to-1 multiplexing
   // and to generate active-low enable signal
   // This was altered to be 17:15 as needed 24 bit counter
   logic blink;//////////////////////////////////////////////////////////////
   assign blink = q_reg[N-1]; ///////////////////////////////////////////////////
   logic [2:0] current_segment; ////////////////////////////////////////////////////////
   logic [7:0] intermediate_sseg;  ///////////////////////////////////////////////////////
   always_comb begin ///////////////////////////////////////////////////////
      current_segment = q_reg[17:15]; //////////////////////////////////////
      unique case (current_segment)   ////////////////////////////////////////////////////
         3'b000: begin
            an = 8'b1111_1110;
            intermediate_sseg = in0;//////////////////////////////////////////////////////
         end
         3'b001: begin
            an = 8'b1111_1101;
            intermediate_sseg = in1;///////////////////////////////
         end
         3'b010: begin
            an = 8'b1111_1011;
            intermediate_sseg = in2;////////////////////////
         end
         3'b011: begin
            an = 8'b1111_0111;
            intermediate_sseg = in3;///////////////////
         end
         3'b100: begin
            an = 8'b1110_1111;
            intermediate_sseg = in4;////////////////////////////
         end
         3'b101: begin
            an = 8'b1101_1111;
            intermediate_sseg = in5;///////////////////////////////
         end
         3'b110: begin
            an = 8'b1011_1111;
            intermediate_sseg = in6;///////////////////////////////
         end
         default: begin
            an = 8'b0111_1111;
            intermediate_sseg = in7;////////////////////////////////
         end
       endcase
       
       
       if ((current_segment == active_segment) && blink && seg_enable) ////////////////////////////
            sseg = 8'hFF; /////////////////////////////////////////////////
       else/////////////////////////////////////////////////////////////
            sseg = intermediate_sseg;/////////////////////////////////////
            
       end /////////////////////////////////////////////////////////
endmodule
