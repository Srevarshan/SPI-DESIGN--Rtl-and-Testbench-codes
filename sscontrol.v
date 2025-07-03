module sscontrol(pclk,presetn,mstr,spiswai,spimode,senddata,baudratedivisor,target,receivedata,ss,tip,count);
input pclk,presetn,mstr,spiswai,senddata;
input [1:0]spimode;
input [11:0]baudratedivisor;
output reg receivedata;
output reg ss;
output tip;
wire drcv;
wire dss;
output [15:0]target;
wire [15:0]dcnt;
output reg [15:0]count;
assign tip=(~ss);
assign drcv=(mstr&(~spiswai)&((spimode==2'b01)|(spimode==2'b00)))?((senddata==1'b1)?(1'b0):(((count<(target-1'b1))|(count==(target-1'b1)))?((count==(target-1'b1))?(1'b1):(receivedata)):(1'b0))):(1'b0);
assign dss=(mstr&(~spiswai)&((spimode==2'b01)|(spimode==2'b00)))?((senddata==1'b1)?(1'b0):(((count<(target-1'b1))|(count==(target-1'b1)))?(1'b0):(1'b1))):(1'b1);
assign dcnt=(mstr&(~spiswai)&((spimode==2'b01)|(spimode==2'b00)))?((senddata==1'b1)?(16'b0):((count<(target-1'b1))?(count+1'b1):(16'h0000))):(16'h0000);
assign target=baudratedivisor*16;

always@(posedge pclk)
begin
 if(~presetn)
     receivedata<=1'b0;
 else
     receivedata<=drcv;
end
always@(posedge pclk)
begin
 if(~presetn)
     ss<=1'b1;
 else
     ss<=dss;
end
always@(posedge pclk)
begin
 if(~presetn)
     count<=16'hffff;
 else
     count<=dcnt;
end

endmodule