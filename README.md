# uartspi

Verilog UART 多字节回环与独立 SPI Master 实验代码，附 Vivado 工程快照和 Python 串口客户端。

[在线文档](https://xiaoshecode.github.io/xiaoshecode/repos/uartspi/) · [原 UART 说明](README4uart.md)

## 目录与源文件

| 路径 | 用途 |
| --- | --- |
| 根目录 `uart_*.v`、`read_n_bytes.v`、`send_n_bytes.v` | UART 顶层、单字节收发、多字节缓冲和旧测试平台 |
| `uart_board_top.v`（两套源各一份） | 保留原有时钟/RX/TX 三个物理端口，向 UART 核提供配置后启动复位 |
| `spi_master.v` | 独立 SPI 时钟发生器与 Master，不属于 UART 回环的数据路径 |
| `nbytes_uart_final.srcs/` | Vivado 保存的源、约束、IP 和仿真副本 |
| `use/nbytes_uart_final.xpr` | Vivado 工程入口，源引用相对工程目录指向旁侧 `nbytes_uart_final.srcs/` |
| `use/main.py` | 可配置串口回环检查工具 |
| `tests/` | 无硬件 Python/工程接口检查与自检式启动复位 RTL 测试平台 |

**每次构建只选一套 UART 源。** 根目录与 Vivado 副本包含同名模块，不能一起加入编译。更改公共 UART 逻辑时要同步检查两套源。

## 参数与复位

默认 UART 参数为 `CLK_FREQ=50` MHz、`BAUD_RATE=9600`、`CHECK_SEL=1`（奇校验）、`BYTE_NUM=4`。客户端对应 9600、8O1、4 字节一组；若修改 HDL 波特率，传入相同的 `--baudrate`。

核心模块 `uart` 使用低有效 `rst_n_i` 输入，供现有 testbench 或其他集成调用。保存的 Vivado 工程现在固定选择 **`uart_board_top`** 为综合顶层，保持 `clk_50m_i`、`uart_rxd_i`、`uart_txd_o` 三个物理端口，与现有 XDC 相符，不新增或猜测复位引脚。

板级包装层利用 Xilinx FPGA 配置时的寄存器初始化，将 UART 核在最初 4 个时钟采样沿保持复位，随后同步释放。它只提供配置后的启动复位，不提供按钮复位、看门狗或断钟恢复；移植到其他器件时需核对寄存器初始化支持。若单独把 `uart` 作为其他工程顶层，则必须自行提供复位及配套约束。历史综合 checkpoint 不再自动复用，修改顶层后应完整重建。

SPI 的 `CLK_FREQ` 单位 MHz，`SPI_CLK` 单位 kHz，`RstP_I` 为**高有效异步复位**。默认 SPI 数据宽度 24 位；各 CPOL/CPHA 模式仍需专用时序仿真。

## 主机安装与运行

```sh
python -m venv .venv
# 激活虚拟环境后：
python -m pip install -r requirements.txt
python use/main.py --help
python use/main.py --port COM4 --baudrate 9600 --count 100
```

Linux 可用 `--port /dev/ttyUSB0`。运行硬件回环前先完成 FPGA 下载，等待启动复位释放并检查串口接线；脚本始终关闭串口，即使读写异常。旧版本默认发送 100 万组且使用与 HDL 不一致的 1500000 波特率，现已改为显式参数和 100 组默认值。

## 验证

```sh
python -m unittest discover -s tests -v
```

2026-10-30：6 项 Python 测试通过（3 项主机测试，3 项工程顶层/物理端口约束/源路径一致性检查）；pyslang 12.1.0 对两套 UART 源及新增启动复位测试平台分别解析/展开，均为 0 errors、18 warnings。`spi_master.v` 已由 GB18030 转为 UTF-8；移除接收总线的持续 `x` 驱动。仍有符号比较、调试隐式线网和位宽告警，不能据此宣称硬件无错误。

安装 Icarus Verilog 后可运行不涉及硬件的启动复位仿真：

```sh
iverilog -g2012 -s uart_board_startup_tb -o startup.vvp tests/uart_board_startup_tb.v uart_board_top.v uart_top.v uart_rx.v uart_tx.v read_n_bytes.v send_n_bytes.v
vvp startup.vvp
```

测试平台断言启动复位保持 4 个采样沿、随后持续释放以及空闲 TX 电平，并设超时。本次环境没有可运行的 RTL 模拟器，**上述行为仿真未执行**；只完成了测试平台的解析/展开和工程接口静态检查。

旧 `uart_tb.v` 使用手工激励、没有自动断言/结束条件，未作为通过的行为仿真测试。未执行 Vivado 综合、时序收敛或真实串口/SPI 回环。

## 维护

新增文本遵循 `.editorconfig`，提交前运行 `git diff --check`。不要提交 `.Xil`、日志、波形和 Python 缓存。仓库目前没有统一 LICENSE，复用授权需向作者确认。
