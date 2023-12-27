（1）uart_top 模块
clk_50m_i : 时钟输入，默认使用开发板上50MHz时钟。
rst_n_i: 复位输入，低电平有效。
uart_rxd_i: uart输入端口，按位接收数据。
uart_txd_i: uart输出端口，按位发送数据。

（2）read_n_bytes 模块
clk_i: 时钟输入。
rst_n_i: 复位输入，低电平有效。
uart_rxd_i: uart输入端口，按位接收数据。

nbytes_crc_valid_o: 收到的n bytes数据奇偶校验通过时置1，脉冲信号，1个时钟周期后置0。
nbytes_data_in_o：接收到的n bytes 数据输出。
rx_nbytes_data_valid_o: 已经接收完毕n bytes数据时置1，脉冲信号，1个时钟周期后置0。

调用 read_n_bytes 模块时如何判断是否收到以及数据有效：
若nbytes_crc_valid_o信号和rx_nbytes_data_valid_o信号同时为1，则数据收到且有效，
若rx_nbytes_data_valid_o =1且nbytes_crc_valid_o = 0， 则数据已收到但出错无效。
这两个信号的输出是同步的。

（3）send_n_bytes 模块
clk_i: 时钟输入。
rst_n_i: 复位输入，低电平有效。
send_en_i: 发送开始信号，需要为持续信号至整体发送结束。
uart_txd_i: uart输入端口，按位发送数据。
nbytes_data_out_i: 所需要发送的n bytes 数据输出。

tx_nbytes_busy_o: n bytes 发送模块整体繁忙，该信号从接收到send_enable 信号后置1，持续至发送完成后归0。该信号为1时不应向模块传入数据下无法发送。
uart_txd_i: uart输出端口，按位发送数据。


uart_rx 模块
clk_i: 时钟输入。
rst_n_i: 复位输入，低电平有效。
uart_rxd_i: uart输入端口，按位接收数据。

rx_bytes_done_o: 接收到1字节数据后置1，随后在下一个时钟周期后置0，脉冲信号。
rx_valid_o: 接收到的1字节数据有效后置1，随后在下一个时钟周期后置0，脉冲信号。
调用 uart_rx 模块时如何判断是否收到以及数据有效：
若rx_bytes_done_o信号与 rx_valid_o信号同时为1时，接收到数据完成且有效。
若rx_bytes_done_o信号为1且 rx_valid_o 为0时，接收到数据但数据无效。

uart_tx 模块
clk_i: 时钟输入。
rst_n_i: 复位输入，低电平有效。
tx_en_i: 发送开始信号，需要为持续信号至整体发送结束。
uart_txd_i: uart输入端口，按位发送数据。
data_out_i: 所需要发送的1 bytes 数据输出。

tx_busy_o:  单字节发送模块繁忙，该信号从接收到tx_en信号准备开始发送后置1，持续至发送完成后归0.该信号为1时
u_tx_o: uart输出端口，按位发送数据。 
