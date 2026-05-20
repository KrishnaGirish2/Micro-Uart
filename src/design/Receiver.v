`timescale 1ns/1ps
`default_nettype none
module rx #(parameter D=8)(sys_rst_l,uart_REC_dataH,baud_rx,rec_dataH,rec_readyH,rec_busy);
  input wire sys_rst_l,uart_REC_dataH;
  input wire baud_rx;
  output reg [D-1:0] rec_dataH;
  output reg rec_readyH, rec_busy;

  parameter IDLE=2'b00, START=2'b01, DATA=2'b10, STOP=2'b11;

  reg [1:0]ct_st, nt_st;
  reg [$clog2(D)-1:0]count;
  reg [D-1:0]shift_reg;
  reg [3:0] sample_count;
  reg uart_sync1, uart_sync2;

  always @(posedge baud_rx) begin
    uart_sync1<=uart_REC_dataH;
    uart_sync2<=uart_sync1;
  end

  always @(posedge baud_rx or negedge sys_rst_l) begin
    if(!sys_rst_l) begin
      ct_st<=IDLE;
    end
    else
      ct_st<=nt_st;
    end

  always @(*) begin
    case(ct_st) 
      IDLE: begin
        if(uart_sync2==1'b0) begin
          nt_st=START;
        end
        else
          nt_st=IDLE;
        end

        START: begin
          if(sample_count==4'd7) begin
            if(uart_sync2==1'b0) 
              nt_st=DATA;
            else 
              nt_st=IDLE;
          end
          else
            nt_st=START;
        end

        DATA: begin
          if(count==D-1 && sample_count==4'd7)
            nt_st=STOP;
          else
            nt_st=DATA;
        end

        STOP: begin
          if(sample_count==4'd7) begin
            if(uart_sync2)  
              nt_st=IDLE;
            else
              nt_st=STOP;
          end
          else
            nt_st=STOP;
        end

        default: begin
          nt_st=IDLE;
        end
      endcase
    end

  always @(posedge baud_rx or negedge sys_rst_l) begin
    if(!sys_rst_l) begin
      sample_count<=0;
    end
    else if(ct_st==IDLE) begin
      sample_count<=0;
    end
    else if(ct_st==START && sample_count==4'd7) begin
      sample_count<=0;
    end
    else if(sample_count==4'd15) 
      sample_count<=0;
    else
      sample_count<=sample_count+1;
    end

  always @(posedge baud_rx or negedge sys_rst_l) begin
    if(!sys_rst_l) begin
      count<=0;
      shift_reg<=0;
    end
    else if(ct_st==IDLE)
      count<=0;

    else if(ct_st==DATA && sample_count==4'd7) begin
      shift_reg<={uart_sync2,shift_reg[D-1:1]};
      if(count==D-1)
        count<=0;
      else
        count<=count+1;
    end
  end

  always @(posedge baud_rx or negedge sys_rst_l) begin
    if(!sys_rst_l) begin
      rec_dataH<=0;
    end
    else if(ct_st==STOP && sample_count==4'd7)
      rec_dataH<=shift_reg;
    end

  always @(posedge baud_rx or negedge sys_rst_l) begin
    if(!sys_rst_l) 
      rec_readyH<=0;
    else if(ct_st==STOP  && uart_sync2 && sample_count==4'd7)
      rec_readyH<=1;
    else
      rec_readyH<=0;
  end

  always @(*) begin
    case(ct_st) 
      IDLE: begin
        rec_busy=0;
      end

      START: begin
        rec_busy=1;
      end

      DATA: begin
        rec_busy=1;
      end

      STOP: begin
        if(sample_count==4'd7)
          rec_busy=0;
        else
          rec_busy=1;
      end

      default: begin
        rec_busy=0;
      end
    endcase
  end
endmodule



