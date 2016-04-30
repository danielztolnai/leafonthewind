`timescale 1ns / 1ps

module vga(
	input clk,
	input rst,
	input en,
	output [1:0] red,
	output [1:0] green,
	output [1:0] blue,
	output hsync,
	output vsync,
   
   output [10:0] nextH,
   output [ 9:0] nextV,
   output        nextActive,
   input  [ 5:0] pixel
);

// Parameters
parameter H_ACTIVE = 800;
parameter H_FRONT  =  56;
parameter H_SYNC   = 120;
parameter H_BACK   =  64;
parameter H_SIZE   = H_ACTIVE + H_FRONT + H_SYNC + H_BACK;

parameter V_ACTIVE = 600;
parameter V_FRONT  =  37;
parameter V_SYNC   =   6;
parameter V_BACK   =  23;
parameter V_SIZE   = V_ACTIVE + V_FRONT + V_SYNC + V_BACK;

// Horizontal pixel counter
reg [10:0] cntr_h; // Horizontal pixel counter
wire   cntr_hmaxed;
assign cntr_hmaxed = ( cntr_h == H_SIZE-1 );
assign nextH = (cntr_hmaxed) ? 11'b0 : (cntr_h + 1'b1);

always @ (posedge clk)
begin
   if(rst)
		cntr_h <= 0;
	else if(cntr_hmaxed)
		cntr_h <= 0;
	else if(en)
      cntr_h <= cntr_h + 1'b1;
end

// Vertical pixel counter
reg [9:0] cntr_v; // Vertical pixel counter
wire   cntr_vmaxed;
assign cntr_vmaxed = ( cntr_v == V_SIZE-1 );
assign nextV = (cntr_vmaxed) ? 10'b0 : (cntr_v + 1'b1);

always @ (posedge clk)
begin
   if(rst)
      cntr_v <= 0;
	else if(cntr_vmaxed)
	   cntr_v <= 0;
   else if(cntr_hmaxed)
      cntr_v <= cntr_v + 1'b1;
end

// Horizontal sync
reg hsync_reg;
always @ (posedge clk)
begin
	if(rst)
		hsync_reg <= 0;
	else if( cntr_h == (H_ACTIVE+H_FRONT+H_SYNC-1) )
		hsync_reg <= 0;
   else if( cntr_h == (H_ACTIVE+H_FRONT-1) )
      hsync_reg <= 1;
end
assign hsync = hsync_reg;

// Vertical sync
reg vsync_reg;
always @ (posedge clk)
begin
	if(rst)
		vsync_reg <= 0;
   else if( (cntr_h == (H_SIZE-1)) & (cntr_v == (V_ACTIVE+V_FRONT+V_SYNC-1)) )
		vsync_reg <= 0;
   else if( (cntr_h == (H_SIZE-1)) & (cntr_v == (V_ACTIVE+V_FRONT-1)) )
      vsync_reg <= 1'b1;
end
assign vsync = vsync_reg;

// Output assignment
assign red   = (cntr_h < H_ACTIVE & cntr_v < V_ACTIVE) ? pixel[5:4] : 2'b0;
assign green = (cntr_h < H_ACTIVE & cntr_v < V_ACTIVE) ? pixel[3:2] : 2'b0;
assign blue  = (cntr_h < H_ACTIVE & cntr_v < V_ACTIVE) ? pixel[1:0] : 2'b0;

assign nextActive = ( (nextH < H_ACTIVE) & (nextV < V_ACTIVE) );

endmodule
