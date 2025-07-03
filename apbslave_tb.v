module apbslave_tb();

reg pclk,presetn,pwrite,psel,penable,ss,receivedata,tip;
reg [2:0]paddr;
reg [7:0]pwdata;
reg [7:0]misodata;
wire [7:0]prdata;
wire spiintr_req;
wire cpol,cpha,mstr,lsbfe,spiswai;
wire pready,pslverr;
wire senddata;
wire [7:0]mosidata;
wire [1:0]spimode;
wire [2:0]sppr;
wire [2:0]spr;
wire [1:0] state;
wire spe;
apbslave dut(.pclk(pclk),.presetn(presetn),.paddr(paddr),.pwrite(pwrite),.psel(psel),.penable(penable),.pwdata(pwdata),.ss(ss),.misodata(misodata),.receivedata(receivedata),.tip(tip),.prdata(prdata),.mstr(mstr),.cpol(cpol),.cpha(cpha),.lsbfe(lsbfe),.spiswai(spiswai),.sppr(sppr),.spr(spr),.spiintr_req(spiintr_req),.pready(pready),.pslverr(pslverr),.senddata(senddata),.mosidata(mosidata),.spimode(spimode),.state(state),.spe(spe));

initial
begin
pclk=0;
forever 
  #2 pclk=~pclk;
end

initial
begin
presetn=1'b0;
#5;
presetn=1'b1;
end

initial
begin
psel=1'b0;
penable=1'b0;
#10;
psel=1'b1;
#10;
penable=1'b1;
end

initial
begin
 misodata=8'b0;
 receivedata=1'b0;
 #20;
 pwrite=1'b1;
 paddr=3'b000;
 pwdata=8'b11111111;
 #20;
 paddr=3'b001;
 pwdata=8'b00010000;
 #10;
 paddr=3'b010;
 pwdata=8'b0;
 #10;
 paddr=3'b101;
 pwdata=8'd70;
 #20;
 pwdata=8'b0;
 pwrite=1'b0;
 paddr=3'b011; 
 #20;
 paddr=3'b101;
 #20;
 receivedata=1'b1;
 misodata=8'd75;
 #20;
end

initial
#140 $finish;

endmodule