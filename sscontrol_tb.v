module sscontrol_tb();
reg pclk,presetn,mstr,spiswai,senddata;
reg [1:0]spimode;
wire [15:0]target;
reg [11:0]baudratedivisor;
wire receivedata;
wire ss;
wire tip;
wire [15:0]cnt;
sscontrol dut(.pclk(pclk),.presetn(presetn),.mstr(mstr),.spiswai(spiswai),.spimode(spimode),.senddata(senddata),.baudratedivisor(baudratedivisor),.target(target),.receivedata(receivedata),.ss(ss),.tip(tip),.count(cnt));
initial
begin
 pclk=0;
 forever 
    #5 pclk=~pclk;
end

initial
begin
  presetn=1'b0;
  #10;
  presetn=1'b1;
  mstr=1'b1;
  spiswai=1'b0;
  senddata=1'b1;
  spimode=2'b00;
  baudratedivisor=12'd2;
  #10;
  senddata=1'b0;
  #350;
end
initial
 #500 $finish;
endmodule