`timescale 1ns / 1ps
// *******************************************************
// SPI_Master V1.0
// xiaoshe from TIQC
// *******************************************************
//����˵����
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
	output      SCKEdge1_O,		    /* ʱ�ӵĵ�һ�������� */
	output      SCKEdge2_O			/* ʱ�ӵĵڶ��������� */
);

/* SPIʱ��˵����1����CPOL=1ʱ��SCK�ڿ���ʱ��Ϊ�͵�ƽ����һ������Ϊ������
				2����CPOL=0ʱ��SCK�ڿ���ʱΪ�ߵ�ƽ����һ������Ϊ�½���
*/
/* ʱ�ӷ�Ƶ������ */
localparam	CLK_DIV_CNT = (CLK_FREQ * 1000)/SPI_CLK_FREQ;
reg         SCK;
reg         SCK_Pdg, SCK_Ndg;
reg[31:0]	ClkDivCnt;
/* ʱ�ӷ�Ƶ���������ƿ� */
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
/* SCK���ƿ� */
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
/* SCK�����ؼ��� */
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
 
/* SCK�½��ؼ��� */
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
/* ����CPOL��ѡ�������� */
assign SCKEdge1_O = (CPOL) ? SCK_Ndg : SCK_Pdg;
assign SCKEdge2_O = (CPOL) ? SCK_Pdg : SCK_Ndg;
assign SCK_O = SCK;
endmodule


module SPI_Master#
(
	parameter	CLK_FREQ = 100,			/* ģ��ʱ�����룬��λΪMHz */
	parameter	SPI_CLK = 1000,		    /* SPIʱ��Ƶ�ʣ���λΪKHz */
	parameter	CPOL = 0,				/* SPIʱ�Ӽ��Կ��� */
	parameter	CPHA = 0,				/* SPIʱ����λ���� */
	
	parameter	DATA_WIDTH = 24			/* ���ݿ�� */
)
(
	input       Clk_I,			/* ģ��ʱ�����룬Ӧ��CLK_FREQһ�� */
	input       RstP_I,			/* ͬ����λ�źţ��͵�ƽ��Ч */
	
	input       WrRdReq_I,		                        /* ��/д�������� */	
	input       [DATA_WIDTH - 1:0]      Data_I,		    /* Ҫд������� */
	output      [DATA_WIDTH - 1:0]      Data_O,		    /* ��ȡ�������� */
	output	    DataValid_O,	                        /* ��ȡ������Ч����������Ч */
	output 	    Busy_O,			                        /* ģ��æ�ź� */
    
	output	    SCK_O,			/* SPIģ��ʱ����� */
	output	    MOSI_O,			/* MOSI_O */
	input	    MISO_I,			/* MISO_I  */
	output		CS_O
);
 
localparam	    IDLE 	= 0;		/* ģ����� */
localparam	    START	= 1;
localparam	    RUNNING	= 2;		/* ģ�������� */
localparam	    DELIVER	= 3;		/* ����ת�� */
 
 
reg[7:0]        MainState, NxtMainState;
wire	        SCKEdge1, SCKEdge2;
wire 	        SCKEnable;
wire			RecvDoneFlag;
reg[7:0]	    SCKEdgeCnt;
 
 
reg[DATA_WIDTH - 1:0]	    WrDataLatch;
reg[DATA_WIDTH - 1:0]	    RdDataLatch;
 
/* ��д�ź������ؼ�� */
wire 	        WrRdReq_Pdg;					
reg 	        WrRdReq_D0, WrRdReq_D1;
 
/* ʵ����һ��SPIʱ��ģ�� */
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
 
/* ���д����������� */
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
 
/* ��״̬�� */
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
 
 
/* �������ݿ��ƿ� */
always@(posedge Clk_I or posedge RstP_I) begin
    if(RstP_I)
        WrDataLatch <= 0;
    else begin
        case(MainState)
            START: WrDataLatch <= Data_I;	/* �ȱ�����Ҫ���͵����� */
            RUNNING: begin
                /* ���CPHA=1������ʱ�ӵĵ�һ����������������ڵڶ���������� */
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
 
/* �������ݿ��ƿ� */
always@(posedge Clk_I or posedge RstP_I) begin
    if(RstP_I)
        RdDataLatch <= 0;
    else begin
        case(MainState)
            START: RdDataLatch <= 0;
            RUNNING: begin
                /* ���CPHA = 1������ʱ�ӵ�ÿ�������ض����ݽ��в�����
                   �����ڵ�һ�����ز��� */
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
 
/* ʱ�ӱ��ؼ����� */
always@(posedge Clk_I or posedge RstP_I) begin
	if(RstP_I)
		SCKEdgeCnt <= 7'd0;
	else begin
		case(MainState)
			RUNNING: begin
				if(SCKEdge1 || SCKEdge2)		/* ͳ������ʱ�ӱ������� */
					SCKEdgeCnt <= SCKEdgeCnt + 1'b1;
				else
					SCKEdgeCnt <= SCKEdgeCnt;
			end
			default: SCKEdgeCnt <= 7'd0;
		endcase
	end
end

/* ������ɱ�־ */
assign	RecvDoneFlag = (SCKEdgeCnt == DATA_WIDTH * 2);
/* ���ݽ������ʱ���һ��ʱ�ӿ�ȵ������ź� */
assign DataValid_O = (MainState == DELIVER) ? 1'b1 : 1'b0;
/* ��ȡ�������� */
assign Data_O = RdDataLatch;
/* ģ��æ�ź� */
assign Busy_O = (MainState == IDLE) ? 1'b0 : 1'b1;
/* ��Ҫ���͵����ݷ��͵�MOSI���� */
assign MOSI_O = (MainState == RUNNING) ? WrDataLatch[DATA_WIDTH - 1] : 1'bz;

/* Ƭѡ */
assign	CS_O = (MainState == RUNNING) ? 1'b0 : 1'b1;

/* SPIʱ��ʹ���ź� */
assign	SCKEnable = (MainState == RUNNING) ? 1'b1 : 1'b0;


endmodule
 
