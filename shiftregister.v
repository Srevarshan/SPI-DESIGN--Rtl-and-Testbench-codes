module shiftregister(pclk,presetn,ss,senddata,lsbfe,cpha,cpol,flaglow,flaghigh,flagslow,flagshigh,mosidata,miso,receivedata,mosi,misodata,count,count1,count2,count3);
input pclk,presetn,ss,senddata,lsbfe,cpha,cpol,flaglow,flaghigh,flagslow,flagshigh;
input [7:0]mosidata;
input miso,receivedata;
output reg mosi;
output [7:0]misodata;
output reg [2:0]count;
output reg [2:0]count1;
output reg [2:0]count2;
output reg [2:0]count3;
reg [7:0]tempreg;
reg [7:0]shift_register;
wire temp,dtemp,tempout;
wire [2:0]tempcount;
wire [2:0]tempcount2;
wire [7:0]dtempshift;
wire dtempmosi;
assign temp=((~cpol)&cpha)|((~cpha)&cpol); 
assign tempout=(tempreg[count2])|(tempreg[count3]);
assign tempcount=({3{~ss}})&(temp?(lsbfe?(flagshigh?((count<=3'd7)?((count+1'b1)&({3{flagshigh}})):(3'd0)):(count)):(flagshigh?((count1>=3'd0)?((count1-1'b1)&({3{flagshigh}})):(3'd7)):(count1))):(lsbfe?(flagslow?((count<=3'd7)?((count+1'b1)&({3{flagslow}})):(3'd0)):(count)):(flagslow?((count1>=3'd0)?((count1-1'b1)&({3{flagslow}})):(3'd7)):(count1))));
assign tempcount2=({3{~ss}})&(temp?(lsbfe?(flaghigh?((count2<=3'd7)?((count2+1'b1)&({3{flaghigh}})):(3'd0)):(count2)):(flaghigh?((count3>=3'd0)?((count3-1'b1)&({3{flaghigh}})):(3'd7)):(count3))):(lsbfe?(flaglow?((count2<=3'd7)?((count2+1'b1)&({3{flaglow}})):(3'd0)):(count2)):(flaglow?((count3>=3'd0)?((count3-1'b1)&({3{flaglow}})):(3'd7)):(count3))));

assign dtemp=(~ss)&(temp?(lsbfe?((count2<=3'd7)?((miso)&(flaghigh)):(tempout)):((count3>=3'd0)?((miso)&(flaghigh)):(tempout))):(lsbfe?((count2<=3'd7)?((miso)&(flaglow)):(tempout)):((count3>=3'd0)?((miso)&(flaglow)):(tempout))));
assign misodata=(receivedata==1'b1)?tempreg:8'h00;
assign dtempshift=(senddata==1'b1)?mosidata:shift_register;
assign dtempmosi=(~ss)?((temp==1'b1)?((lsbfe==1)?((count<=3'd7)?((flagshigh==1)?(shift_register[count]):(mosi)):(mosi)):(mosi)):((count>=3'd0)?((flagshigh==1'b1)?(shift_register[count1]):(mosi)):(mosi))):mosi;

always@(posedge pclk)
begin
  if(~presetn) begin mosi<=1'b0; end
  else begin mosi<=dtempmosi; end
end

always@(posedge pclk)
begin
   if(~presetn)begin shift_register<=8'b0; end
   else begin shift_register<=dtempshift; end
end

always@(posedge pclk)
begin
 if(~presetn)
   begin
     count<=3'b0;
     count1<=3'b0;
   end
  else
    begin
       if(lsbfe) begin count<=tempcount; end
       else begin count1<=tempcount; end
    end
end

always@(posedge pclk)
begin
 if(~presetn)
   begin
     count2<=3'b0;
     count3<=3'b0;
   end
  else
    begin
       if(lsbfe) begin count2<=tempcount2; end
       else begin count3<=tempcount2; end
    end
end

always@(posedge pclk)
begin
 if(~presetn)
   begin
     tempreg<=8'b0;
   end
  else
    begin
       if(lsbfe) begin tempreg[count2]<=dtemp; end
       else begin tempreg[count3]<=dtemp; end
    end
end

endmodule

