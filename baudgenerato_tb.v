module baudgenerator_tb();
reg pclk,presetn,spiswai,cpol,cpha,ss;
reg [1:0]spimode;
reg [2:0]sppr;
reg [2:0]spr;
wire sclk,flaglow,flaghigh,flagslow,flagshigh;
wire [11:0]baudratedivisor;
wire clk;
baudgenerator dut(.pclk(pclk),.presetn(presetn),.spimode(spimode),.spiswai(spiswai),.sppr(sppr),.spr(spr),.cpol(cpol),.cpha(cpha),.ss(ss),.sclk(sclk),.flaglow(flaglow),.flaghigh(flaghigh),.flagslow(flagslow),.flagshigh(flagshigh),.baudratedivisor(baudratedivisor));
assign clk=pclk;
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
 cpol<=1'b0;
 cpha<=1'b0;
 spiswai<=1'b0;
 ss<=1'b0;
 sppr<=3'b000;
 spr<=3'b0;
 spimode<=2'b00;
end
initial
begin
 #200 $finish;
end

endmodule