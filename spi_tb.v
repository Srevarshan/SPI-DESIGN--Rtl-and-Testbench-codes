module spi_tb();
reg pclk,presetn,pwrite,psel,penable,miso;
reg [2:0]paddr;
reg [7:0]pwdata;
wire ss,sclk,spiintr_req,mosi,pready,pslverr;
wire [7:0]prdata;
spi uut(pclk,presetn,paddr,pwrite,psel,penable,pwdata,miso,sclk,ss,spiintr_req,mosi,prdata,pready,pslverr);
integer i,j;
initial
begin
 pclk=0;
 forever 
   #5 pclk=~pclk;
end
task reset;
begin
  #10;
  presetn=1'b0;
  #10;
  presetn=1'b1;
end
endtask
task en;
begin
 #20;
 psel=1'b0;penable=1'b0;
 #10;
 psel=1'b1;
 #10;
 penable=1'b1;
 #10;
end
endtask
task misolsb(input [7:0]misodata1);
begin
  pwdata=misodata1;
  wait(~ss)
   for(i=0;i<8;i=i+1)
   begin
     @(negedge sclk)
     miso=misodata1[i];
   end
    @(negedge sclk)
     miso=1'b0;
end
endtask
task misomsb(input [7:0]misodata1);
begin
  pwdata=misodata1;
  wait(~ss)
   for(i=7;i>=0;i=i-1)
   begin
     @(negedge sclk)
     miso=misodata1[i];
   end
    @(negedge sclk)
     miso=1'b0;
end
endtask

task write_register(input [7:0]data,input [2:0]addr);
begin
 pwrite=1'b1;
 paddr=addr;
 pwdata=data;
 #10;
end
endtask

task sendmosi;
begin
 pwrite=1'b0;
 pwdata=8'b0;
 for(j=0;j<8;j=j+1)
 begin
  @(posedge sclk)
    #0;
 
 end
end
endtask

initial
begin
 reset;
 en;
 miso=1'b0;
 write_register(8'b11111011,3'b000);
 write_register(8'b11000001,3'b001);
 write_register(8'b00000000,3'b010);
 write_register(8'b01010101,3'b101);
 pwrite=1'b0;
 paddr=3'b101;
 #10;
 paddr=3'b011;
 #10;
end
initial
begin
 #345;
 pwrite=1'b1;
 pwdata=8'b11011010;
 paddr=3'b101;
 #20;
 pwrite=1'b0;
 #10;
 sendmosi();
 pwrite=1'b1;
 pwdata=8'b0;
 paddr=3'b101;
 #10;
 pwrite=1'b0;
 #40;
 misolsb(8'b11010101);
 $finish;
end 
initial
#1200 $finish;
endmodule