module uart_top_tb;

	parameter DATA_WIDTH=8;
	parameter clk_freq=50_000_000;
	parameter baud_rate=2400;

	reg sys_clk;
	reg sys_rst_l;

	wire xmitH;
	wire[DATA_WIDTH-1:0]xmit_dataH;

	wire xmit_active;
	wire xmit_doneH;
	wire uart_XMIT_dataH;

	wire rec_readyH;
	wire rec_busy;
	wire[DATA_WIDTH-1:0]rec_dataH;

	wire ref_xmit_active;
	wire ref_xmit_doneH;
	wire ref_uart_XMIT_dataH;

	wire ref_rec_readyH;
	wire ref_rec_busy;
	wire[DATA_WIDTH-1:0]ref_rec_dataH;

	driver#(DATA_WIDTH)drv();

	scoreboard#(DATA_WIDTH)sb();

	assign xmitH=drv.xmitH;
	assign xmit_dataH=drv.xmit_dataH;

	initial begin

		sys_clk=0;

		forever #10 sys_clk=~sys_clk;

	end

	initial begin

		sys_rst_l=0;

		drv.reset();

		#200;

		sys_rst_l=1;

	end

	top#(DATA_WIDTH,clk_freq,baud_rate) 	DUT(.sys_clk(sys_clk),.sys_rst_l(sys_rst_l),.xmitH(xmitH),.xmit_dataH(xmit_dataH),.xmit_active(xmit_active),.xmit_doneH(xmit_doneH),.uart_XMIT_dataH(uart_XMIT_dataH),
	.uart_REC_dataH(uart_XMIT_dataH),.rec_readyH(rec_readyH),.rec_busy(rec_busy),.rec_dataH(rec_dataH));

	ref_model#(DATA_WIDTH,clk_freq,baud_rate)REF_MODEL(.sys_clk(sys_clk),.sys_rst_l(sys_rst_l),.xmitH(xmitH),.xmit_dataH(xmit_dataH),.uart_REC_dataH(uart_XMIT_dataH),	.xmit_active(ref_xmit_active),.xmit_doneH(ref_xmit_doneH),.uart_XMIT_dataH(ref_uart_XMIT_dataH),.rec_readyH(ref_rec_readyH),.rec_busy(ref_rec_busy),.rec_dataH(ref_rec_dataH));

	initial begin

		wait(sys_rst_l);
		drv.transmit(8'hAA);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'hFF);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'h00);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'hD3);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'h33);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'h55);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		
		#100000000;
		$finish;
	end

endmodule
