`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/25 09:17:36
// Design Name: 
// Module Name: send_n_bytes
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


module send_n_bytes
    #(
        parameter CLK_FREQ = 50,                    // Clock frequency(MHz)
        parameter BAUD_RATE = 9600,                 // Set for baud rate
        parameter CHECK_SEL = 1,                    // Selecting for parity check mode, 1 for odd check and 0 for even check.
        parameter BYTE_NUM = 4                      // Number of bytes want to be sent
    )    
    (
        input clk_i,                                // Clock input 
        input rst_n_i,                              // Resset signal, it will active when rst_n_i = 0
        input send_en_i,                            // Send enable signal, activate when send_en_i = 1. Starting sending process
        input [8*BYTE_NUM-1:0] nbytes_data_out_i,   // N_bytes data need to be sent to computer
    
        output reg tx_nbytes_busy_o,                // Signal showing that module is sending n bytes data
        output uart_txd_o                           // Bit output for data to send to computer 
    );
    
    // Wire definition
    wire send_en_pos;                               // Signal to catch posedge of send enable signal
    wire send_done_pos;                             // Signal to catch posedge signal of tx module send 1 bytes data done
    wire tx_en_o;                                   // Signal to start transmission processing
    wire tx_send_byte_done_i;                         // Signal showing that 1 byte transmission done
    
    // Reg definition
    reg send_en_reg0;                               // Flip-flop reg to catch posedge of send_en signal 
    reg send_en_reg1;
    reg send_done_reg0;                             // Flip-flop reg to catch posedge of 1 byte send_done signal 
    reg send_done_reg1;
    reg tx_en_reg;                                  // Reg to store enable signal 
    reg [8*BYTE_NUM -1:0] data_out_reg;             // Reg to store data need to be sent getting from top module
    reg [3:0] tx_send_num;                          // Reg to count how many bytes data current has sent 
    reg [7:0] data_o;                               // 1 byte data passing to tx module
    

    
//////////////////////////////////////////////////////////////////////////////////
    // Instantiate Tx module for sending data
    uart_tx 
    #(
        .CLK_FREQ(CLK_FREQ),
        .UART_BPS(BAUD_RATE),
        .CHECK_SEL(CHECK_SEL)
    )
    U_uart_tx (
        .clk_i (clk_i),
        .rst_n_i (rst_n_i),
        .data_out_i (data_o),
        .tx_en_i(tx_en_o),
        
        .tx_send_byte_done_o(tx_send_byte_done_i),
        .u_tx_o (uart_txd_o)  
    );
//////////////////////////////////////////////////////////////////////////////////
    // Control part of sending n bytes signal to computer 
    
    // Catch posedge of send enable signal
    assign send_en_pos = send_en_reg0 & (~send_en_reg1);
    
    always @(posedge clk_i or negedge rst_n_i) begin         
        if (!rst_n_i) begin
            send_en_reg0 <= 1'b0;                                  
            send_en_reg1 <= 1'b0;
        end                                                      
        else begin                                               
            send_en_reg0 <= send_en_i;                               
            send_en_reg1 <= send_en_reg0;                            
        end
    end
    
    // Catch posedge of 1 byte sent done signal
    assign send_done_pos = send_done_reg0 & (~send_done_reg1);
    
    always @(posedge clk_i or negedge rst_n_i) begin         
        if (!rst_n_i) begin
            send_done_reg0 <= 1'b0;                                  
            send_done_reg1 <= 1'b0;
        end                                                      
        else begin                                               
            send_done_reg0 <= tx_send_byte_done_i;                               
            send_done_reg1 <= send_done_reg0;                            
        end
    end
    
    
    // Generating enable signal for tx module
    assign tx_en_o = tx_en_reg;
    
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            tx_send_num <= 'd0;
            data_out_reg <= 'hx;
            tx_en_reg <= 1'b0; 
            tx_nbytes_busy_o <= 1'b0;
        end
        else begin
            if(send_en_pos) begin
                tx_send_num <= 'd1;
                data_out_reg <= nbytes_data_out_i;
                data_o <= nbytes_data_out_i[8*BYTE_NUM-1:8*BYTE_NUM-8];
                tx_en_reg <= 1'b1;
                tx_nbytes_busy_o <= 1'b1;
            end
            else begin
                if(send_done_pos) begin
                    tx_send_num <= tx_send_num + 1'd1;
                    data_o <= data_out_reg[8*BYTE_NUM-9:8*BYTE_NUM-16];
                    data_out_reg = data_out_reg << 8;
                end
                else begin
                    tx_send_num <= tx_send_num;
                    data_o <= data_o;
                end
                if(tx_send_num == BYTE_NUM) begin
                    tx_en_reg <= 1'b0;
                    tx_send_num <= 'd0;
                    tx_nbytes_busy_o <= 1'b0;
                end
                else begin
                    tx_nbytes_busy_o <= 1'b1;
                end                
            end
        end
    end

    
    
endmodule


    
//    // output for test 
//    output reg [3:0] tx_send_num,   // place for test 
//    output tx_en,
//    output reg [7:0] data,
//    output reg [31:0] data_out_reg,

//data_o <= nbytes_data_out_i[7:0];
//data_out_reg = data_out_reg >> 8;
//data_o <= data_out_reg[15:8];
//data_out_reg = data_out_reg >> 8;  
