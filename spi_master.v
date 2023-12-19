`timescale 1ns / 1ps
// *******************************************************
// SPI_Master V1.0
// xiaoshe from TIQC
// *******************************************************
//例化说明：
// SPI_Master 
// #(
// 	.CLK_FREQ(100),			/* 100MHz */
// 	.SPI_CLK (5000),		    /* 5000kHz */
// 	.CPOL(0),				/* SPI */
// 	.CPHA(0),				/* SPI */
// 	.DATA_WIDTH(DATA_WIDTH)			/* 24bit */
// )
// SPI_top(.Clk_I(clk_100M),
//         .RstP_I(reset),
//         .WrRdReq_I(WrRdReq_I),
//         .Data_I(Data_I_com),
//         .Data_O(Data_O),
//         .DataValid_O(DataValid_O),
//         .Busy_O(Busy_O),
//         .SCK_O(sclk),
//         .MOSI_O(mosi),
//         .MISO_I(miso),
//         .CS_O(cs));
module SPI_Clock#
(
	parameter	CLK_FREQ        = 50,
    parameter   CPOL            = 1'b0,
	parameter	SPI_CLK_FREQ    = 1000
)
(
	input       Clk_I,
	input       RstP_I,
	input       En_I,
	output      SCK_O,
	output      SCKEdge1_O,		    /* 时钟的第一个跳变沿 */
	output      SCKEdge2_O			/* 时钟的第二个跳变沿 */
);

/* SPI时序说明：1、当CPOL=1时，SCK在空闲时候为低电平，第一个跳变为上升沿
				2、当CPOL=0时，SCK在空闲时为高电平，第一个跳变为下降沿
*/
/* 时钟分频计数器 */
localparam	CLK_DIV_CNT = (CLK_FREQ * 1000)/SPI_CLK_FREQ;
reg         SCK;
reg         SCK_Pdg, SCK_Ndg;
reg[31:0]	ClkDivCnt;
/* 时钟分频计数器控制块 */
always@(posedge Clk_I or posedge RstP_I) begin
	if(RstP_I)
		ClkDivCnt <= 32'd0;
	else if(!En_I)
        ClkDivCnt <= 32'd0;
    else begin
        if(ClkDivCnt == CLK_DIV_CNT - 1)
            ClkDivCnt <= 32'd0;
        else
            ClkDivCnt <= ClkDivCnt + 1'b1;
    end
end
/* SCK控制块 */
always@(posedge Clk_I or posedge RstP_I) begin
	if(RstP_I)
        SCK <= (CPOL) ? 1'b1 : 1'b0;
    else if(!En_I)
        SCK <= (CPOL) ? 1'b1 : 1'b0;
    else begin
        if(ClkDivCnt == CLK_DIV_CNT - 1 || (ClkDivCnt == (CLK_DIV_CNT >> 1) - 1))
            SCK <= ~SCK;
        else
            SCK <= SCK;
    end
end
/* SCK上升沿检测块 */
always@(posedge Clk_I or posedge RstP_I) begin
    if(RstP_I)
        SCK_Pdg <= 1'b0;
    else begin
        if(CPOL)
            SCK_Pdg <= (ClkDivCnt == CLK_DIV_CNT - 1) ? 1'b1 : 1'b0;
        else
            SCK_Pdg <= (ClkDivCnt == (CLK_DIV_CNT >> 1) - 1) ? 1'b1 : 1'b0;
    end
end
 
/* SCK下降沿检测块 */
always@(posedge Clk_I or posedge RstP_I) begin
    if(RstP_I)
        SCK_Ndg <= 1'b0;
    else begin
        if(CPOL)
            SCK_Ndg <= (ClkDivCnt == (CLK_DIV_CNT >> 1) - 1) ? 1'b1 : 1'b0;
        else
            SCK_Ndg <= (ClkDivCnt == CLK_DIV_CNT - 1) ? 1'b1 : 1'b0;
    end
end
/* 根据CPOL来选择边沿输出 */
assign SCKEdge1_O = (CPOL) ? SCK_Ndg : SCK_Pdg;
assign SCKEdge2_O = (CPOL) ? SCK_Pdg : SCK_Ndg;
assign SCK_O = SCK;
endmodule


module SPI_Master#
(
	parameter	CLK_FREQ = 100,			/* 模块时钟输入，单位为MHz */
	parameter	SPI_CLK = 1000,		    /* SPI时钟频率，单位为KHz */
	parameter	CPOL = 0,				/* SPI时钟极性控制 */
	parameter	CPHA = 0,				/* SPI时钟相位控制 */
	
	parameter	DATA_WIDTH = 24			/* 数据宽度 */
)
(
	input       Clk_I,			/* 模块时钟输入，应和CLK_FREQ一样 */
	input       RstP_I,			/* 同步复位信号，低电平有效 */
	
	input       WrRdReq_I,		                        /* 读/写数据请求 */	
	input       [DATA_WIDTH - 1:0]      Data_I,		    /* 要写入的数据 */
	output      [DATA_WIDTH - 1:0]      Data_O,		    /* 读取到的数据 */
	output	    DataValid_O,	                        /* 读取数据有效，上升沿有效 */
	output 	    Busy_O,			                        /* 模块忙信号 */
    
	output	    SCK_O,			/* SPI模块时钟输出 */
	output	    MOSI_O,			/* MOSI_O */
	input	    MISO_I,			/* MISO_I  */
	output		CS_O
);
 
localparam	    IDLE 	= 0;		/* 模块空闲 */
localparam	    START	= 1;
localparam	    RUNNING	= 2;		/* 模块运行中 */
localparam	    DELIVER	= 3;		/* 数据转发 */
 
 
reg[7:0]        MainState, NxtMainState;
wire	        SCKEdge1, SCKEdge2;
wire 	        SCKEnable;
wire			RecvDoneFlag;
reg[7:0]	    SCKEdgeCnt;
 
 
reg[DATA_WIDTH - 1:0]	    WrDataLatch;
reg[DATA_WIDTH - 1:0]	    RdDataLatch;
 
/* 读写信号上升沿检测 */
wire 	        WrRdReq_Pdg;					
reg 	        WrRdReq_D0, WrRdReq_D1;
 
/* 实例化一个SPI时钟模块 */
SPI_Clock#
(
	.CLK_FREQ(CLK_FREQ),
    .CPOL(CPOL),
	.SPI_CLK_FREQ(SPI_CLK)
)
SPI_Clock_Inst 
( 
	.En_I(SCKEnable),
	.Clk_I(Clk_I),
	.SCKEdge1_O(SCKEdge1),
	.SCKEdge2_O(SCKEdge2),
	.RstP_I(RstP_I),
	.SCK_O(SCK_O)
);
 
/* 检测写请求的上升沿 */
assign	WrRdReq_Pdg = (WrRdReq_D0) && (~WrRdReq_D1);
always@(posedge Clk_I or posedge RstP_I) begin
	if(RstP_I) begin	
        WrRdReq_D0 <= 1'b0;
        WrRdReq_D1 <= 1'b0;
	end	
    else begin
        WrRdReq_D0 <= WrRdReq_I;
        WrRdReq_D1 <= WrRdReq_D0;
	end
end
 
/* 主状态机 */
always@(posedge Clk_I or posedge RstP_I) begin
    if(RstP_I)
        MainState <= IDLE;
    else
        MainState <= NxtMainState;
end
 
always@(*) begin
    NxtMainState = IDLE;
    case(MainState)
        IDLE: NxtMainState = (WrRdReq_Pdg) ? START: IDLE;
        START: NxtMainState = RUNNING;
        RUNNING: NxtMainState = (RecvDoneFlag) ? DELIVER : RUNNING;
        DELIVER: NxtMainState = IDLE;
        default: NxtMainState = IDLE;
    endcase
end
 
 
/* 发送数据控制块 */
always@(posedge Clk_I or posedge RstP_I) begin
    if(RstP_I)
        WrDataLatch <= 0;
    else begin
        case(MainState)
            START: WrDataLatch <= Data_I;	/* 先保存需要发送的数据 */
            RUNNING: begin
                /* 如果CPHA=1，则在时钟的第一个边沿输出，否则在第二个边沿输出 */
                if(CPHA == 1'b1 && SCKEdge1)
                    WrDataLatch <= {WrDataLatch[DATA_WIDTH - 2:0], 1'b0};
                else if(CPHA == 1'b0 && SCKEdge2)
                    WrDataLatch <= {WrDataLatch[DATA_WIDTH - 2:0], 1'b0};
                else
                    WrDataLatch <= WrDataLatch;
            end
            default: WrDataLatch <= 0;
        endcase
    end
end
 
/* 接收数据控制块 */
always@(posedge Clk_I or posedge RstP_I) begin
    if(RstP_I)
        RdDataLatch <= 0;
    else begin
        case(MainState)
            START: RdDataLatch <= 0;
            RUNNING: begin
                /* 如果CPHA = 1，则在时钟的每二个边沿对数据进行采样，
                   否则在第一个边沿采样 */
                if(CPHA == 1'b1 && SCKEdge2)	
                    RdDataLatch <= {RdDataLatch[DATA_WIDTH - 2:0], MISO_I};
                else if(CPHA == 1'b0 && SCKEdge1)
                    RdDataLatch <= {RdDataLatch[DATA_WIDTH - 2:0], MISO_I};
                else
                    RdDataLatch <= RdDataLatch;
            end
            default: RdDataLatch <= RdDataLatch;
        endcase
    end
end
 
/* 时钟边沿计数块 */
always@(posedge Clk_I or posedge RstP_I) begin
	if(RstP_I)
		SCKEdgeCnt <= 7'd0;
	else begin
		case(MainState)
			RUNNING: begin
				if(SCKEdge1 || SCKEdge2)		/* 统计两个时钟边沿数量 */
					SCKEdgeCnt <= SCKEdgeCnt + 1'b1;
				else
					SCKEdgeCnt <= SCKEdgeCnt;
			end
			default: SCKEdgeCnt <= 7'd0;
		endcase
	end
end

/* 接收完成标志 */
assign	RecvDoneFlag = (SCKEdgeCnt == DATA_WIDTH * 2);
/* 数据接收完成时输出一个时钟宽度的脉冲信号 */
assign DataValid_O = (MainState == DELIVER) ? 1'b1 : 1'b0;
/* 读取到的数据 */
assign Data_O = RdDataLatch;
/* 模块忙信号 */
assign Busy_O = (MainState == IDLE) ? 1'b0 : 1'b1;
/* 将要发送的数据发送到MOSI线上 */
assign MOSI_O = (MainState == RUNNING) ? WrDataLatch[DATA_WIDTH - 1] : 1'bz;

/* 片选 */
assign	CS_O = (MainState == RUNNING) ? 1'b0 : 1'b1;

/* SPI时钟使能信号 */
assign	SCKEnable = (MainState == RUNNING) ? 1'b1 : 1'b0;


endmodule
 
