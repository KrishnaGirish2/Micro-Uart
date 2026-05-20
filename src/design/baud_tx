`timescale 1ns/1ps
`default_nettype none
module baud#(parameter value=16'd20833)(sys_rst_l,sys_clk, baud_en);
  input wire sys_rst_l, sys_clk;
  output reg baud_en;
  reg [15:0] divider;

  always @(posedge sys_clk or negedge sys_rst_l) begin
    if(!sys_rst_l) begin
      divider<=0;
      baud_en<=0;
    end
    else begin
      if(divider==value-1) begin
        divider<=16'd0;
        baud_en<=~baud_en;
      end
      else begin
        divider<=divider+1;
        baud_en<=baud_en;
      end
    end
  end
endmodule

