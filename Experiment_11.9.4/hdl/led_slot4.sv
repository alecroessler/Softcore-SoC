module led_slot4
   #(parameter W = 16)  // width of output port
   (
    input  logic clk,
    input  logic reset,
    // slot interface
    input  logic cs,
    input  logic read,
    input  logic write,
    input  logic [4:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data,
    // external port    
    output logic [W-1:0] dout
   );
logic [15:0] interval_reg [0:3], interval_reg_new [0:3];
logic [15:0] led; 

always_ff @(posedge(clk), posedge(reset)) begin
    if (reset) begin
        interval_reg[0] <= 16'd0;
        interval_reg[1] <= 16'd0;
        interval_reg[2] <= 16'd0;
        interval_reg[3] <= 16'd0;
    end
    // Check if the processor is actively writing to this module.
    else if (cs && write) begin
        interval_reg <= interval_reg_new;
    end
end


always_comb begin
    case (addr)
        0: interval_reg_new[0] <= wr_data[15:0];
        1: interval_reg_new[1] <= wr_data[15:0];
        2: interval_reg_new[2] <= wr_data[15:0];
        3: interval_reg_new[3] <= wr_data[15:0];
        default: interval_reg_new[0] <= wr_data[15:0];
    endcase
end




timer led1(.led_out(led[15]), .delay_ms(interval_reg[0]), .clk(clk), .reset(reset));
timer led2(.led_out(led[14]), .delay_ms(interval_reg[1]), .clk(clk), .reset(reset));
timer led3(.led_out(led[13]), .delay_ms(interval_reg[2]), .clk(clk), .reset(reset));
timer led4(.led_out(led[12]), .delay_ms(interval_reg[3]), .clk(clk), .reset(reset));


assign rd_data = 0;
assign dout = led;
//assign dout = 16'b1010101010101010;

endmodule
      
   
