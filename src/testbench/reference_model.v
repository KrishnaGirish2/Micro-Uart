`timescale 1ns/1ps
`default_nettype none

module ref_model#(parameter DATA_WIDTH=8,parameter clk_freq=50_000_000,parameter baud_rate=2400)(input wire sys_clk,input wire sys_rst_l,
	input wire xmitH,input wire [DATA_WIDTH-1:0] xmit_dataH,input wire uart_REC_dataH,output reg xmit_active,output reg xmit_doneH,
	output reg uart_XMIT_dataH,output reg rec_readyH,output reg rec_busy,output reg [DATA_WIDTH-1:0] rec_dataH);

	localparam integer CLK_DIV=clk_freq/(baud_rate*16*2);
	reg baud_clk;
	reg [15:0]divider;
	always @(posedge sys_clk or negedge sys_rst_l) begin
		if(!sys_rst_l) begin
        		baud_clk<=0;
        		divider<=0;
    	end
	else begin
		if(divider==CLK_DIV-1) begin
			baud_clk<=~baud_clk;
			divider<=0;
		end
		else
			divider<=divider+ 1;
		end
	end

	integer i;
	reg [DATA_WIDTH-1:0]tx_data;

	always @(posedge baud_clk) begin
		@(posedge xmitH);
		uart_XMIT_dataH<=0;
		xmit_doneH<=0;
		xmit_active<=1;
		tx_data<=xmit_dataH;
		repeat(16) @(posedge baud_clk);
		for(i=0;i<DATA_WIDTH;i=i+1) begin
			uart_XMIT_dataH<=tx_data[0];
			tx_data<=tx_data>>1;
			repeat(16) @(posedge baud_clk);
		end

		uart_XMIT_dataH<=1;
		repeat(16) @(posedge baud_clk);
		xmit_doneH<=1;
		xmit_active<=0;
	end
	reg sync1;
	reg sync2;
	always @(posedge baud_clk or negedge sys_rst_l) begin
		if(!sys_rst_l) begin
			sync1<=1;
			sync2<=1;
		end
		else begin
		sync1<=uart_REC_dataH;
		sync2<=sync1;
		end
	end

	reg [DATA_WIDTH-1:0] rx_data;
	always @(posedge baud_clk) begin
		@(negedge sync2);
		rec_readyH<=0;
		rec_busy<=1;
		repeat(4) @(posedge baud_clk);
		if(sync2==0) begin
			for(i=0;i<DATA_WIDTH;i=i+1) begin
				repeat(16) @(posedge baud_clk);
				rx_data[i]<=sync2;
			end
		end
		repeat(16) @(posedge baud_clk);
		rec_dataH<=rx_data;
		rec_readyH<=1;
		rec_busy<=0;
	end
endmodule

                                                                                                                                                                           
                                                                                                                                                                     
