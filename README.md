# uartspi

Verilog UART 多字节回环与独立 SPI Master 实验代码，附 Vivado 工程快照和 Python 串口客户端。

[在线文档](https://xiaoshecode.github.io/xiaoshecode/repos/uartspi/) · [原 UART 说明](README4uart.md)

## 目录与源文件

| 路径 | 用途 |
| --- | --- |
| 根目录 `uart_*.v`、`read_n_bytes.v`、`send_n_bytes.v` | UART 顶层、单字节收发、多字节缓冲和旧测试平台 |
| `spi_master.v` | 独立 SPI 时钟发生器与 Master，不属于 UART 回环的数据路径 |
| `nbytes_uart_final.srcs/` | Vivado 保存的源、约束、IP 和仿真副本 |
| `use/nbytes_uart_final.xpr` | Vivado 工程入口，打开后先检查源引用是否解析到当前检出路径 |
| `use/main.py` | 可配置串口回环检查工具 |
| `tests/` | 无硬件 Python 回归测试 |

**每次构建只选一套 UART 源。** 根目录与 Vivado 副本包含同名模块，不能一起加入编译。更改公共 UART 逻辑时要同步检查两套源。

## 参数与复位

默认 UART 参数为 `CLK_FREQ=50` MHz、`BAUD_RATE=9600`、`CHECK_SEL=1`（奇校验）、`BYTE_NUM=4`。客户端对应 9600、8O1、4 字节一组；若修改 HDL 波特率，传入相同的 `--baudrate`。

顶层 `uart` 使用低有效 `rst_n_i` 输入。此次修复恢复该端口，修正旧 testbench 的不存在端口错误；综合前必须按实际开发板连接复位，并在 XDC 中指定正确引脚和电平。原示例复位约束被注释，不能直接假设引脚正确。

SPI 的 `CLK_FREQ` 单位 MHz，`SPI_CLK` 单位 kHz，`RstP_I` 为**高有效异步复位**。默认 SPI 数据宽度 24 位；各 CPOL/CPHA 模式仍需专用时序仿真。

## 主机安装与运行

```sh
python -m venv .venv
# 激活虚拟环境后：
python -m pip install -r requirements.txt
python use/main.py --help
python use/main.py --port COM4 --baudrate 9600 --count 100
```

Linux 可用 `--port /dev/ttyUSB0`。运行硬件回环前先完成 FPGA 下载和复位，检查串口接线；脚本始终关闭串口，即使读写异常。旧版本默认发送 100 万组且使用与 HDL 不一致的 1500000 波特率，现已改为显式参数和 100 组默认值。

## 验证

```sh
python -m unittest discover -s tests -v
```

2026-10-30：3 项主机测试通过（回环、异常关闭、空测试次数拒绝）；pyslang 12.1.0 对根目录 Verilog 与 Vivado 源副本分别解析/展开，无 error。`spi_master.v` 已由 GB18030 转为 UTF-8；移除接收总线的持续 `x` 驱动。仍有符号比较、调试隐式线网和位宽告警，不能据此宣称硬件无错误。

旧 `uart_tb.v` 使用手工激励、没有自动断言/结束条件，未作为通过的行为仿真测试。未执行 Vivado 综合、时序收敛或真实串口/SPI 回环。

## 维护

新增文本遵循 `.editorconfig`，提交前运行 `git diff --check`。不要提交 `.Xil`、日志、波形和 Python 缓存。仓库目前没有统一 LICENSE，复用授权需向作者确认。
