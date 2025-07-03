module baudgenerator(pclk,presetn,spimode,spiswai,sppr,spr,cpol,cpha,ss,sclk,flaglow,flaghigh,flagslow,flagshigh,baudratedivisor);

input pclk,presetn,spiswai,cpol,cpha,ss;
input [1:0]spimode;
input [2:0]sppr;
input [2:0]spr;
output reg sclk,flaglow,flaghigh,flagslow,flagshigh;
output [11:0]baudratedivisor;
wire temp;
wire presclk,dflaglow,dflaghigh,dflagslow,dflagshigh;
reg [11:0]count;
wire [11:0]dcount;
wire dsclk;
assign baudratedivisor=(sppr+1)*2**(spr+1);
assign temp=(((spimode==2'b00)|(spimode==2'b01))&(~ss)&(~spiswai));
assign temp1=((~cpha)&(cpol))|((cpha)&(~cpol));
assign presclk=1'b0;
assign dcount=(temp)?((count==(baudratedivisor-2'b01))?12'b0:(count+1'b1)):12'b0;
assign dsclk=(temp)?((count==(baudratedivisor-2'b01))?(~sclk):sclk):presclk;
assign dflaglow=(temp1)?flaglow:(sclk?(1'b0):((count==(baudratedivisor-2'b01))?1'b1:1'b0));
assign dflagslow=(temp1)?flagslow:(~sclk?(1'b0):((count==(baudratedivisor-2'b10))?1'b1:1'b0));

assign dflaghigh=(temp1)?(sclk?((count==(baudratedivisor-2'b01))?1'b1:1'b0):(1'b0)):flaghigh;
assign dflagshigh=(temp1)?(~sclk?((count==(baudratedivisor-2'b10))?1'b1:1'b0):(1'b0)):flagshigh;


always@(posedge pclk)
begin
 if(~presetn) begin count<=12'b0; end
 else begin count<=dcount; end
end

always@(posedge pclk)
begin
 if(~presetn) begin sclk<=presclk; end
 else begin sclk<=dsclk; end
end

always@(posedge pclk)
begin
 if(~presetn) begin flaglow<=1'b0; end
 else begin flaglow<=dflaglow; end
end

always@(posedge pclk)
begin
 if(~presetn) begin flagslow<=1'b0; end
 else begin flagslow<=dflagslow; end
end

always@(posedge pclk)
begin
 if(~presetn) begin flaghigh<=1'b0; end
 else begin flaghigh<=dflaghigh; end
end

always@(posedge pclk)
begin
 if(~presetn) begin flagshigh<=1'b0; end
 else begin flagshigh<=dflagshigh; end
end
endmodule