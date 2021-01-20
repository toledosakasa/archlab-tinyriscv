## This file is a general .xdc for the PYNQ-Z2 board Rev. C
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal 125 MHz

set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 8.000 -name sys_clk_pin -waveform {0.000 4.000} -add [get_ports clk]

set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports rst]

set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports over]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports succ]

set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports halted_ind]

# JTAG pin
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports jtag_TCK]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports jtag_TMS]
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports jtag_TDI]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports jtag_TDO]

set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports uart_debug_pin]

set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports uart_rx_pin]
set_property -dict {PACKAGE_PIN Y6 IOSTANDARD LVCMOS33} [get_ports uart_tx_pin]

set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports {gpio[0]}]
set_property -dict {PACKAGE_PIN Y7 IOSTANDARD LVCMOS33} [get_ports {gpio[1]}]

## ChipKit SPI
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports spi_miso]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports spi_mosi]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports spi_clk]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports spi_ss]





create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list u_clk_wiz_0/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_tinyriscv/pc_pc_o[0]} {u_tinyriscv/pc_pc_o[1]} {u_tinyriscv/pc_pc_o[2]} {u_tinyriscv/pc_pc_o[3]} {u_tinyriscv/pc_pc_o[4]} {u_tinyriscv/pc_pc_o[5]} {u_tinyriscv/pc_pc_o[6]} {u_tinyriscv/pc_pc_o[7]} {u_tinyriscv/pc_pc_o[8]} {u_tinyriscv/pc_pc_o[9]} {u_tinyriscv/pc_pc_o[10]} {u_tinyriscv/pc_pc_o[11]} {u_tinyriscv/pc_pc_o[12]} {u_tinyriscv/pc_pc_o[13]} {u_tinyriscv/pc_pc_o[14]} {u_tinyriscv/pc_pc_o[15]} {u_tinyriscv/pc_pc_o[16]} {u_tinyriscv/pc_pc_o[17]} {u_tinyriscv/pc_pc_o[18]} {u_tinyriscv/pc_pc_o[19]} {u_tinyriscv/pc_pc_o[20]} {u_tinyriscv/pc_pc_o[21]} {u_tinyriscv/pc_pc_o[22]} {u_tinyriscv/pc_pc_o[23]} {u_tinyriscv/pc_pc_o[24]} {u_tinyriscv/pc_pc_o[25]} {u_tinyriscv/pc_pc_o[26]} {u_tinyriscv/pc_pc_o[27]} {u_tinyriscv/pc_pc_o[28]} {u_tinyriscv/pc_pc_o[29]} {u_tinyriscv/pc_pc_o[30]} {u_tinyriscv/pc_pc_o[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {s0_data_i[0]} {s0_data_i[1]} {s0_data_i[2]} {s0_data_i[3]} {s0_data_i[4]} {s0_data_i[5]} {s0_data_i[6]} {s0_data_i[7]} {s0_data_i[8]} {s0_data_i[9]} {s0_data_i[10]} {s0_data_i[11]} {s0_data_i[12]} {s0_data_i[13]} {s0_data_i[14]} {s0_data_i[15]} {s0_data_i[16]} {s0_data_i[17]} {s0_data_i[18]} {s0_data_i[19]} {s0_data_i[20]} {s0_data_i[21]} {s0_data_i[22]} {s0_data_i[23]} {s0_data_i[24]} {s0_data_i[25]} {s0_data_i[26]} {s0_data_i[27]} {s0_data_i[28]} {s0_data_i[29]} {s0_data_i[30]} {s0_data_i[31]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets new_clk]
