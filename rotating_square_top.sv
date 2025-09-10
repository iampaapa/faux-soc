/*
 * Module: rotating_square_top
 * Description:
 * This module drives a four-digit seven-segment display to show a rotating
 * square pattern. The pattern can circulate clockwise or counter-clockwise,
 * and the circulation can be enabled or paused. The design is parameterized
 * to allow for different clock division ratios for simulation and synthesis.
 */
module rotating_square_top #(
    // Parameters for clock division. Default values are for a 100MHz clock.
    parameter SLOW_CLK_DIV    = 27'd50_000_000, // ~1Hz for pattern state changes
    parameter REFRESH_DIV     = 17'd50_000      // ~2kHz refresh rate -> ~500Hz per digit
)(
    input  logic        clk,        // 100MHz system clock
    input  logic        rst_n,      // Active-low reset
    input  logic        en,         // Enable signal for rotation
    input  logic        cw,         // Direction: 1=clockwise, 0=counterclockwise
    output logic [3:0]  an,         // Anode control for 4 digits (active-low)
    output logic [7:0]  seg         // Segment control (active-low, {dp,g,f,e,d,c,b,a})
);

    // Internal logic signals
    logic slow_clk_tick;
    logic refresh_clk_tick;
    logic [2:0] current_state; // Represents 8 unique positions in the rotation
    logic [1:0] digit_select;  // Selects which of the 4 digits is active

    // Internal registers for clock division
    logic [26:0] slow_counter;
    logic [16:0] refresh_counter;

    // ROM to store the two square patterns
    // Common anode displays require a '0' to light a segment.
    // Pattern encoding: {dp, g, f, e, d, c, b, a}
    const logic [7:0] SQUARE_PATTERN_1 = 8'b10110000; // Segments a,b,f,e
    const logic [7:0] SQUARE_PATTERN_2 = 8'b10011100; // Segments b,c,d,e

    // Clock dividers to generate slow ticks for state changes and display refresh
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            slow_counter <= '0;
            refresh_counter <= '0;
            slow_clk_tick <= 1'b0;
            refresh_clk_tick <= 1'b0;
        end else begin
            // Generate a single-cycle tick for the state machine
            if (slow_counter == SLOW_CLK_DIV - 1) begin
                slow_counter <= '0;
                slow_clk_tick <= 1'b1;
            end else begin
                slow_counter <= slow_counter + 1;
                slow_clk_tick <= 1'b0;
            end

            // Generate a single-cycle tick for the display refresh
            if (refresh_counter == REFRESH_DIV - 1) begin
                refresh_counter <= '0;
                refresh_clk_tick <= 1'b1;
            end else begin
                refresh_counter <= refresh_counter + 1;
                refresh_clk_tick <= 1'b0;
            end
        end
    end

    // State machine to control the pattern's position
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= 3'd0;
        end else if (en && slow_clk_tick) begin
            if (cw) begin // Clockwise rotation
                current_state <= (current_state == 3'd7) ? 3'd0 : current_state + 1;
            end else begin // Counter-clockwise rotation
                current_state <= (current_state == 3'd0) ? 3'd7 : current_state - 1;
            end
        end
    end

    // Counter to cycle through the four digits for display multiplexing
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digit_select <= 2'd0;
        end else if (refresh_clk_tick) begin
            digit_select <= digit_select + 1;
        end
    end

    // Combinational logic for output generation
    logic [3:0] current_an;
    logic [7:0] current_seg;

    always_comb begin
        // --- Anode Control ---
        // Activate one digit at a time (active low)
        case (digit_select)
            2'b00:  current_an = 4'b1110; // Enable digit 0 (rightmost)
            2'b01:  current_an = 4'b1101; // Enable digit 1
            2'b10:  current_an = 4'b1011; // Enable digit 2
            2'b11:  current_an = 4'b0111; // Enable digit 3 (leftmost)
            default: current_an = 4'b1111;
        endcase

        // --- Segment Control ---
        logic [1:0] square_digit_pos;
        logic [7:0] pattern_to_display;

        // Determine which pattern to use based on the current state
        if (current_state inside {[3'd0], [3'd1], [3'd2], [3'd3]}) begin
            pattern_to_display = SQUARE_PATTERN_1;
        end else begin
            pattern_to_display = SQUARE_PATTERN_2;
        end

        // Determine which digit the square should be on
        case (current_state)
            3'd0, 3'd7: square_digit_pos = 2'd0;
            3'd1, 3'd6: square_digit_pos = 2'd1;
            3'd2, 3'd5: square_digit_pos = 2'd2;
            3'd3, 3'd4: square_digit_pos = 2'd3;
            default:    square_digit_pos = 2'bxx;
        endcase

        // If the currently active digit is the one that should show the square,
        // output the pattern. Otherwise, turn all segments off.
        if (digit_select == square_digit_pos) begin
            current_seg = pattern_to_display;
        end else begin
            current_seg = 8'b11111111; // All segments off
        end
    end

    // Assign combinational outputs to module ports
    assign an = current_an;
    assign seg = current_seg;

endmodule