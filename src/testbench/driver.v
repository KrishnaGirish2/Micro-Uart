module driver#(parameter D=8);

	reg xmitH;
	reg[D-1:0]xmit_dataH;

	task reset(); 
		begin
			xmitH=0;
			xmit_dataH=0;
		end
	endtask

	task transmit(input[D-1:0]data);
		begin

			wait(uart_top_tb.xmit_active==0);

			@(posedge uart_top_tb.REF_MODEL.baud_clk);

			xmit_dataH=data;
			xmitH=1'b1;

			@(posedge uart_top_tb.REF_MODEL.baud_clk);

			xmitH=1'b0;

		end
	endtask

endmodule
