`timescale 1ns/1ps
`default_nettype none
module baud_16#(parameter value16=1302)(sys_clk,sys_rst_l,baud_rx);
  input wire sys_clk, sys_rst_l;
  output reg baud_rx;
  reg [11:0]divider;

  always @(posedge sys_clk or negedge sys_rst_l) begin
    if(!sys_rst_l) begin
      divider<=0;
      baud_rx<=0;
    end
    else begin
      if(divider==value16-1) begin
        divider<=0;
        baud_rx<=~baud_rx;
      end
      else begin
        divider<=divider+1;
        baud_rx<=baud_rx;
      end
    end
  end

endmodule
