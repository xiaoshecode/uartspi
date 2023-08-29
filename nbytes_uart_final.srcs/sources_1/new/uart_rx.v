`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/14 17:23:06
// Design Name: 
// Module Name: uart_rx
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

module uart_rx
    #(
        parameter CLK_FREQ = 50,        // Clock frequency(MHz)
        parameter UART_BPS = 9600,      // Set for baud rate
        parameter CHECK_SEL = 1         // Selecting for parity check mode, 1 for odd check and 0 for even check.
    )
    (
        input clk_i,                    // System clock 50MHz
        input rst_n_i,                  // Reset signal, active when 0 
        input uart_rxd_i,               // Data input from computer 

        output wire rx_bytes_done_o,    // RX module finished receiving data
        output reg rx_valid_o,          /* Data received is valid(data pass parity check) when rx_valid_o = 1, this signal will be generated 
                                           when rx_busy drop to 0. So check both negedge of rx_busy signal and posedge of rx_valid signal will
                                           indicate a byte data has been received and the data is correct. */
        output reg [7:0] data_in_o      // Data received, 8 bits, not include parity check bit.
    );
    
    //parameter define
    localparam  BPS_CNT  = CLK_FREQ * 1000000 / UART_BPS;   // Counter for the specific baud rate
    localparam  BAUD_FLAG = BPS_CNT / 2;                    // Flag for baud rate counter 
    
    reg u_rx0;                  // Flip-flop for data receiving
    reg u_rx1;                  // Flip-flop for data receiving

    reg [14:0] baud_cnt;        // Counting value for baud rate
    reg [8:0] rx_data;
    reg [3:0]  bit_cnt;         // Counting value for bit has recived in byte data 

    reg rx_state;               // Receiving process state
    reg bit_flag;               
    reg rx_done;                // Showing receiving process finish
    
    reg o_check;                // Reg for odd check
    reg e_check;                // Reg for even check
    wire check;                 // Wire for parity check
    
    reg rx_busy_o;              // Reg for showing rx module is working 
    reg rx_busy0;               // FF reg to catch rx_busy's negedge
    reg rx_busy1;    
    
    
    /* Generate data receiving state signal, when receiving, 
        drx_state is 1, otherwise drx_stae is 0 */ 
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin        
            rx_state <= 1'b0;
        end
        else if((~u_rx0) & (u_rx1)) begin
            rx_state <= 1'b1 ;
        end
        else if(rx_done) begin
            rx_state <= 1'b0;
        end
        else begin
            rx_state <= rx_state ;
        end
    end
    
    // Receiving data 
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            u_rx0 <= 1'b1;
            u_rx1 <= 1'b1;
        end
        else begin
            u_rx0 <= uart_rxd_i;
            u_rx1 <= u_rx0;
        end
    end
    
    // Count for the baud rates
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) 
            baud_cnt <= 1'b0;
        else if(rx_state)begin
            if(baud_cnt == BPS_CNT - 1)
                baud_cnt <= 1'b0;
            else
                baud_cnt <= baud_cnt + 1'b1;
        end
        else
            baud_cnt <= 1'b0 ;
    end
    
    // Counting for the bit flag
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) 
            bit_flag <= 1'b0;
        else if(baud_cnt == BAUD_FLAG)
            bit_flag <= 1'b1;
        else
            bit_flag <= 1'b0;
    end
    
    // Counting bit number that has been received
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) 
            bit_cnt <= 1'b0;
        else if(bit_flag)begin
            if(bit_cnt == 10)
                bit_cnt <= 1'b0;
            else
                bit_cnt <= bit_cnt + 1'b1;
        end
        else
            bit_cnt <= bit_cnt;
    end
   
    
    // Receiving and store data
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) 
            rx_data <= 9'b000000000;
        else if(bit_flag)begin     
            case(bit_cnt)
                4'd0: rx_data <= rx_data;
                4'd1: rx_data[0] <= u_rx1;
                4'd2: rx_data[1] <= u_rx1;
                4'd3: rx_data[2] <= u_rx1;
                4'd4: rx_data[3] <= u_rx1;
                4'd5: rx_data[4] <= u_rx1;
                4'd6: rx_data[5] <= u_rx1;
                4'd7: rx_data[6] <= u_rx1;
                4'd8: rx_data[7] <= u_rx1;
                4'd9: rx_data[8] <= u_rx1;
                4'd10: rx_data   <= rx_data;
                default : rx_data <= rx_data;
            endcase
        end
        else
            rx_data <= rx_data ;
    end    
        
    /* Generate rx_busy signal, when receiving, 
        rx_busy is 1, otherwise rx_busy is 0 */ 
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin        
            rx_busy_o <= 1'b0;
        end
        else if((~u_rx0) & (u_rx1)) begin
            rx_busy_o <= 1'b1 ;
        end
        else if(bit_flag && bit_cnt == 4'd10 ) begin
            rx_busy_o <= 1'b0;
        end
        else begin
            rx_busy_o <= rx_busy_o ;
        end
    end
    
    // Generate receiving finish flag 
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) 
            rx_done <= 1'b1;
        else if(bit_cnt == 10 && bit_flag)
            rx_done <= 1'b1;
        else
            rx_done <= 1'b0;
    end

    //Doing parity check
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            o_check <= 1'b0; 
            e_check <= 1'b0;
        end
        else if(bit_cnt == 9 && bit_flag) begin
            data_in_o <= rx_data[7:0];   
            e_check <= rx_data[0] ^ rx_data[1] ^ rx_data[2] ^ rx_data[3] ^ rx_data[4] ^ rx_data[5] ^ rx_data[6] ^ rx_data[7];
            o_check <= ~(rx_data[0] ^ rx_data[1] ^ rx_data[2] ^ rx_data[3] ^ rx_data[4] ^ rx_data[5] ^ rx_data[6] ^ rx_data[7]);
        end
        else begin
            o_check <= o_check;
            e_check <= e_check;
        end
    end
    
    always @(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i)
            rx_valid_o <= 1'b0 ;
        else if(rx_done) begin
            if(CHECK_SEL == 1'b0 && e_check == rx_data[8])
              rx_valid_o <= 1'b1;
            else if(CHECK_SEL == 1'b1 && o_check == rx_data[8])
              rx_valid_o <= 1'b1;
            else 
              rx_valid_o <= 1'b0;     
        end
        else
            rx_valid_o <= 1'b0 ;
    end
    
    // Catch negedge of rx_busy signal, showing 8 bits data has been received 
    assign rx_bytes_done_o = rx_busy1 & (~rx_busy0);
    
    always @(posedge clk_i or negedge rst_n_i) begin         
        if (!rst_n_i) begin
            rx_busy0 <= 1'b0;                                  
            rx_busy1 <= 1'b0;
        end                                                      
        else begin                                               
            rx_busy0 <= rx_busy_o;                               
            rx_busy1 <= rx_busy0;                            
        end
    end
    

endmodule


//    // Receiving and store data
//    always@(posedge clk_i or negedge rst_n_i) begin
//        if(!rst_n_i) 
//            rx_data <= 9'b000000000;
//        else if(bit_flag)begin     
//            case(bit_cnt)
//                4'd0: begin rx_data <= rx_data; rx_busy_o <= 1'b0;end
//                4'd1: begin rx_data[0] <= u_rx1; rx_busy_o <= 1'b1;end
//                4'd2: begin rx_data[1] <= u_rx1; rx_busy_o <= 1'b1;end
//                4'd3: begin rx_data[2] <= u_rx1; rx_busy_o <= 1'b1;end
//                4'd4: begin rx_data[3] <= u_rx1; rx_busy_o <= 1'b1;end
//                4'd5: begin rx_data[4] <= u_rx1; rx_busy_o <= 1'b1;end
//                4'd6: begin rx_data[5] <= u_rx1; rx_busy_o <= 1'b1;end
//                4'd7: begin rx_data[6] <= u_rx1; rx_busy_o <= 1'b1;end
//                4'd8: begin rx_data[7] <= u_rx1; rx_busy_o <= 1'b1;end
//                4'd9: begin rx_data[8] <= u_rx1; rx_busy_o <= 1'b1;end
//                4'd10: begin  rx_data   <= rx_data; rx_busy_o <= 1'b0;end
//                default : begin rx_data <= rx_data; rx_busy_o <= 1'b0;end
//            endcase
//        end
//        else
//            rx_data <= rx_data ;
//    end