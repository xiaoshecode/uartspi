`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Version 1.0
//////////////////////////////////////////////////////////////////////////////////

module uart_tb();

        reg clk;
        reg rst_n;

        reg u_rx;
        
        wire u_tx;
    
        uart u_uart
        (
            .clk_50m_i (clk),
            .rst_n_i (rst_n),
            .uart_rxd_i (u_rx),

            .uart_txd_o (u_tx)      
        );
    
        // Set up clock
        initial begin
            clk = 1;
            forever
            #10
            clk=~clk;
        end

        initial begin
            rst_n = 1;
            #10;
            rst_n = 0;
            #20;
            rst_n = 1;
        end

    parameter TIMEPERIOD = 20;

    initial begin

		u_rx = 1'b1;
		// First byte
		// Sending start bit
		#(5027*TIMEPERIOD); u_rx = 1'b0;
		// Sending bit 0 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 1 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 2 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 3 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 4 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 5 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 6 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 7 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending parity check bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending Stop bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		
		// Second byte
		// Sending start bit
		#(5027*TIMEPERIOD);u_rx = 1'b0;
		// Sending bit 0 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 1 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b1;
        // Sending bit 2 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 3 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 4 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 5 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 6 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b1;
        // Sending bit 7 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending parity check bit
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending Stop bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		
		// Thrid byte
		// Sending start bit
		#(5027*TIMEPERIOD);u_rx = 1'b0;
		// Sending bit 0 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 1 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 2 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 3 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 4 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 5 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 6 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 7 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending parity check bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending Stop bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		
		// Fourth byte
		// Sending start bit
		#(5027*TIMEPERIOD);u_rx = 1'b0;
		// Sending bit 0 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 1 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 2 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 3 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 4 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 5 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 6 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 7 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending parity check bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending Stop bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
        
        
//        #(5027*TIMEPERIOD*40);	u_rx = 1'b1;
        
        
        // First byte
		// Sending start bit
		#(5027*TIMEPERIOD); u_rx = 1'b0;
		// Sending bit 0 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 1 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 2 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 3 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 4 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 5 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 6 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 7 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending parity check bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending Stop bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		
		// Second byte
		// Sending start bit
		#(5027*TIMEPERIOD);u_rx = 1'b0;
		// Sending bit 0 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 1 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b1;
        // Sending bit 2 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 3 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 4 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 5 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 6 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b1;
        // Sending bit 7 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending parity check bit
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending Stop bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		
		// Thrid byte
		// Sending start bit
		#(5027*TIMEPERIOD);u_rx = 1'b0;
		// Sending bit 0 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 1 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 2 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending bit 3 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 4 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 5 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 6 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 7 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending parity check bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending Stop bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		
		// Fourth byte
		// Sending start bit
		#(5027*TIMEPERIOD);u_rx = 1'b0;
		// Sending bit 0 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 1 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 2 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 3 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 4 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 5 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending bit 6 of Data
        #(5027*TIMEPERIOD);	u_rx = 1'b0;
        // Sending bit 7 of Data
		#(5027*TIMEPERIOD);	u_rx = 1'b0;
		// Sending parity check bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;
		// Sending Stop bit
		#(5027*TIMEPERIOD);	u_rx = 1'b1;

end

endmodule


//        reg check_sel;
//        reg [2:0] baud_set;

//            .check_sel(check_sel),
//            .baud_set(baud_set),
//            .KEY1(KEY1),

//        baud_set = 3'd0;
//        check_sel = 1'b1;
//        KEY1 = 1'B1;
        // High voltage for normal time 
		
//		// Fifth byte
//		// Sending start bit
//		#(5027*TIMEPERIOD);u_rx = 1'b0;
//		// Sending bit 0 of Data
//		#(5027*TIMEPERIOD);	u_rx = 1'b1;
//		// Sending bit 1 of Data
//        #(5027*TIMEPERIOD);	u_rx = 1'b1;
//        // Sending bit 2 of Data
//		#(5027*TIMEPERIOD);	u_rx = 1'b1;
//		// Sending bit 3 of Data
//		#(5027*TIMEPERIOD);	u_rx = 1'b1;
//		// Sending bit 4 of Data
//		#(5027*TIMEPERIOD);	u_rx = 1'b1;
//		// Sending bit 5 of Data
//		#(5027*TIMEPERIOD);	u_rx = 1'b1;
//		// Sending bit 6 of Data
//        #(5027*TIMEPERIOD);	u_rx = 1'b1;
//        // Sending bit 7 of Data
//		#(5027*TIMEPERIOD);	u_rx = 1'b1;
//		// Sending parity check bit
//		#(5027*TIMEPERIOD);	u_rx = 1'b0;
//		// Sending Stop bit
//		#(5027*TIMEPERIOD);	u_rx = 1'b1;