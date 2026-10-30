`timescale 1ns / 1ps

// Board wrapper: preserve the existing clock / RX / TX pin interface.
// Xilinx FPGA configuration initializes this shift register to zero. Hold the
// UART core in reset for the first four rising clock edges, then release reset
// synchronously. This is a configuration-time reset, not a watchdog or button.
module uart_board_top #(
    parameter CLK_FREQ = 50,
    parameter BAUD_RATE = 9600,
    parameter CHECK_SEL = 1,
    parameter BYTE_NUM = 4
) (
    input wire clk_50m_i,
    input wire uart_rxd_i,
    output wire uart_txd_o
);
    reg [3:0] startup_reset = 4'b0000;
    wire core_rst_n = startup_reset[3];

    always @(posedge clk_50m_i)
        startup_reset <= {startup_reset[2:0], 1'b1};

    uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .CHECK_SEL(CHECK_SEL),
        .BYTE_NUM(BYTE_NUM)
    ) uart_core (
        .clk_50m_i(clk_50m_i),
        .rst_n_i(core_rst_n),
        .uart_rxd_i(uart_rxd_i),
        .uart_txd_o(uart_txd_o)
    );
endmodule
