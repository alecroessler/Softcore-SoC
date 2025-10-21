
module timer (
    input  logic clk,
    input  logic reset,
    input  logic [15:0] delay_ms,
    output logic led_out
);

    logic [31:0] count, ncount;
    logic [15:0] ms_count;
    logic led;

    always_ff @(posedge(clk), posedge(reset)) begin
        if (reset) begin
            count <= 0;
            ms_count <= 0;
            led <= 0;
        end else begin
            if (count >= 99_999) begin 
                count <= 0;
                ms_count <= ms_count + 1;
                if (ms_count >= delay_ms) begin
                    ms_count <= 0;
                    led <= ~led;  
                end
            end
            else count <= ncount;
        end
    end
    
assign ncount = count + 1;
assign led_out = led;    

endmodule

