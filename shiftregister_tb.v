module shiftregister_tb();
reg pclk,presetn,ss,senddata,lsbfe,cpha,cpol;
wire flaglow,flaghigh,flagslow,flagshigh;//
reg [7:0]mosidata;//
reg miso,receivedata;//
wire mosi;
wire [7:0]misodata;
reg spiswai;
reg [1:0]spimode;
reg [2:0]sppr;
reg [2:0]spr;
wire sclk;
wire [2:0]count;
wire [2:0]count1;
wire [2:0]count2;
wire [2:0]count3;
wire [11:0]baudratedivisor;
reg [7:0]register1;
integer i;
shiftregister dut(.pclk(pclk),.presetn(presetn),.ss(ss),.senddata(senddata),.lsbfe(lsbfe),.cpha(cpha),.cpol(cpol),.flaglow(flaglow),.flaghigh(flaghigh),.flagslow(flagslow),.flagshigh(flagshigh),.mosidata(mosidata),.miso(miso),.receivedata(receivedata),.mosi(mosi),.misodata(misodata),.count(count),.count1(count1),.count2(count2),.count3(count3));

baudgenerator dut1(.pclk(pclk),.presetn(presetn),.spimode(spimode),.spiswai(spiswai),.sppr(sppr),.spr(spr),.cpol(cpol),.cpha(cpha),.ss(ss),.sclk(sclk),.flaglow(flaglow),.flaghigh(flaghigh),.flagslow(flagslow),.flagshigh(flagshigh),.baudratedivisor(baudratedivisor));

initial 
begin
 pclk=0;
 forever 
    #5 pclk=~pclk;
end
initial
begin
  presetn=1'b0;
  #8;
  presetn=1'b1;
end

initial
begin
 cpol=1'b1;
 cpha=1'b0;
 spiswai=1'b0;
 ss=1'b0;
 sppr=3'b000;
 spr=3'b0;
 spimode=2'b00;
 senddata=1'b1;
 lsbfe=1'b1;
 mosidata=8'd70;
end
initial
begin
 receivedata=1'b1;
 register1=8'b01000110;
 for(i=0;i<=7;i=i+1)
   begin
     @(negedge sclk)
      miso=register1[i];
   end
 
end

initial
begin
 #400 $finish;
end



endmodule