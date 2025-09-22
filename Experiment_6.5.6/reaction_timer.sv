
module reaction_timer (
    input logic clk, clear, stop, start,
    output logic led,
    output logic [7:0] an,
    output logic [7:0] sseg
    );

    ////////////////////////// Signal declarations ////////////////////////////////
    // FSM
    typedef enum {init, hold, random_setup, reset_ms, led_on, thousand, nines, done} state_type;
    state_type current_state, next_state;

    // Counters and Timing
    logic [16:0] elapsed_ms, ms_counter;
    
    // Data to be passed to the display driver
    logic [15:0] display_data;
    
    // PRBS_LFSR
    parameter N_lfsr = 14;
    logic [N_lfsr-1:0] random_ms;
    logic [N_lfsr-1:0] random_ms_scaled;
    
    
    ////////////////////////// Instantiate prbs_lfsr psuedo random number generator ////////////////////////
    prbs_lfsr #(N_lfsr) lfsr (
        .clk(clk),
        .rst(clear),
        .rnd(random_ms)
    );
    
    /////////////// Instantiate seven segment display driver ////////////////////////
    seven_seg ss (.*);



    ///////////////////////// Synchronous Logic /////////////////////
    always_ff @(posedge clk, posedge clear) begin
        if (clear) begin
            ms_counter <= 0;
            random_ms_scaled <= 0;
            elapsed_ms <= 0;
            current_state <= init; end
            
        else begin
            current_state <= next_state;

            // Reset counter and increment elapsed milli seconds
            if (ms_counter == 99999) begin
                ms_counter <= 0;
                elapsed_ms <= elapsed_ms + 1; end
            
            // Set output for nines and 1000 special cases
            if (current_state == nines)
                display_data <= 16'h9999;
            else if (current_state == thousand)
                display_data <= 16'h1000;
            else if (current_state == led_on || current_state == done) begin
            
                // BCD Conversion for displaying ms elapsed
                display_data[3:0] <= elapsed_ms % 10;          // Ones digit
                display_data[7:4] <= (elapsed_ms / 10) % 10;   // Tens digit
                display_data[11:8] <= (elapsed_ms / 100) % 10;  // Hundreds digit
                display_data[15:12] <= (elapsed_ms / 1000) % 10; // Thousands digit 
                end

            else if (current_state == init)
                display_data <= 16'hCEBB; // HI
            else begin
                display_data <= 16'hBBBB; // blank display
                if (current_state == random_setup) begin
                elapsed_ms <= 0;
                random_ms_scaled <= 14'd2000 + (random_ms % 14'd13001); end
                else if (current_state == reset_ms)
                elapsed_ms <= 0; end
                
            
            // Pause ms_counter increment if in done state
            if (current_state != done)
                ms_counter <= ms_counter + 1;
            end end
   
    //////////////////////////////// FSM & Combinational Logic //////////////////////////////////
    always_comb begin
        // Default assignments
        next_state = current_state;
        led = 1'b0;
        
        case (current_state)
            init: 
                if (start)
                    next_state = random_setup; 

            random_setup:  
                next_state = hold; 

            hold: begin
                if (elapsed_ms == random_ms_scaled)
                    next_state = reset_ms;
                else if (stop) 
                     next_state = nines; 
                end
                
            reset_ms: 
                next_state = led_on; 

            led_on: begin
                led = 1'b1;

                if (stop)
                    next_state = done;
                else if (elapsed_ms >= 1000) 
                    next_state = thousand;
                end
            
            nines: ;
                
            thousand: ;
                
            done: ;

            default:
                next_state = init;
        endcase
    end
endmodule
