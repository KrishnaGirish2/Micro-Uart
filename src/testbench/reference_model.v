`timescale 1ns/1ps
`default_nettype none

module ref_model#
(parameter DATA_WIDTH=8,parameter clk_freq=50_000_000,parameter baud_rate=2400)(input wire sys_clk,input wire sys_rst_l,input wire baud_clk,input wire xmitH,input wire [DATA_WIDTH-1:0] xmit_dataH,input wire uart_REC_dataH,output reg xmit_active,output reg xmit_doneH,output reg uart_XMIT_dataH,output reg rec_readyH,output reg rec_busy,output reg [DATA_WIDTH-1:0] rec_dataH);

	localparam integer CLK_DIV = clk_freq/(baud_rate*16*2);
	initial begin
		xmit_doneH      = 1;
		xmit_active     = 0;
		uart_XMIT_dataH = 1'b1;
		rec_readyH      = 1;
		rec_busy        = 0;
		rec_dataH       = 0;
	end

	integer i;
	reg [DATA_WIDTH-1:0] tx_data;
	initial begin
		forever begin
			@(posedge xmitH);
			xmit_active = 1;
			xmit_doneH  = 0;
			tx_data = xmit_dataH;
			uart_XMIT_dataH = 0;
			repeat(16) @(posedge baud_clk);
			for(i=0;i<DATA_WIDTH;i=i+1) begin
				uart_XMIT_dataH = tx_data[i];
				repeat(16) @(posedge baud_clk);
			end

			uart_XMIT_dataH = 1;
			repeat(16) @(posedge baud_clk);
			xmit_active = 0;
			xmit_doneH  = 1;
		end
	end

	reg sync1;
	reg sync2;

	always @(posedge baud_clk or negedge sys_rst_l) begin
		if(!sys_rst_l) begin
			sync1 <= 1'b1;
			sync2 <= 1'b1;
		end
		else begin
			sync1 <= uart_REC_dataH;
			sync2 <= sync1;
		end
	end
	integer j;
	reg [DATA_WIDTH-1:0] rx_data;
	initial begin
		forever begin
			@(negedge sync2);
			rec_readyH = 0;
			rec_busy   = 1;
			repeat(8) @(posedge baud_clk);
			if(sync2 == 0) begin
				for(j=0;j<DATA_WIDTH;j=j+1) begin
					repeat(16) @(posedge baud_clk);
					rx_data[j] = sync2;
				end
				repeat(16) @(posedge baud_clk);
				rec_dataH = rx_data;
			end
			rec_busy   = 0;
			rec_readyH = 1;
		end
	end
endmodule
