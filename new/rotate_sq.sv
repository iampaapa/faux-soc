`timescale 1ns / 1ps

module rotate_sq
    #(parameter base_counter = 10_000_000)
    (
    input clk, rst_n,
    input cw, en,
    output reg[7:0] in0, in1, in2, in3, in4, in5, in6, in7
    );

    reg [23:0] mod_counter = 0;
    // 16-state machine to cover all 8 digits with 2 patterns
    reg [3:0] state = 0; 
    
    // Registers for state and speed control
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            mod_counter <= 0;
            state <= 0;
        end else if (en) begin // Only advance if enabled
            if (mod_counter == base_counter - 1) begin
                mod_counter <= 0;
                if (cw) // Clockwise
                    state <= (state == 15) ? 0 : state + 1;
                else // Counter-clockwise
                    state <= (state == 0) ? 15 : state - 1;
            end else begin
                mod_counter <= mod_counter + 1;
            end
        end
    end
    
    always @* begin
        // Default all displays to off
        in0=8'hff; in1=8'hff; in2=8'hff; in3=8'hff;
        in4=8'hff; in5=8'hff; in6=8'hff; in7=8'hff;
        
        case(state)
            // States 0-7: Upper box pattern (9C)
            4'd0:  in0 = 8'h9C;
            4'd1:  in1 = 8'h9C;
            4'd2:  in2 = 8'h9C;
            4'd3:  in3 = 8'h9C;
            4'd4:  in4 = 8'h9C;
            4'd5:  in5 = 8'h9C;
            4'd6:  in6 = 8'h9C;
            4'd7:  in7 = 8'h9C;
            
            // States 8-15: Lower box pattern (A3)
            4'd8:  in7 = 8'hA3;
            4'd9:  in6 = 8'hA3;
            4'd10: in5 = 8'hA3;
            4'd11: in4 = 8'hA3;
            4'd12: in3 = 8'hA3;
            4'd13: in2 = 8'hA3;
            4'd14: in1 = 8'hA3;
            4'd15: in0 = 8'hA3;
        endcase
    end
    
endmodule