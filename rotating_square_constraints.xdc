## Nexys 4 DDR Constraints File for Rotating Square Circuit
## This file maps the SystemVerilog ports to the physical pins on the Nexys 4 DDR board

## Clock signal (100 MHz)
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }]; 
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

## Reset signal - Using center button (BTNC)
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { rst_n }]; 

## Enable signal - Using right button (BTNR)
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports { en }]; 

## Direction control signal - Using up button (BTNU)
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { cw }]; 

## Seven-segment display anodes (active low)
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { an[0] }]; 
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { an[1] }]; 
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { an[2] }]; 
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { an[3] }]; 

## Seven-segment display cathodes (active low)
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { seg[0] }]; 
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { seg[1] }]; 
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { seg[2] }]; 
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { seg[3] }]; 
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { seg[4] }]; 
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { seg[5] }]; 
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { seg[6] }]; 
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { seg[7] }]; 

## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## Timing constraints
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rst_n_IBUF]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets en_IBUF]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets cw_IBUF]