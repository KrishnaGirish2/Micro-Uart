module uart_top_tb;

	parameter DATA_WIDTH=8;
	parameter clk_freq=50_000_000;
	parameter baud_rate=2400;

	reg sys_clk,sys_rst_l;
	wire xmitH;
	wire[DATA_WIDTH-1:0]xmit_dataH;
	wire xmit_active,xmit_doneH,uart_XMIT_dataH,rec_readyH,rec_busy;
	wire[DATA_WIDTH-1:0]rec_dataH,ref_xmit_active,ref_xmit_doneH,ref_uart_XMIT_dataH,ref_rec_readyH,ref_rec_busy;
	wire[DATA_WIDTH-1:0]ref_rec_dataH;
	wire baud_clk_dbg;
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
	top_uart#(DATA_WIDTH,clk_freq,baud_rate)     DUT(.baud_clk_dbg(baud_clk_dbg),.sys_clk(sys_clk),.sys_rst_l(sys_rst_l),.xmitH(xmitH),.xmit_dataH(xmit_dataH),.xmit_active(xmit_active),.xmit_doneH(xmit_doneH),.uart_XMIT_dataH(uart_XMIT_dataH),      .uart_REC_dataH(uart_XMIT_dataH),.rec_readyH(rec_readyH),.rec_busy(rec_busy),.rec_dataH(rec_dataH));

	ref_model#(DATA_WIDTH,clk_freq,baud_rate)REF_MODEL(.sys_clk(sys_clk),.baud_clk(baud_clk_dbg),.sys_rst_l(sys_rst_l),.xmitH(xmitH),.xmit_dataH(xmit_dataH),.uart_REC_dataH(uart_XMIT_dataH),      .xmit_active(ref_xmit_active),.xmit_doneH(ref_xmit_doneH),.uart_XMIT_dataH(ref_uart_XMIT_dataH),.rec_readyH(ref_rec_readyH),.rec_busy(ref_rec_busy),.rec_dataH(ref_rec_dataH));

	initial begin
		wait(sys_rst_l);
		drv.transmit(8'hAA);
		repeat(250) @(posedge REF_MODEL.baud_clk);
		sb.check_data(rec_dataH, ref_rec_dataH);
		drv.transmit(8'hFF);
		repeat(250) @(posedge REF_MODEL.baud_clk);
		sb.check_data(rec_dataH, ref_rec_dataH);
		drv.transmit(8'h00);
		repeat(250) @(posedge REF_MODEL.baud_clk);
		sb.check_data(rec_dataH, ref_rec_dataH);
		drv.transmit(8'hD3);
		repeat(250) @(posedge REF_MODEL.baud_clk);
		sb.check_data(rec_dataH, ref_rec_dataH);
		drv.transmit(8'h55);
		repeat(250) @(posedge REF_MODEL.baud_clk);
		sb.check_data(rec_dataH, ref_rec_dataH);
		drv.transmit(8'hA5);
		repeat(250) @(posedge REF_MODEL.baud_clk);
		sb.check_data(rec_dataH, ref_rec_dataH);
		$display("PASS COUNT = %0d", sb.pass_count);
		$display("FAIL COUNT = %0d", sb.fail_count);
		drv.transmit(8'hFF);
		wait(rec_readyH);
		repeat(50) @(posedge uart_top_tb.REF_MODEL.baud_clk);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'h00);
		wait(rec_readyH);
		repeat(50) @(posedge uart_top_tb.REF_MODEL.baud_clk);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'hD3);
		wait(rec_readyH);
		repeat(50) @(posedge uart_top_tb.REF_MODEL.baud_clk);
		repeat(50) @(posedge uart_top_tb.REF_MODEL.baud_clk);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'h33);
		wait(rec_readyH);
		repeat(50) @(posedge uart_top_tb.REF_MODEL.baud_clk);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'h55);
		wait(rec_readyH);
		repeat(50) @(posedge uart_top_tb.REF_MODEL.baud_clk);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'h01);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'h80);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'hF0);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'h0F);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'hA5);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'h5A);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'hFE);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		drv.transmit(8'h7F);
		wait(rec_readyH);
		sb.check_data(rec_dataH,ref_rec_dataH);
		force DUT.rx1.rx_sync2 = 0;
		@(posedge DUT.b1.baud_clk);
		force DUT.rx1.rx_sync2 = 1;
		@(posedge DUT.b1.baud_clk);
		release DUT.rx1.rx_sync2;
		drv.transmit(8'hAA);
		#1000;
		sys_rst_l = 0;
		#200;
		sys_rst_l = 1;
		wait(rec_readyH);
		#100000000;
		$finish;
	end
endmodule

