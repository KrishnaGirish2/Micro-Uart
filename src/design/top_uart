`timescale 1ns/1ps
`default_nettype none
module top_uart #(parameter D=8, parameter value=20833, parameter value16=1302) (sys_clk,sys_rst_l,xmitH,xmit_dataH,rec_dataH,rec_readyH,rec_busy,uart_XMIT_dataH,xmit_doneH,xmit_active);
  input wire sys_clk, sys_rst_l, xmitH;
  input wire [D-1:0] xmit_dataH;

  output wire uart_XMIT_dataH, xmit_doneH, xmit_active;
  output wire [D-1:0] rec_dataH;
  output wire rec_readyH, rec_busy;
  wire baud_en, uart_bit;
  wire baud_rx;
  baud #(value) B1 (.sys_rst_l(sys_rst_l),.sys_clk(sys_clk),.baud_en(baud_en));
  baud_16 #(value16) B2(.sys_rst_l(sys_rst_l),.sys_clk(sys_clk),.baud_rx(baud_rx));
  tx #(D) T1 (.sys_rst_l(sys_rst_l),.xmitH(xmitH),.xmit_dataH(xmit_dataH),.baud_en(baud_en),.xmit_doneH(xmit_doneH),.xmit_active(xmit_active),.uart_XMIT_dataH(uart_bit));
  rx #(D)R1(.sys_rst_l(sys_rst_l),.baud_rx(baud_rx),.uart_REC_dataH(uart_bit),.rec_readyH(rec_readyH),.rec_dataH(rec_dataH),.rec_busy(rec_busy));
  assign uart_XMIT_dataH=uart_bit;
endmodule 

