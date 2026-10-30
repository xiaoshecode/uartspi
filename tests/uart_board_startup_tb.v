`timescale 1ns / 1ps

// Self-checking configuration/startup regression; no hardware or serial I/O.
module uart_board_startup_tb;
    reg clk = 1'b0;
    wire tx;
    integer cycle;
    uart_board_top dut (.clk_50m_i(clk), .uart_rxd_i(1'b1), .uart_txd_o(tx));
    always #10 clk = ~clk;

    initial begin
        #1;
        if (dut.core_rst_n !== 1'b0)
            $fatal(1, "UART reset must assert at configuration/startup");
        for (cycle = 1; cycle <= 4; cycle = cycle + 1) begin
            @(posedge clk);
            // At the sampling edge the core must still see asserted reset.
            if (dut.core_rst_n !== 1'b0)
                $fatal(1, "UART reset released before four sampled clock edges");
            #1;
            if (tx !== 1'b1)
                $fatal(1, "UART TX must be idle high during reset");
            if (cycle < 4 && dut.core_rst_n !== 1'b0)
                $fatal(1, "UART reset released early");
        end
        if (dut.core_rst_n !== 1'b1)
            $fatal(1, "UART reset failed to release after four edges");
        repeat (20) begin
            @(posedge clk);
            #1;
            if (dut.core_rst_n !== 1'b1 || tx !== 1'b1)
                $fatal(1, "UART reset must stay released and idle TX stay high");
        end
        $display("PASS: startup reset and idle TX");
        $finish;
    end
    initial begin
        #10000;
        $fatal(1, "Startup regression timed out");
    end
endmodule
