
module seven_seg (
    input  logic clk,     
    input  logic clear,    
    input  logic [15:0] display_data,  
    output logic [7:0] sseg,       
    output logic [7:0] an           
);

    // Counter
    logic [17:0] mux_counter;
    always_ff @(posedge clk, posedge clear) begin
        if (clear)
            mux_counter <= 0;
        else
            mux_counter <= mux_counter + 1;
    end

    logic [1:0] digit_sel;
    assign digit_sel = mux_counter[17:16];

    // Select the 4-bit data from input
    logic [3:0] digit_data;
    always_comb begin
        case(digit_sel)
            2'b00: digit_data = display_data[3:0]; 
            2'b01: digit_data = display_data[7:4];  
            2'b10: digit_data = display_data[11:8]; 
            2'b11: digit_data = display_data[15:12]; 
            default: digit_data = 4'hF;
        endcase
    end


    always_comb begin
        // Default off
        sseg = 8'hFF;
        an = 8'hFF;

        // Convert to sseg hardware can recognize
        case(digit_data)
            4'h0: sseg = 8'hC0; // 0
            4'h1: sseg = 8'hF9; // 1
            4'h2: sseg = 8'hA4; // 2
            4'h3: sseg = 8'hB0; // 3
            4'h4: sseg = 8'h99; // 4
            4'h5: sseg = 8'h92; // 5
            4'h6: sseg = 8'h82; // 6
            4'h7: sseg = 8'hF8; // 7
            4'h8: sseg = 8'h80; // 8
            4'h9: sseg = 8'h90; // 9
            4'hC: sseg = 8'h89; // H
            4'hE: sseg = 8'hCF; // I
            default: sseg = 8'hFF;
        endcase

        // Enable the correct an
        case(digit_sel)
            2'b00: an = 8'b11111110; 
            2'b01: an = 8'b11111101; 
            2'b10: an = 8'b11111011; 
            2'b11: an = 8'b11110111; 
            default: an = 8'hFF;
        endcase
    end

endmodule
