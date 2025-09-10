## Comprehensive Vivado Implementation Guide

### Step 1: Opening Vivado and Project Setup

1. **Launch Vivado**
   - Click the Vivado icon on your Windows desktop
   - Or navigate to Start Menu → Xilinx Design Tools → Vivado 2023.x → Vivado

2. **Create New Project**
   - Click "Create Project" on the start screen
   - Click "Next" on the New Project wizard
   - Project name: `rotating_square_circuit`
   - Project location: Choose your preferred directory (e.g., `C:\vivado_projects\`)
   - Ensure "Create project subdirectory" is checked
   - Click "Next"

3. **Project Type Selection**
   - Select "RTL Project"
   - Check "Do not specify sources at this time"
   - Click "Next"

4. **Part Selection**
   - In the search box, type: `xc7a100tcsg324-1`
   - Select the part: `xc7a100tcsg324-1` (this is the FPGA on Nexys 4 DDR)
   - Click "Next", then "Finish"

### Step 2: Adding Source Files

1. **Add Design Sources**
   - In the Sources window, right-click "Design Sources"
   - Select "Add Sources"
   - Choose "Add or create design sources"
   - Click "Next"
   - Click "Add Files"
   - Navigate to your files and select `rotating_square_top.sv`
   - Ensure "Copy sources into project" is checked
   - Click "Finish"

2. **Add Simulation Sources**
   - Right-click "Simulation Sources"
   - Select "Add Sources"
   - Choose "Add or create simulation sources"
   - Click "Next"
   - Click "Add Files"
   - Select `rotating_square_tb.sv`
   - Ensure "Copy sources into project" is checked
   - Click "Finish"

3. **Add Constraints**
   - Right-click "Constraints"
   - Select "Add Sources"
   - Choose "Add or create constraints"
   - Click "Next"
   - Click "Add Files"
   - Select `rotating_square_constraints.xdc`
   - Ensure "Copy sources into project" is checked
   - Click "Finish"

### Step 3: Running Simulation

1. **Launch Simulation**
   - In the Flow Navigator (left panel), click "Run Simulation"
   - Select "Run Behavioral Simulation"
   - Wait for simulation to compile and launch

2. **Simulation Analysis**
   - The simulator will open with waveform viewer
   - Verify that the testbench runs without errors
   - Check the console output for "ALL TESTS PASSED"
   - Examine key signals: `current_state`, `an`, `seg`
   - The simulation should complete in approximately 30-60 seconds

3. **Troubleshooting Simulation**
   - If compilation errors occur, check the Messages tab
   - Verify all file paths are correct
   - Ensure SystemVerilog syntax is properly recognized

### Step 4: Synthesis and Implementation

1. **Run Synthesis**
   - Close the simulation if open
   - In Flow Navigator, click "Run Synthesis"
   - This process takes 2-5 minutes depending on your computer
   - Monitor the progress in the top-right corner
   - If successful, you'll see "Synthesis Completed Successfully"

2. **Review Synthesis Results**
   - Click "Open Synthesized Design" when prompted
   - Check the Messages tab for any warnings
   - Review resource utilization in the reports

3. **Run Implementation**
   - In Flow Navigator, click "Run Implementation"
   - This takes 3-8 minutes
   - Monitor for completion message
   - Address any timing violations if they appear

4. **Generate Bitstream**
   - Click "Generate Bitstream" in Flow Navigator
   - This final step takes 2-4 minutes
   - The bitstream file (.bit) will be created for board programming

### Step 5: Hardware Deployment

1. **Connect the Nexys 4 DDR Board**
   - Connect the board to your computer via USB cable
   - Ensure the board power switch is ON
   - The board should be recognized by Windows (may require Digilent drivers)

2. **Open Hardware Manager**
   - In Flow Navigator, click "Open Hardware Manager"
   - Click "Open target" → "Auto Connect"
   - The Nexys 4 DDR should appear as a connected target

3. **Program the Device**
   - Right-click on the FPGA device (xc7a100t_0)
   - Select "Program Device"
   - The bitstream file should be automatically selected
   - If not, browse to: `[project_directory]/rotating_square_circuit.runs/impl_1/rotating_square_top.bit`
   - Click "Program"
   - Programming takes 10-20 seconds
   - Look for "Program Device completed successfully" message

### Step 6: Testing on Hardware

1. **Initial Verification**
   - After programming, the seven-segment displays should be mostly off
   - One display should show a square pattern (segments forming a square shape)

2. **Control Testing**
   - **Reset (BTNC - Center button)**: Press to reset the pattern to initial position
   - **Enable (BTNR - Right button)**: Hold down to enable pattern movement
   - **Direction (BTNU - Up button)**: Press and hold while enable is active
     - Up button pressed = Clockwise rotation
     - Up button released = Counterclockwise rotation

3. **Expected Behavior**
   - With enable pressed, the square pattern should move between digits
   - The pattern alternates between two square configurations as it moves
   - Movement should be slow enough for visual inspection (approximately 1 second per step)
   - Direction changes should be immediately visible when toggling the direction button

### Step 7: Advanced Verification and Debugging

1. **Signal Monitoring with ILA (Optional)**
   ```tcl
   # Add to constraints file if debugging needed
   set_property MARK_DEBUG true [get_nets current_state]
   set_property MARK_DEBUG true [get_nets en]
   set_property MARK_DEBUG true [get_nets cw]
   ```

2. **Timing Analysis**
   - In Flow Navigator, expand "Implementation"
   - Click "Open Implemented Design"
   - Go to Reports → Timing → Report Timing Summary
   - Verify no timing violations exist

3. **Resource Utilization Check**
   - In Reports, select "Utilization Report"
   - Verify the design uses minimal resources:
     - LUTs: < 1% of available
     - Flip-flops: < 1% of available
     - No BRAM or DSP usage required

### Step 8: Troubleshooting Common Issues

1. **Board Not Recognized**
   - Install Digilent Adept software and drivers
   - Check USB cable connection
   - Verify board power is on
   - Try a different USB port

2. **Seven-Segment Display Issues**
   - If displays show random patterns: Check constraints file pin assignments
   - If no display activity: Verify power connections and constraint file
   - If pattern doesn't move: Check enable button functionality

3. **Synthesis/Implementation Errors**
   - Check Messages tab for specific error details
   - Verify SystemVerilog syntax compatibility
   - Ensure all referenced signals are properly declared

4. **Timing Violations**
   - If critical warnings appear about timing, the clock constraints may need adjustment
   - The design should meet timing at 100MHz easily due to its simplicity

### Step 9: Design Verification Checklist

**Functional Verification:**
- [ ] Pattern resets to initial position on reset button
- [ ] Pattern moves only when enable button is pressed
- [ ] Clockwise rotation works correctly
- [ ] Counterclockwise rotation works correctly
- [ ] Pattern completes full circulation through all 8 states
- [ ] Only one digit shows pattern at any time
- [ ] Pattern alternates between two square configurations

**Technical Verification:**
- [ ] Synthesis completes without errors
- [ ] Implementation meets timing requirements
- [ ] Resource utilization is reasonable (< 5% of FPGA)
- [ ] Testbench simulation passes all test cases
- [ ] Hardware programming succeeds without errors

### Step 10: Performance Optimization (Optional)

1. **Timing Adjustment**
   - To change rotation speed, modify `SLOW_CLK_DIV` parameter in the top module
   - Current setting: ~1Hz (50,000,000 clock cycles)
   - For faster rotation: decrease the value
   - For slower rotation: increase the value

2. **Pattern Customization**
   - Modify `square_patterns` array to change visual appearance
   - Each 8-bit value controls the seven segments plus decimal point
   - Bit order: `{dp, g, f, e, d, c, b, a}` (active low for common anode)

### Final Notes

This implementation provides a robust, well-tested rotating square circuit that meets all specified requirements. The design incorporates proper timing control, direction management, and display multiplexing suitable for the Nexys 4 DDR board architecture. The comprehensive testbench ensures functional correctness before hardware deployment, while the detailed constraints file guarantees proper signal routing to the board's physical interfaces.

The circuit operates at the board's native 100MHz clock frequency with appropriate clock division for human-visible timing, ensuring reliable operation across all environmental conditions. The modular design allows for easy modification and extension of functionality as needed for future enhancements.