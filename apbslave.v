module apbslave(pclk,presetn,paddr,pwrite,psel,penable,pwdata,ss,misodata,receivedata,
tip,prdata,mstr,cpol,cpha,lsbfe,spiswai,sppr,spr,spiintr_req,pready,pslverr,senddata,mosidata,spimode,state,spe);
reg [7:0]spicr1;
reg [7:0]spicr2;
reg [7:0]spisr;
reg [7:0]spibr;
reg [7:0]spidr;
input pclk,presetn,pwrite,psel,penable,ss,receivedata,tip;
input [2:0]paddr;
input [7:0]pwdata;
input [7:0]misodata;
output [7:0]prdata;
output spiintr_req;
output cpol,cpha,mstr,lsbfe,spiswai;
output pready,pslverr;
output reg senddata;
output reg[7:0]mosidata;
output reg [1:0]spimode;
wire temp=senddata;
wire [7:0]dcr1;
wire [7:0]dcr2;
wire [7:0]dbr;
wire [7:0]ddr;
wire dsend;
wire wrenb;
wire rdenb;
wire sptef;
wire spif;
output [2:0]sppr;
output [2:0]spr;
output spe;
wire modfen;
wire modf;
wire spie;
wire sptie;
wire ssoe;
parameter cr2mask=8'b00011011;
parameter brmask=8'b01110111;
wire spc0,bidiroe;
assign lsbfe=spicr1[0];
assign ssoe=spicr1[1];
assign cpha=spicr1[2];
assign cpol=spicr1[3];
assign mstr=spicr1[4];
assign sptie=spicr1[5];
assign spe=spicr1[6];
assign spie=spicr1[7];
assign spc0=spicr2[0];
assign spiswai=spicr2[1];
assign bidiroe=spicr2[3];
assign modfen=spicr2[4];
assign sppr=spibr[6:4];
assign spr=spibr[2:0];
parameter idle=2'b00,
	  setup=2'b01,
          enable=2'b10;
parameter spirun=2'b00,
          spiwait=2'b01,
          spistop=2'b10;
output reg [1:0]state;
reg [1:0]nextstate;
reg [1:0]nextmode;
assign prdata=(rdenb==0)?8'b0:((paddr==3'b000)?spicr1:((paddr==3'b001)?spicr2:((paddr==3'b010)?spibr:((paddr==3'b011)?spisr:spidr))));
assign pready=(state==enable)?1:0;
assign wrenb=((state==enable)&&(pwrite==1'b1))?1:0;
assign rdenb=((state==enable)&&(pwrite==1'b0))?1:0;
assign pslverr=(state==enable)?1:0;
assign sptef=(spidr==8'h00)?1:0;
assign spif=(spidr!=8'h00)?1:0;
assign modef=(~ss)&&mstr&&modfen&&(~ssoe);
assign spiintr_req=(~spie&&(~sptie))?1'b0:(spie&&(~sptie))?(spif||modf):((~spie&&sptie)?sptef:(spif||sptef||modf));

assign dcr2=(wrenb==1'b1)?((paddr==3'b001)?(pwdata&cr2mask):spicr2):spicr2;
assign dcr1=(wrenb==1'b1)?((paddr==3'b000)?pwdata:spicr1):spicr1;
assign dbr=(wrenb==1'b1)?((paddr==3'b010)?(pwdata&brmask):spibr):spibr;
assign ddr=(wrenb==1'b1)?((paddr==3'b101)?(pwdata):spidr):((spidr==pwdata)&(spidr!=misodata)&((spimode==spiwait)|(spimode==spirun)))?8'b0:((receivedata&((spimode==spiwait)|(spimode==spirun)))?misodata:spidr);
assign dsend=(wrenb==1'b1)?(senddata):((spidr==pwdata)&(spidr!=misodata)&((spimode==spiwait)|(spimode==spirun)))?(1'b1):((((spimode==spiwait)|(spimode==spirun))&receivedata)?1'b0:1'b0); 
assign modf=mstr&modfen&(~ss)&(~ssoe);
always@(posedge pclk)
begin
   spisr<=(presetn==0)?8'b00000000:{spif,1'b0,sptef,modf,4'b0};
end

always@(posedge pclk,negedge presetn)
begin
  if(~presetn)
        mosidata<=8'b0; 
  else if(((spidr==pwdata)&&(spidr!=misodata))&&((spimode==spirun)||(spimode==spiwait))&&(~wrenb))
        mosidata<=spidr; 
end

//fsm for spi state
always@(posedge pclk,negedge presetn)
begin
	if(~presetn) state<=idle; 
	else state<=nextstate; 
end

always@(psel,penable,state)
begin
   nextstate=idle;
   case(state)
       idle:
        begin 
            if(psel&(~penable))
                 nextstate=setup;
        end
       setup:
         begin
             if(psel&penable)
                  nextstate=enable;
             else if((psel)&(~penable))
                   nextstate=setup;
         end
       enable:
          begin
             if(psel&(~penable))
                  nextstate=setup;
             else if((psel)&(penable))
                   nextstate=enable;
          end
    endcase
end
     
//fsm for spi modes
always@(posedge pclk,negedge presetn)
begin
	if(~presetn) 
          spimode<=spirun; 
	else 
          spimode<=nextmode;
end

always@(spimode,spe,spiswai)
begin
  nextmode=spirun;
  case(spimode)
   spirun:
   begin 
        if(spe==1'b0) 
           nextmode=spiwait;
   end
   spiwait:
      begin
        if(spiswai==1'b1)
           nextmode=spistop; 
        else if((spe==1'b0)&(spiswai==1'b0))
           nextmode=spiwait;
      end
   spistop:
    begin
     if(spiswai==1'b0) 
         nextmode=spiwait; 
     else if(spiswai)
           nextmode=spistop;
    end
  endcase 
end  
//for spicr1 register
always@(posedge pclk)
begin
  if(~presetn) begin spicr1=8'h04; end
  else begin spicr1<=dcr1; end
end
//for spicr2 register
always@(posedge pclk)
begin
  if(~presetn) begin spicr2<=8'h00; end
  else begin spicr2<=dcr2; end
end
//for spibr register
always@(posedge pclk)
begin
  if(~presetn) begin spibr<=8'h00; end
  else begin spibr<=dbr; end
end
//for spidr register
always@(posedge pclk)
begin 
  if(~presetn) begin spidr<=8'b0; end
  else begin spidr<=ddr; end
end
     

//for senddata flag
always@(posedge pclk)
begin
  if(~presetn) begin senddata<=1'b0; end
  else begin senddata<=dsend; end
end 

endmodule