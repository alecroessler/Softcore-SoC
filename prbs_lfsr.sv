
module prbs_lfsr #(parameter N = 14)(
    input  logic clk,
    input  logic rst,
    output logic [N-1:0] rnd
);
    logic [N-1:0] count, ncount;
    logic feedback;

    // shift register
    parameter START = { {(N-1){1'b0} }, 1'b1}; // 1) {a, b} 2) {a, {b}}

    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            count <= START;
        else
            count <= ncount;
    end

    // build prbs sequence
    assign feedback = count[13] ^ count[4] ^ count[2] ^ count[0]; // taps for 14-bit LFSR: {14,5,3,1}
    assign ncount   = {count[12:0], feedback};
    assign rnd = count;  
endmodule
