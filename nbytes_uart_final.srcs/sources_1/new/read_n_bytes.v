`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/18 13:05:15
// Design Name: 
// Module Name: read_n_bytes
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


module read_n_bytes
    #(
        parameter CLK_FREQ = 50,                // Clock frequency(MHz)
        parameter BAUD_RATE = 9600,             // Set for baud rate
        parameter CHECK_SEL = 1,                // Selecting for parity check mode, 1 for odd check and 0 for even check.
        parameter BYTE_NUM = 4                  // Number of bytes want to be sent
    )
    (   
        input clk_i,                                    // Clock signal
        input rst_n_i,                                  // Resset signal, it will active when rst_n_i = 0
        input uart_rxd_i,                               // Bit signal for data received from computer 
        
        output wire rx_nbytes_valid_o,                   // Valid signal for data received, when read n bytes done and all data is valid, valid signal is 1
        output reg [8*BYTE_NUM-1:0] nbytes_data_in_o,   // N_bytes data received from rx module
        output wire rx_nbytes_busy_o                    // Signal showing that read n bytes module is working, it is a continuous signal 
    );
    
    
    // Wire definition
    wire rx_busy_i;                         // Signal getting from rx module showing rx module is working on receiving data
    wire rx_bytes_done;                   // Signal getting from rx module showing rx module has received 8 bits data
    wire rx_valid_i;
    wire [7:0] data_i;                      // Signal for data getting from rx module
    
    // Reg definition
    reg rx_valid_reg0;                      // Flip-flop reg to catch posedge of rx_valid signal
    reg rx_valid_reg1;
    reg rx_busy0;                           // Flip-flop reg to catch negedge of rx_busy signal
    reg rx_busy1;
    reg rx_nbytes_error_o;                       
    reg [3:0] rx_bytes_num;                 // Reg to count for the bytes num of data that rx module has received 
    reg [8*BYTE_NUM-1 :0] rx_data_nbytes;   // Reg to store data getting from rx module 
    reg rx_nbytes_finish;                   // Reg to store finish signal that module has received n bytes data
    
    assign rx_nbytes_busy_o = ~rx_nbytes_finish;
    assign rx_nbytes_valid_o = ~rx_nbytes_error_o;
    
//////////////////////////////////////////////////////////////////////////////////    
    // Instantiate Rx module for receiving data and do parity check
    uart_rx 
    #(
        .CLK_FREQ(CLK_FREQ),
        .UART_BPS(BAUD_RATE),
        .CHECK_SEL(CHECK_SEL)
    )
    U_uart_rx (
        .clk_i (clk_i),
        .rst_n_i (rst_n_i),
        .uart_rxd_i (uart_rxd_i),
        
        .rx_busy_o(rx_busy_i),    
        .rx_valid_o (rx_valid_i),
        .data_in_o (data_i)
    );

//////////////////////////////////////////////////////////////////////////////////
    // Control part for reading data, store them byte by byte and output them
    
    // Catch negedge of rx_busy signal, showing 8 bits data has been received 
    assign rx_bytes_done = rx_busy1 & (~rx_busy0);
    
    always @(posedge clk_i or negedge rst_n_i) begin         
        if (!rst_n_i) begin
            rx_busy0 <= 1'b0;                                  
            rx_busy1 <= 1'b0;
        end                                                      
        else begin                                               
            rx_busy0 <= rx_busy_i;                               
            rx_busy1 <= rx_busy0;                            
        end
    end
    
    // Store data getting from rx module, output them when rx module received N bytes data needed 
    always @(posedge clk_i or negedge rst_n_i) begin         
        if (!rst_n_i) begin
            rx_bytes_num <= 4'd0;
            rx_nbytes_finish <= 1'b0;
            rx_data_nbytes <= 'hx;
            nbytes_data_in_o <= 'hx;
        end
        else begin
            if(rx_bytes_done) begin
                rx_bytes_num <= rx_bytes_num +1'b1;
                rx_data_nbytes[7:0] <= data_i;
                rx_data_nbytes = rx_data_nbytes  << 8;
                if(rx_bytes_num == BYTE_NUM-1) begin
                    rx_nbytes_finish <= 1'b1;
                    rx_bytes_num <= 4'd0; 
                    nbytes_data_in_o <= {rx_data_nbytes[8*BYTE_NUM-1:8],data_i};
                end
                else begin
                    rx_nbytes_finish <= 1'b0;
                    nbytes_data_in_o <= 'hx;
                end
            end
        end
     end
     
     // Generating error signal when there is error inside the data received, 
     always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            rx_nbytes_error_o <= 1'b0;
        end
        else begin
            if(rx_bytes_done) begin
                if(rx_valid_i) begin 
                    rx_nbytes_error_o <= 1'b0;
                end
                else begin 
                    rx_nbytes_error_o <= 1'b1;
                end
            end
            else begin
                rx_nbytes_error_o <= 1'b0;
//                rx_nbytes_valid_o <= 1'b0;
            end
        end
     end
    
endmodule


//                    nbytes_data_in_o <= rx_data_nbytes;
//                    nbytes_data_in_o <= 'hx;

//                    if(rx_nbytes_finish == 1'b1)
//                        nbytes_data_in_o <= rx_data_nbytes;
     
//     always@(posedge clk or negedge rst_n_i) begin
//        if(!rst_n_i) begin
//            rx_nbytes_data <= 'hx;
//        end
//        else begin
//            if(rx_nbytes_finish==1 && rx_nbytes_error==0) 
//                rx_nbytes_data <= rx_data_nbytes;
//            else 
//                rx_nbytes_data <= 'hx;
//        end
//     end
//                    if(rx_nbytes_error==1)  rx_nbytes_data <= 'hx;
//                    else rx_nbytes_data <= rx_data_nbytes;
    
//    assign rx_valid_pos = (~rx_valid_reg1) & rx_valid_reg0;

//    always @(posedge clk_i or negedge rst_n_i) begin         
//        if (!rst_n_i) begin
//            rx_valid_reg0 <= 1'b0;                                  
//            rx_valid_reg1 <= 1'b0;
//        end                                                      
//        else begin                                               
//            rx_valid_reg0 <= rx_valid_i;                               
//            rx_valid_reg1 <= rx_valid_reg0;                            
//        end
//    end
    
//    always @(posedge clk or negedge rst_n_i) begin         
//        if (!rst_n_i) begin
//            rx_valid_num <= 4'd0;
//        end
//        else begin
//            if(rx_valid_pos) begin
//                rx_valid_num <= rx_valid_num +1'd1;
//                if(rx_bytes_num == BYTE_NUM) begin
//                    if(rx_valid_num != BYTE_NUM) begin
////                        rx_nbytes_error <= 1'b1;
//                        rx_valid_num <= 4'd1;
//                    end
//                    else begin
////                        rx_nbytes_error <= 1'b0;
//                        rx_valid_num <= 4'd1;
//                    end
//                end
////                else begin
//////                    rx_nbytes_error <= 1'b0;
////                end
//            end
//        end
//     end

//                rx_data_nbytes[8*BYTE_NUM-1:8*BYTE_NUM-8] <= data_i;
//                rx_data_nbytes = rx_data_nbytes  >> 8;     