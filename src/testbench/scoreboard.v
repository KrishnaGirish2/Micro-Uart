module scoreboard #(parameter D=8);

	integer pass_count;
	integer fail_count;

	initial begin
		pass_count=0;
		fail_count=0;
	end
	task check_data;

		input [D-1:0] dut_data;
		input [D-1:0] ref_data;
		begin
			if(dut_data==ref_data) begin
				pass_count=pass_count+1;
				$display("PASS");
				$display("REF DATA=%h", ref_data);
				$display("DUT DATA=%h", dut_data);
				$display("TIME=%0t", $time);
			end
			else begin
				fail_count=fail_count+1;
				$display("FAIL");
				$display("REF DATA=%h", ref_data);
				$display("DUT DATA=%h", dut_data);
				$display("TIME=%0t", $time);
			end
		end
	endtask
endmodule
