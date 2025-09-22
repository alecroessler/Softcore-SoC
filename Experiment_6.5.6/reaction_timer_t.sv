`timescale 1ns / 1ps

module reaction_timer_t;

    // Testbench signals
    logic clk, clear, start, stop;
    logic led;
    logic [7:0] an, sseg;

    // Instantiate the DUT
    reaction_timer dut (.*);

    initial clk = 0;
    always #5 clk = ~clk;

    // test
    initial begin
        // Initialize inputs
        clear = 1;
        start = 0;
        stop  = 0;

        // Apply reset
        #10;
        clear = 0;
        #10;

        // Start the reaction timer
        start = 1;
        #10;
        start = 0;
        #10;

        // User presses stop
        stop = 1;
        #10;
        stop = 0;

        // In thousand state
        #(30);

        $finish;
    end

endmodule
