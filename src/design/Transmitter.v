`timescale 1ns/1ps
module tx#(parameter D=4'd8)(sys_rst_l,xmitH,xmit_dataH,baud_en,xmit_doneH,xmit_active,uart_XMIT_dataH);
  input wire sys_rst_l, xmitH;
  input wire [D-1:0]xmit_dataH;
  input wire baud_en;
  output reg xmit_doneH, xmit_active;
  output reg uart_XMIT_dataH;
  reg [$clog2(D)-1:0] count;

  parameter IDLE=2'b00, START=2'b01, DATA=2'b10, STOP=2'b11;
  reg [1:0] ct_st, nt_st;
  reg [D-1:0] shift_reg;

  always @(posedge baud_en or negedge sys_rst_l) begin
    if( !sys_rst_l) begin
      ct_st<=IDLE;
    end
    else
      ct_st<=nt_st;
    end

  always @(*) begin
    case(ct_st)
      IDLE: begin
        if(xmitH) begin
          nt_st=START;
        end
        else
          nt_st=IDLE;
      end

      START: begin
        nt_st=DATA;
      end

      DATA: begin
        if(count==D-1) 
          nt_st=STOP;
        else
          nt_st=DATA;
      end

      STOP: begin
	      if(!xmitH)
		      nt_st=IDLE;
	      else
		      nt_st=START;
      end

      default: begin
        nt_st=IDLE;
      end
    endcase
  end

  always @(posedge baud_en or negedge sys_rst_l) begin
    if(!sys_rst_l) begin
      count<=0;
      shift_reg<=0;
    end
    else if((xmitH && ct_st==IDLE) || (ct_st==STOP && xmitH)) begin
      shift_reg<=xmit_dataH;
      count<=0;
    end

    else if( ct_st==DATA) begin
      shift_reg<=shift_reg>>1;
      if(count==D-1)
        count<=0;
      else
        count<=count+1;
    end
  end

  always @(posedge baud_en or negedge sys_rst_l) begin
    if(!sys_rst_l) 
      xmit_doneH<=0;
    else if(ct_st==STOP) 
      xmit_doneH<=1;
    else
      xmit_doneH<=0;
  end

  always @(*) begin
    case(ct_st)
      IDLE: begin
        xmit_active=0;
        uart_XMIT_dataH=1;
      end
      START: begin
        xmit_active=1;
        uart_XMIT_dataH=0;
      end
      DATA: begin
        xmit_active=1;
        uart_XMIT_dataH=shift_reg[0];
      end
      STOP: begin
        xmit_active=1;
        uart_XMIT_dataH=1;
      end

      default: begin
        xmit_active=0;
        uart_XMIT_dataH=1;
      end
    endcase
  end
endmodule
