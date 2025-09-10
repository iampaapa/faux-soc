`timescale 1ns / 1ps

module rotating_square_tb;

    // Testbench parameters
    localparam CLK_PERIOD = 10; // 100MHz clock

    // DUT signals
    logic        clk;
    logic        rst_n;
    logic        en;
    logic        cw;
    logic [3:0]  an;
    logic [7:0]  seg;

    // Instantiate DUT with fast timing parameters for simulation
    rotating_square_top #(
        .SLOW_CLK_DIV(1000),
        .REFRESH_DIV(100)
    ) dut (.*);

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test stimulus and monitoring
    initial begin
        integer error_count = 0;
        logic [2:0] expected_state;

        $display("--- Starting Simulation ---");

        // 1. Assert reset
        rst_n = 1;
        en = 0;
        cw = 1;
        #5;
        rst_n = 0;
        # (CLK_PERIOD * 10);
        rst_n = 1;
        # (CLK_PERIOD * 5);

        if (dut.current_state !== 3'd0) begin
            $error("Reset failed. Expected state 0, got %0d", dut.current_state);
            error_count++;
        end else begin
            $display("PASS: Reset successful.");
        end

        // 2. Test Enable/Disable functionality
        // With 'en' low, the state should not change despite slow clock ticks.
        en = 0;
        repeat (10) begin
            wait (dut.slow_clk_tick);
            @(posedge clk);
        end
        
        if (dut.current_state !== 3'd0) begin
            $error("State changed while disabled. Expected 0, got %0d", dut.current_state);
            error_count++;
        end else begin
            $display("PASS: State unchanged while disabled.");
        end

        // 3. Test Clockwise rotation
        $display("--- Testing Clockwise Rotation ---");
        en = 1;
        cw = 1;
        expected_state = dut.current_state;

        for (int i = 0; i < 16; i++) begin
            wait (dut.slow_clk_tick); // Wait for the enable tick
            @(posedge clk);           // Wait for the clock edge that captures the state change
            #1;                       // Let signals propagate for checking

            expected_state = (expected_state == 3'd7) ? 3'd0 : expected_state + 1;

            if (dut.current_state !== expected_state) begin
                $error("CW step %0d failed. Expected %0d, got %0d", i+1, expected_state, dut.current_state);
                error_count++;
            end
        end
        $display("PASS: Clockwise rotation verified.");


        // 4. Test Counter-clockwise rotation
        $display("--- Testing Counter-Clockwise Rotation ---");
        cw = 0;
        expected_state = dut.current_state;

        for (int i = 0; i < 16; i++) begin
            wait (dut.slow_clk_tick);
            @(posedge clk);
            #1;

            expected_state = (expected_state == 3'd0) ? 3'd7 : expected_state - 1;

            if (dut.current_state !== expected_state) begin
                $error("CCW step %0d failed. Expected %0d, got %0d", i+1, expected_state, dut.current_state);
                error_count++;
            end
        end
        $display("PASS: Counter-clockwise rotation verified.");

        // 5. Verify segment patterns
        $display("--- Verifying Segment Patterns ---");
        // Go to a known state, e.g., state 2 (square on digit 2, pattern 1)
        cw = 1;
        while (dut.current_state !== 3'd2) begin
            wait(dut.slow_clk_tick);
            @(posedge clk);
        end

        // Wait for the multiplexer to select the correct digit (digit 2)
        wait (dut.digit_select == 2'd2);
        #1;

        if (seg !== dut.SQUARE_PATTERN_1) begin
             $error("Segment pattern incorrect for state 2. Expected %b, got %b", dut.SQUARE_PATTERN_1, seg);
             error_count++;
        end else begin
             $display("PASS: Segment pattern verified.");
        end

        // --- Final Results ---
        if (error_count == 0) begin
            $display("\n*** ALL TESTS PASSED ***");
        end else begin
            $display("\n*** %0d TESTS FAILED ***", error_count);
        end

        $finish;
    end

endmodule