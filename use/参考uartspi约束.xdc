## This file is a general .xdc for the Arty A7-35 Rev. D and Rev. E
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property -dict { PACKAGE_PIN Y18    IOSTANDARD LVCMOS33 } [get_ports { clk_50m_i }]; #IO_L12P_T1_MRCC_35 Sch=gclk[100]
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports { clk_50m_i }];
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets CLK50MHZ]

# USB-UART Interface
set_property -dict { PACKAGE_PIN G16   IOSTANDARD LVCMOS33 } [get_ports { uart_txd_o }]; #IO_L19N_T3_VREF_16 Sch=uart_rxd_out
set_property -dict { PACKAGE_PIN G15    IOSTANDARD LVCMOS33 } [get_ports { uart_rxd_i }]; #IO_L14N_T2_SRCC_16 Sch=uart_txd_in
#set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { uart_rxd_out }]; #IO_L19N_T3_VREF_16 Sch=uart_rxd_out
#set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { uart_txd_in }]; #IO_L14N_T2_SRCC_16 Sch=uart_txd_in

# Buttons
set_property -dict { PACKAGE_PIN F20    IOSTANDARD LVCMOS33 } [get_ports { rst_n_i }]; #IO_L6N_T0_VREF_16 Sch=btn[0]
#set_property -dict { PACKAGE_PIN M13    IOSTANDARD LVCMOS33 } [get_ports { KEY1 }]; #IO_L6N_T0_VREF_16 Sch=btn[0]
#set_property -dict { PACKAGE_PIN K14    IOSTANDARD LVCMOS33 } [get_ports { KEY2 }]; #IO_L11P_T1_SRCC_16 Sch=btn[1]
#set_property -dict { PACKAGE_PIN K13    IOSTANDARD LVCMOS33 } [get_ports { KEY3 }]; #IO_L11N_T1_SRCC_16 Sch=btn[2]
#set_property -dict { PACKAGE_PIN L13    IOSTANDARD LVCMOS33 } [get_ports { KEY4 }]; #IO_L12P_T1_MRCC_16 Sch=btn[3]