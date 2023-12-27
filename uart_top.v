`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/16 09:02:04
// Design Name: 
// Module Name: uart_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module  uart
    #(
        parameter CLK_FREQ = 50,            // Clock frequency(MHz)
        parameter BAUD_RATE = 9600,         // Set for baud rate
        parameter CHECK_SEL = 1,            // Selecting for parity check mode, 1 for odd check and 0 for even check.
        parameter BYTE_NUM = 4              // Number of bytes want to be sent
    )
    (
        input clk_50m_i,                    // System clock
//        input rst_n_i,                      // RESET button, active when rst_n_i is 0 
        input uart_rxd_i,                   // Bit data received from computer
        
        output uart_txd_o                   // Bit data send to computer
    );
    
    // Wire definition
    wire crc_error_i;                       // Signal for rx_n_bytes data error, this is a pulse signal
    wire crc_valid_i;                       // Signal for rx_n_bytes data valid, this is a pulse signal 
    wire rx_nbytes_busy;                    // Signal for read_n_bytes module busy, this is a continuous signal 
    wire tx_nbytes_busy_i;                  // Signal for send_n_bytes module busy, this is a continuous signal  
    wire tx_send_en_o;                      // Enable signal for send_n_bytes data module
    wire tx_nbytes_done;                    // Sinal for send_n_bytes data module finished working 
    wire rx_busy_neg;                       // Signal to catch negedge of rx_busy signal             
    wire tx_busy_neg;                       // Signal to catch negedge of tx_busy signal
    wire error_pos;                         // Signal to catch posedge of rx data error signal
    wire valid_neg;                         // Signal to catch posedge of rx data valid signal
    wire rx_nbytes_done_i;
    wire rx_nbytes_crc_valid;
    wire [8*BYTE_NUM-1:0] uart_nbytes_data ='hx; // Signal to tranmit uart data from read n bytes module to send n bytes module
    
    
    // Reg definition
    reg rx_busy_reg0;                       // Flip-flop reg to catch negedge of rx_busy signal
    reg rx_busy_reg1;
    reg error_reg0;                         // Flip-flop reg to catch posedge of rx_error signal 
    reg error_reg1;                         
    reg valid_reg0;                         // Flip-flop reg to catch posedge of nbytes_valid signal 
    reg valid_reg1;
    reg tx_busy_reg0;                       // Flip-flop reg to catch negedge of tx_busy signal
    reg tx_busy_reg1;
    reg tx_senden_reg;
    reg [2:0] tx_send_reg =3'b0;                  // Number of group data that has been sent
    reg [2:0] rx_read_reg =3'b0;                  // Number of group data that has been read
    
    reg rst_n = 1'b1;
    assign rst_n_i = rst_n;


//////////////////////////////////////////////////////////////////////////////////
    // Instantiate read_n_bytes module for reading n bytes data
    read_n_bytes 
    #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .CHECK_SEL(CHECK_SEL),
        .BYTE_NUM(BYTE_NUM)
    )
    U_n_bytes_read (
        .clk_i (clk_50m_i),
        .rst_n_i (rst_n_i),
        .uart_rxd_i (uart_rxd_i),
        
        .rx_nbytes_data_valid_o(rx_nbytes_done_i),  
        .nbytes_crc_valid_o(rx_nbytes_crc_valid),   
        .nbytes_data_in_o (uart_nbytes_data)
    );
    
    // Instantiate send_n_bytes module for sending n bytes data
    send_n_bytes
    #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .CHECK_SEL(CHECK_SEL),
        .BYTE_NUM(BYTE_NUM)
    )
    U_n_bytes_send(
        .clk_i (clk_50m_i),
        .rst_n_i (rst_n_i),
        .send_en_i(tx_send_en_o),
        .nbytes_data_out_i(uart_nbytes_data),
        
        .tx_nbytes_busy_o(tx_nbytes_busy_i),   
        .uart_txd_o (uart_txd_o)
    );

//////////////////////////////////////////////////////////////////////////////////
    // Control part of read n bytes module and send n bytes module
        
    // Catch negedge of tx_busy signal
    assign tx_busy_neg = (~tx_busy_reg0) & (tx_busy_reg1);
    
    always@(posedge clk_50m_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
          tx_busy_reg0 <= 1'b0;
          tx_busy_reg1 <= 1'b0;  
        end
        else begin
            tx_busy_reg0 <= tx_nbytes_busy_i;
            tx_busy_reg1 <= tx_busy_reg0;
        end
    end

    // Generating signal to enable transmission process
    assign tx_send_en_o = tx_senden_reg;    
    
    always@(posedge clk_50m_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            tx_send_reg <= 3'd0;
            rx_read_reg <= 3'd0;
        end
        else begin
            if(rx_nbytes_done_i) begin
                if(rx_nbytes_crc_valid)
                    rx_read_reg <= rx_read_reg + 1'd1;
                else
                    rx_read_reg <= rx_read_reg; 
            end
            else if(tx_busy_neg) begin
                tx_send_reg <= tx_send_reg + 1'd1;
            end
            else begin
                tx_send_reg <= tx_send_reg;
                rx_read_reg <= rx_read_reg;
            end
        end     
     end
     
     always@(posedge clk_50m_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            tx_senden_reg <= 1'b0;
        end
        else begin
            if(tx_send_reg != rx_read_reg ) tx_senden_reg <= 1'b1;
            else tx_senden_reg <= 1'b0;
        end     
     end 



endmodule



//    // Wires need for iLA testing
//    wire [7:0] data_test;
//    wire tx_en;
//    wire [3:0] tx_send_num;
//    wire [31:0] test_data_out;
    
//    // ila testing module 
//    ila_0 tx_data_prob (
//        .clk(clk_50m_i), // input wire clk
    
//        .probe0(tx_send_en_o), // input wire [0:0]  probe0  
//        .probe1(uart_nbytes_data), // input wire [31:0]  probe1
//        .probe2(rx_read_reg), // input wire [7:0]  probe1
//        .probe3(tx_send_reg), // input wire [3:0]  probe3 
//        .probe4(rx_busy_neg)  // input wire [0:0]  probe4   
//    );


    
//    // Wires need for testing
//    wire [7:0] data_test;
//    wire tx_en;
//    wire [3:0] tx_send_num;
//    wire [31:0] test_data_out;
    
//    // ila testing module 
//    ila_0 tx_data_prob (
//        .clk(clk_50m_i), // input wire clk
    
//        .probe0(tx_senden_reg), // input wire [0:0]  probe0  
//        .probe1(test_data_out), // input wire [31:0]  probe1
//        .probe2(rx_read_reg), // input wire [7:0]  probe1
//        .probe3(tx_send_reg), // input wire [3:0]  probe3 
//        .probe4(rx_busy_neg)  // input wire [0:0]  probe4   
//    );

//        .tx_send_num(tx_send_num),
//        .tx_en(tx_en),
//        .data(data_test),
//        .data_out_reg(test_data_out),


    
//    // Catch posedge of crc_error_i signal
//    assign error_pos = error_reg0 & (~error_reg1);
    
//    always@(posedge clk_50m_i or negedge rst_n_i) begin
//        if(!rst_n_i) begin
//          error_reg0 <= 1'b0;
//          error_reg1 <= 1'b0;  
//        end
//        else begin
//            error_reg0 <= crc_error_i;
//            error_reg1 <= error_reg0;
//        end
//    end


//    // Catch negedge of rx_busy signal
//    // Catch posedge of rx_data_valid signal
//    assign rx_busy_neg = (~rx_busy_reg0) & (rx_busy_reg1);
    
//    always@(posedge clk_50m_i or negedge rst_n_i) begin
//        if(!rst_n_i) begin
//          rx_busy_reg0 <= 1'b0;
//          rx_busy_reg1 <= 1'b0;  
//        end
//        else begin
//            rx_busy_reg0 <= rx_nbytes_busy_i;
//            rx_busy_reg1 <= rx_busy_reg0;
//        end
//    end

    
//    // Catch negedge of crc_valid_i signal
//    assign valid_neg = (~valid_reg0) & (valid_reg1);
    
//    always@(posedge clk_50m_i or negedge rst_n_i) begin
//        if(!rst_n_i) begin
//          valid_reg0 <= 1'b0;
//          valid_reg1 <= 1'b0;  
//        end
//        else begin
//            valid_reg0 <= crc_valid_i;
//            valid_reg1 <= valid_reg0;
//        end
//    end

//        .rx_nbytes_valid_o (crc_valid_i),
//        .rx_nbytes_busy_o (rx_nbytes_busy_i),


        
//        .data_out_test(data_test),
//        .tx_en_test(tx_en_test),



    
//    // ila testing module 
//    ila_0 tx_data_prob (
//        .clk(clk_50m_i), // input wire clk
    
//        .probe0(tx_send_en_o), // input wire [0:0]  probe0  
//        .probe1(uart_nbytes_data), // input wire [31:0]  probe1
//        .probe2(data_test), // input wire [8:0]  probe1
//        .probe3(rx_nbytes_done_i), // input wire [3:0]  probe3 
//        .probe4(tx_en_test)  // input wire [0:0]  probe4   
//    );
    
//    // Wires need for iLA testing
//    wire [8:0] data_test;
//    wire tx_en_test;
//    wire [3:0] tx_send_num;
//    wire [31:0] test_data_out;