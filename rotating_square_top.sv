module rotating_square_top (
    input  logic        clk,        // 100MHz system clock
    input  logic        rst_n,      // Active-low reset
    input  logic        en,         // Enable signal
    input  logic        cw,         // Direction: 1=clockwise, 0=counterclockwise
    output logic [3:0]  an,         // Anode control for 4 digits
    output logic [7:0]  seg         // Segment control (7-seg + dp)
);

    // Clock divider parameters for visual timing
    localparam SLOW_CLK_DIV = 27'd50_000_000; // ~1Hz for pattern change
    localparam REFRESH_DIV = 17'd100_000;     // ~1kHz for display refresh
    
    // Pattern states for the rotating square
    typedef enum logic [2:0] {
        PATTERN_0 = 3'b000,  // Square pattern 1: segments a,b,f,g
        PATTERN_1 = 3'b001,  // Square pattern 2: segments c,d,e,g  
        PATTERN_2 = 3'b010,
        PATTERN_3 = 3'b011,
        PATTERN_4 = 3'b100,
        PATTERN_5 = 3'b101,
        PATTERN_6 = 3'b110,
        PATTERN_7 = 3'b111
    } pattern_state_t;
    
    // Internal signals
    logic [26:0] slow_counter;
    logic [16:0] refresh_counter;
    logic slow_clk, refresh_clk;
    logic [2:0] current_state;
    logic [1:0] digit_select;
    
    // Seven-segment patterns for the rotating square
    // Pattern encoding: {dp, g, f, e, d, c, b, a}
    logic [7:0] square_patterns [8];
    
    // Initialize the square patterns
    initial begin
        // Pattern 0: Square on digit 0 (rightmost), position 1
        square_patterns[0] = 8'b01110011; // segments a,b,f,g active (inverted for common anode)
        // Pattern 1: Square on digit 1, position 1  
        square_patterns[1] = 8'b01110011;
        // Pattern 2: Square on digit 2, position 1
        square_patterns[2] = 8'b01110011;
        // Pattern 3: Square on digit 3 (leftmost), position 1
        square_patterns[3] = 8'b01110011;
        // Pattern 4: Square on digit 3, position 2
        square_patterns[4] = 8'b01011100; // segments c,d,e,g active
        // Pattern 5: Square on digit 2, position 2
        square_patterns[5] = 8'b01011100;
        // Pattern 6: Square on digit 1, position 2  
        square_patterns[6] = 8'b01011100;
        // Pattern 7: Square on digit 0, position 2
        square_patterns[7] = 8'b01011100;
    end
    
    // Clock dividers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            slow_counter <= 27'd0;
            refresh_counter <= 17'd0;
        end else begin
            slow_counter <= (slow_counter == SLOW_CLK_DIV - 1) ? 27'd0 : slow_counter + 1;
            refresh_counter <= (refresh_counter == REFRESH_DIV - 1) ? 17'd0 : refresh_counter + 1;
        end
    end
    
    assign slow_clk = (slow_counter == SLOW_CLK_DIV - 1);
    assign refresh_clk = (refresh_counter == REFRESH_DIV - 1);
    
    // Pattern state machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= 3'd0;
        end else if (en && slow_clk) begin
            if (cw) begin
                // Clockwise rotation
                current_state <= (current_state == 3'd7) ? 3'd0 : current_state + 1;
            end else begin
                // Counterclockwise rotation  
                current_state <= (current_state == 3'd0) ? 3'd7 : current_state - 1;
            end
        end
    end
    
    // Display refresh counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digit_select <= 2'd0;
        end else if (refresh_clk) begin
            digit_select <= digit_select + 1;
        end
    end
    
    // Anode control (active low for common anode displays)
    always_comb begin
        case (digit_select)
            2'b00: an = 4'b1110; // Enable digit 0 (rightmost)
            2'b01: an = 4'b1101; // Enable digit 1
            2'b10: an = 4'b1011; // Enable digit 2  
            2'b11: an = 4'b0111; // Enable digit 3 (leftmost)
        endcase
    end
    
    // Segment pattern selection
    logic [7:0] current_segments;
    
    always_comb begin
        // Determine which digit should show the square pattern
        case (current_state)
            3'd0, 3'd7: begin // Square on digit 0
                current_segments = (digit_select == 2'd0) ? square_patterns[current_state] : 8'b11111111;
            end
            3'd1, 3'd6: begin // Square on digit 1  
                current_segments = (digit_select == 2'd1) ? square_patterns[current_state] : 8'b11111111;
            end
            3'd2, 3'd5: begin // Square on digit 2
                current_segments = (digit_select == 2'd2) ? square_patterns[current_state] : 8'b11111111;
            end
            3'd3, 3'd4: begin // Square on digit 3
                current_segments = (digit_select == 2'd3) ? square_patterns[current_state] : 8'b11111111;
            end
        endcase
    end
    
    assign seg = current_segments;
    
endmodule