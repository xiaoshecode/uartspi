`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/14 16:36:06
// Design Name: 
// Module Name: uart_tx
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

module uart_tx
    #(
        parameter CLK_FREQ = 50,        // Clock frequency(MHz)
        parameter UART_BPS = 9600,      // Set for baud rate
        parameter CHECK_SEL = 1         // Selecting for parity check mode, 1 for odd check and 0 for even check.
    )
    (
        input clk_i,                    // System clock: 50MHz
        input rst_n_i,                  // Reset when rst_n_i = 1
        input tx_en_i,                  // Enable signal for transmission
        input [7:0] data_out_i,         // Data need to be sent
        
        output wire [8:0] tx_data_test,
        
        output reg tx_busy_o,           // Busy signal showing the transmission module is working 
//        output reg tx_send_byte_done_o, // Showing that 1 byte has been sent 
        output wire uart_txd_o               // Data out to computer, bit by bit 
    );
    
    //parameter define
    localparam  BPS_DR  = CLK_FREQ * 1000000 / UART_BPS;   // Count for baud rate
    localparam  BAUD_FLAG = 1;          // Baud flag
    
    reg tx_state;          // Tx state
    reg bit_flag;               // Flag showing transmission process is working
    reg tx_done;                // Tx finish
    reg e_check;                // Reg for even parity check
    reg o_check;                // Reg for odd parity check
    reg check;                  // Reg for parity check
    
//    reg tx_state=1'b0;          // Tx state
//    reg bit_flag = 1'b0;               // Flag showing transmission process is working
//    reg tx_done = 1'b0;                // Tx finish
//    reg e_check = 1'b0;                // Reg for even parity check
//    reg o_check = 1'b0;                // Reg for odd parity check
//    reg check = 1'b0;                  // Reg for parity check
    reg u_tx_o = 1'b1;

    reg [3:0]  bit_cnt;         // Counter for the bit to be sent
    reg [8:0] tx_data = 9'hx;          // Data reg to store data need to be sent
    reg [14:0] baud_cnt;        // Counter for baud rate
   
    assign tx_data_test = tx_data;
    
    assign uart_txd_o = u_tx_o;
    
    /* Generate data transmission state signal, when transmitting, 
        Uart_state is 1, otherwise Uart_stae is 0 */
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            tx_state <= 1'b0;
        end
        else if(tx_en_i) begin
            tx_state <= 1'b1;
        end
        else if(tx_done) begin
            tx_state <= 1'b0 ;
        end
        else begin
            tx_state <= tx_state;
        end 
    end
    
    // Read data to be sent
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            tx_data <= 9'bxxxxxxxx;
        end
        else if(tx_en_i) begin
            tx_data <= data_out_i;
        end
        else if(tx_done) begin
            tx_data <= 9'b000000000;
        end
        else begin
            tx_data <= tx_data;
        end 
    end
        
    
    // Counting bit number that has been sent
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) 
            baud_cnt <= 1'b0;
        else if(tx_state)begin
            if(baud_cnt == BPS_DR - 1)
                baud_cnt <= 1'b0;
            else
                baud_cnt <= baud_cnt + 1'b1;
        end
        else
            baud_cnt <= 1'b0;
    end
    
    // Setting bit flag 
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) 
            bit_flag <= 1'b0;
        else if(baud_cnt == BAUD_FLAG)
            bit_flag <= 1'b1;
        else
            bit_flag <= 1'b0;
    end
    
    // Counting bit number in byte data that has been sent
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            bit_cnt <= 1'b0;
        end
        else if(bit_flag)begin
            if(bit_cnt == 10)
                bit_cnt <= 1'b0;
            else
                bit_cnt <= bit_cnt + 1'b1;
        end
        else
            bit_cnt <= bit_cnt;
    end

    // Generate busy signal so the module will not read new data in
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            tx_busy_o <= 1'b0;
        end
        else if(bit_cnt == 4'd10 && bit_flag) begin
            tx_busy_o <= 1'b0 ;
        end
        else if(tx_en_i) begin
            tx_busy_o <= 1'b1;
        end
        else begin
            tx_busy_o <= tx_busy_o;
        end 
    end

    // Sending data through uart, 8 bit + 1 parity check bit, Stop bit is high 
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            u_tx_o <= 1'b1;
//            tx_busy_o <= 1'b0;
        end
        else if(bit_flag)begin
            case(bit_cnt)
                4'd0 : u_tx_o <= 1'b0;
                4'd1 : u_tx_o <= tx_data[0];
                4'd2 : u_tx_o <= tx_data[1];
                4'd3 : u_tx_o <= tx_data[2];
                4'd4 : u_tx_o <= tx_data[3];
                4'd5 : u_tx_o <= tx_data[4];
                4'd6 : u_tx_o <= tx_data[5];
                4'd7 : u_tx_o <= tx_data[6];
                4'd8 : u_tx_o <= tx_data[7];
                4'd9 : u_tx_o <= check;
                4'd10: u_tx_o <= 1'b1;
                default : u_tx_o <= 1'b1;
            endcase
        end
        else
            u_tx_o <= u_tx_o;
    end
    
    //Doing parity check
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            o_check <= 1'b0; 
            e_check <= 1'b0;
        end
        else if(tx_done) begin   
            e_check <= tx_data[0] ^ tx_data[1] ^ tx_data[2] ^ tx_data[3] ^ tx_data[4] ^ tx_data[5] ^ tx_data[6] ^ tx_data[7];
            o_check <= ~(tx_data[0] ^ tx_data[1] ^ tx_data[2] ^ tx_data[3] ^ tx_data[4] ^ tx_data[5] ^ tx_data[6] ^ tx_data[7]);
        end
        else begin
            o_check <= o_check;
            e_check <= e_check;
        end
    end
    
    always @(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            check <= 1'b0;
        end    
        else if(bit_flag) begin
            if(CHECK_SEL == 1'b0) begin
              check <= e_check;
            end
            else if(CHECK_SEL == 1'b1) begin
              check <= o_check;
            end
            else 
              check <= 1'b0;     
        end
        else
              check <= 1'b0;
    end
            
    // Showing state that sending process done
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin 
            tx_done <= 1'b0;
//            tx_send_byte_done_o <= 1'b0;
        end
        else if(bit_cnt == 4'd10 && bit_flag) begin
            tx_done <= 1'b1;
//            tx_send_byte_done_o <= 1'b1;
        end
        else begin
            tx_done <= 1'b0;
//            tx_send_byte_done_o <= 1'b0;
        end
    end
    


endmodule



//              tx_valid <= 1'b1;
// always @(posedge clk or negedge rst_n_i) begin
//        if(!rst_n_i)
//            tx_valid <= 1'b0 ;
//        else if(bit_flag) begin
//            if(check_sel == 1'b0 && e_check == tx_data[8]) begin
//              tx_valid <= 1'b1;
//              check <= e_check;
//            end
//            else if(check_sel == 1'b1 && o_check == tx_data[8]) begin
//              tx_valid <= 1'b1;
//              check <= o_check;
//            end
//            else 
//              tx_valid <= 1'b0;     
//        end
//        else
//            tx_valid <= 1'b0 ;
//    end


    
//    // Set baud rate 
//     always@(posedge clk or negedge rst_n_i) begin
//        if(!rst_n_i)
//            bps_DR <= 16'd5208;             // Default baud rate 9600
//        else begin
//            case(baud_set)
//                3'd0:bps_DR <= 16'd5208;       // Set baud rate 9600
//                3'd1:bps_DR <= 16'd2604;       // Set baud rate 19200
//                3'd2:bps_DR <= 16'd1302;       // Set baud rate 38400
//                3'd3:bps_DR <= 16'd868;        // Set baud rate 57600
//                3'd4:bps_DR <= 16'd434;        // Set baud rate 115200
//                default:bps_DR <= 16'd5208; // Default is 9600
//                endcase            
//        end        
//     end 
    // Selecting mode for parity check
//    assign check =(check_sel)? e_check : o_check; 
//    assign tx_valid = (check == data_out_i[8])? 1:0;
    
//    assign tx_ready = tx_done;    
//    //Generating start signal for tx
//    always@(posedge clk or negedge rst_n_i) begin
//        if(!rst_n_i) 
//            tx_start <= 1'b0;
//        else if(tx_en_i && tx_done) begin
//            tx_start <= 1'b1;
//        end
//        else
//            tx_start <= 1'b0;
//    end

    
//    // Sending data through uart, 8 bit + 1 parity check bit, Stop bit is high 
//    always@(posedge clk_i or negedge rst_n_i) begin
//        if(!rst_n_i) begin
//            u_tx_o <= 1'b1;
//            tx_busy_o <= 1'b0;
//        end
//        else if(bit_flag)begin
//            case(bit_cnt)
//                4'd0 : begin u_tx_o <= 1'b0; tx_busy_o <= 1'b0;end
//                4'd1 : begin u_tx_o <= tx_data[0]; tx_busy_o <= 1'b1;end
//                4'd2 : begin u_tx_o <= tx_data[1]; tx_busy_o <= 1'b1;end
//                4'd3 : begin u_tx_o <= tx_data[2]; tx_busy_o <= 1'b1;end
//                4'd4 : begin u_tx_o <= tx_data[3]; tx_busy_o <= 1'b1;end
//                4'd5 : begin u_tx_o <= tx_data[4]; tx_busy_o <= 1'b1;end
//                4'd6 : begin u_tx_o <= tx_data[5]; tx_busy_o <= 1'b1;end
//                4'd7 : begin u_tx_o <= tx_data[6]; tx_busy_o <= 1'b1;end
//                4'd8 : begin u_tx_o <= tx_data[7]; tx_busy_o <= 1'b1;end 
//                4'd9 : begin u_tx_o <= check; tx_busy_o <= 1'b1;end
//                4'd10: begin u_tx_o <= 1'b1; tx_busy_o <= 1'b0;end
//                default : begin u_tx_o <= 1'b1;  tx_busy_o <= 1'b0;end
//            endcase
//        end
//        else
//            u_tx_o <= u_tx_o;
//    end
