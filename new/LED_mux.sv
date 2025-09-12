`timescale 1ns / 1ps

module LED_mux
    #(parameter N=17) // Refresh rate = 100MHz / (2^17) = ~763Hz
    (
    input clk, rst,
    input[7:0] in0, in1, in2, in3, in4, in5, in6, in7,
    output [7:0] seg_out,
    output reg[7:0] sel_out
    );
    
    // counter for multiplexing
    reg [N-1:0] refresh_counter = 0;
    always @(posedge clk, negedge rst) begin
        if (!rst)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end
    
    // The top 3 bits of the counter select the digit (000 to 111)
    wire [2:0] out_counter = refresh_counter[N-1:N-3];
    
    // Anode select logic
    always @* begin
        sel_out = 8'b11111111; // All off (active-low)
        sel_out[out_counter] = 1'b0;
    end
    
    // Segment data multiplexer logic
    reg [7:0] hex_out;
    always @* begin
        case (out_counter)
            3'b000: hex_out = in0;
            3'b001: hex_out = in1;
            3'b010: hex_out = in2;
            3'b011: hex_out = in3;
            3'b100: hex_out = in4;
            3'b101: hex_out = in5;
            3'b110: hex_out = in6;
            3'b111: hex_out = in7;
            default: hex_out = 8'hFF; // Default to all segments off
        endcase
    end
    
    assign seg_out = hex_out;
    
endmodule