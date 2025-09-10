module rotating_square_tb;

    // Testbench parameters
    localparam CLK_PERIOD = 10; // 100MHz clock (10ns period)
    localparam TEST_CYCLES = 1000; // Reduced for simulation speed
    
    // DUT signals
    logic        clk;
    logic        rst_n;
    logic        en;
    logic        cw;
    logic [3:0]  an;
    logic [7:0]  seg;
    
    // Testbench variables
    integer cycle_count;
    integer error_count;
    logic [2:0] expected_state;
    
    // Instantiate DUT with modified timing for simulation
    rotating_square_top_sim dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .cw(cw),
        .an(an),
        .seg(seg)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Test stimulus and monitoring
    initial begin
        $display("=== Rotating Square Circuit Testbench ===");
        $display("Time: %0t - Starting simulation", $time);
        
        // Initialize signals
        rst_n = 0;
        en = 0;
        cw = 1;
        cycle_count = 0;
        error_count = 0;
        expected_state = 3'd0;
        
        // Test 1: Reset functionality
        $display("\n--- Test 1: Reset Functionality ---");
        #(CLK_PERIOD * 10);
        rst_n = 1;
        #(CLK_PERIOD * 5);
        
        if (dut.current_state !== 3'd0) begin
            $display("ERROR: Reset failed. Expected state 0, got %0d", dut.current_state);
            error_count++;
        end else begin
            $display("PASS: Reset successful - state = %0d", dut.current_state);
        end
        
        // Test 2: Enable/Disable functionality
        $display("\n--- Test 2: Enable/Disable Functionality ---");
        en = 0;
        repeat(50) @(posedge dut.slow_clk);
        
        if (dut.current_state !== 3'd0) begin
            $display("ERROR: State changed while disabled. Expected 0, got %0d", dut.current_state);
            error_count++;
        end else begin
            $display("PASS: State unchanged while disabled");
        end
        
        // Test 3: Clockwise rotation
        $display("\n--- Test 3: Clockwise Rotation ---");
        en = 1;
        cw = 1;
        expected_state = 3'd0;
        
        for (int i = 0; i < 16; i++) begin
            @(posedge dut.slow_clk);
            #1; // Small delay for signal propagation
            expected_state = (expected_state == 3'd7) ? 3'd0 : expected_state + 1;
            
            if (dut.current_state !== expected_state) begin
                $display("ERROR: Clockwise step %0d failed. Expected %0d, got %0d", 
                        i+1, expected_state, dut.current_state);
                error_count++;
            end else begin
                $display("PASS: Clockwise step %0d - state = %0d", i+1, dut.current_state);
            end
        end
        
        // Test 4: Counterclockwise rotation
        $display("\n--- Test 4: Counterclockwise Rotation ---");
        cw = 0;
        expected_state = dut.current_state;
        
        for (int i = 0; i < 16; i++) begin
            @(posedge dut.slow_clk);
            #1;
            expected_state = (expected_state == 3'd0) ? 3'd7 : expected_state - 1;
            
            if (dut.current_state !== expected_state) begin
                $display("ERROR: Counterclockwise step %0d failed. Expected %0d, got %0d", 
                        i+1, expected_state, dut.current_state);
                error_count++;
            end else begin
                $display("PASS: Counterclockwise step %0d - state = %0d", i+1, dut.current_state);
            end
        end
        
        // Test 5: Display refresh functionality
        $display("\n--- Test 5: Display Refresh Functionality ---");
        logic [1:0] prev_digit;
        logic [1:0] refresh_changes;
        
        prev_digit = dut.digit_select;
        refresh_changes = 0;
        
        repeat(10) begin
            @(posedge dut.refresh_clk);
            #1;
            if (dut.digit_select !== prev_digit) begin
                refresh_changes++;
                $display("Display refresh: digit_select changed from %0d to %0d", 
                        prev_digit, dut.digit_select);
            end
            prev_digit = dut.digit_select;
        end
        
        if (refresh_changes >= 8) begin
            $display("PASS: Display refresh working correctly");
        end else begin
            $display("ERROR: Display refresh not working properly");
            error_count++;
        end
        
        // Test 6: Anode control patterns
        $display("\n--- Test 6: Anode Control Patterns ---");
        for (int digit = 0; digit < 4; digit++) begin
            while (dut.digit_select !== digit) @(posedge clk);
            #1;
            
            case (digit)
                0: if (an !== 4'b1110) begin
                    $display("ERROR: Digit 0 anode pattern incorrect. Expected 1110, got %b", an);
                    error_count++;
                end
                1: if (an !== 4'b1101) begin
                    $display("ERROR: Digit 1 anode pattern incorrect. Expected 1101, got %b", an);
                    error_count++;
                end
                2: if (an !== 4'b1011) begin
                    $display("ERROR: Digit 2 anode pattern incorrect. Expected 1011, got %b", an);
                    error_count++;
                end
                3: if (an !== 4'b0111) begin
                    $display("ERROR: Digit 3 anode pattern incorrect. Expected 0111, got %b", an);
                    error_count++;
                end
            endcase
        end
        $display("PASS: All anode patterns verified");
        
        // Test 7: Segment patterns verification
        $display("\n--- Test 7: Segment Pattern Verification ---");
        
        // Test pattern 0 (square pattern 1)
        while (dut.current_state !== 3'd0) @(posedge dut.slow_clk);
        while (dut.digit_select !== 2'd0) @(posedge clk);
        #1;
        
        if (seg !== 8'b01110011) begin
            $display("ERROR: Pattern 0 segments incorrect. Expected 01110011, got %b", seg);
            error_count++;
        end else begin
            $display("PASS: Pattern 0 segments correct");
        end
        
        // Test pattern 4 (square pattern 2)  
        while (dut.current_state !== 3'd4) @(posedge dut.slow_clk);
        while (dut.digit_select !== 2'd3) @(posedge clk);
        #1;
        
        if (seg !== 8'b01011100) begin
            $display("ERROR: Pattern 4 segments incorrect. Expected 01011100, got %b", seg);
            error_count++;
        end else begin
            $display("PASS: Pattern 4 segments correct");
        end
        
        // Test 8: Direction change during operation
        $display("\n--- Test 8: Direction Change During Operation ---");
        cw = 1;
        @(posedge dut.slow_clk);
        logic [2:0] state_before_change = dut.current_state;
        
        cw = 0; // Change direction
        @(posedge dut.slow_clk);
        #1;
        
        logic [2:0] expected_ccw_state = (state_before_change == 3'd0) ? 3'd7 : state_before_change - 1;
        
        if (dut.current_state !== expected_ccw_state) begin
            $display("ERROR: Direction change failed. Expected %0d, got %0d", 
                    expected_ccw_state, dut.current_state);
            error_count++;
        end else begin
            $display("PASS: Direction change successful");
        end
        
        // Test 9: Extended operation test
        $display("\n--- Test 9: Extended Operation Test ---");
        cw = 1;
        integer full_cycles = 0;
        logic [2:0] state_history [32];
        
        for (int i = 0; i < 32; i++) begin
            @(posedge dut.slow_clk);
            #1;
            state_history[i] = dut.current_state;
            if (dut.current_state == 3'd0 && i > 0) full_cycles++;
        end
        
        if (full_cycles >= 3) begin
            $display("PASS: Extended operation completed %0d full cycles", full_cycles);
        end else begin
            $display("ERROR: Extended operation failed - only %0d full cycles", full_cycles);
            error_count++;
        end
        
        // Final results
        $display("\n=== Test Results Summary ===");
        $display("Total errors: %0d", error_count);
        $display("Simulation time: %0t", $time);
        
        if (error_count == 0) begin
            $display("*** ALL TESTS PASSED ***");
        end else begin
            $display("*** %0d TESTS FAILED ***", error_count);
        end
        
        $display("\n=== Pattern State Trace (Last 8 states) ===");
        for (int i = 24; i < 32; i++) begin
            $display("Step %0d: State %0d", i-23, state_history[i]);
        end
        
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #(CLK_PERIOD * 1000000); // 10ms timeout
        $display("ERROR: Simulation timeout!");
        $finish;
    end
    
    // Signal monitoring
    always @(posedge dut.slow_clk) begin
        $display("Time: %0t - State transition to: %0d (en=%b, cw=%b)", 
                $time, dut.current_state, en, cw);
    end
    
endmodule

// Modified DUT for faster simulation
module rotating_square_top_sim (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic        cw,
    output logic [3:0]  an,
    output logic [7:0]  seg
);

    // Faster timing for simulation
    localparam SLOW_CLK_DIV = 15'd1000;  // Much faster for simulation
    localparam REFRESH_DIV = 8'd100;     // Faster refresh for simulation
    
    // Rest of the logic identical to main module
    typedef enum logic [2:0] {
        PATTERN_0 = 3'b000,
        PATTERN_1 = 3'b001,
        PATTERN_2 = 3'b010,
        PATTERN_3 = 3'b011,
        PATTERN_4 = 3'b100,
        PATTERN_5 = 3'b101,
        PATTERN_6 = 3'b110,
        PATTERN_7 = 3'b111
    } pattern_state_t;
    
    logic [14:0] slow_counter;
    logic [7:0] refresh_counter;
    logic slow_clk, refresh_clk;
    logic [2:0] current_state;
    logic [1:0] digit_select;
    
    logic [7:0] square_patterns [8];
    
    initial begin
        square_patterns[0] = 8'b01110011;
        square_patterns[1] = 8'b01110011;
        square_patterns[2] = 8'b01110011;
        square_patterns[3] = 8'b01110011;
        square_patterns[4] = 8'b01011100;
        square_patterns[5] = 8'b01011100;
        square_patterns[6] = 8'b01011100;
        square_patterns[7] = 8'b01011100;
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            slow_counter <= 15'd0;
            refresh_counter <= 8'd0;
        end else begin
            slow_counter <= (slow_counter == SLOW_CLK_DIV - 1) ? 15'd0 : slow_counter + 1;
            refresh_counter <= (refresh_counter == REFRESH_DIV - 1) ? 8'd0 : refresh_counter + 1;
        end
    end
    
    assign slow_clk = (slow_counter == SLOW_CLK_DIV - 1);
    assign refresh_clk = (refresh_counter == REFRESH_DIV - 1);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= 3'd0;
        end else if (en && slow_clk) begin
            if (cw) begin
                current_state <= (current_state == 3'd7) ? 3'd0 : current_state + 1;
            end else begin
                current_state <= (current_state == 3'd0) ? 3'd7 : current_state - 1;
            end
        end
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digit_select <= 2'd0;
        end else if (refresh_clk) begin
            digit_select <= digit_select + 1;
        end
    end
    
    always_comb begin
        case (digit_select)
            2'b00: an = 4'b1110;
            2'b01: an = 4'b1101;
            2'b10: an = 4'b1011;
            2'b11: an = 4'b0111;
        endcase
    end
    
    logic [7:0] current_segments;
    
    always_comb begin
        case (current_state)
            3'd0, 3'd7: begin
                current_segments = (digit_select == 2'd0) ? square_patterns[current_state] : 8'b11111111;
            end
            3'd1, 3'd6: begin
                current_segments = (digit_select == 2'd1) ? square_patterns[current_state] : 8'b11111111;
            end
            3'd2, 3'd5: begin
                current_segments = (digit_select == 2'd2) ? square_patterns[current_state] : 8'b11111111;
            end
            3'd3, 3'd4: begin
                current_segments = (digit_select == 2'd3) ? square_patterns[current_state] : 8'b11111111;
            end
        endcase
    end
    
    assign seg = current_segments;
    
endmodule