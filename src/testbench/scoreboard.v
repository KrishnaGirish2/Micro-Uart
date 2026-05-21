module scoreboard#(parameter D=8);


	task check_data;

		input[D-1:0]dut_data;
		input[D-1:0]ref_data;

		begin

			@(posedge uart_top_tb.REF_MODEL.baud_clk);

				if(dut_data==ref_data) begin

					$display("PASS");
					$display("REF DATA=%h",ref_data);
					$display("DUT DATA=%h",dut_data);
					$display("TIME=%0t",$time);

				end

				else begin

					$display("FAIL");
					$display("REF DATA=%h",ref_data);
					$display("DUT DATA=%h",dut_data);
					$display("TIME=%0t",$time);

				end

		end
	endtask

endmodule
