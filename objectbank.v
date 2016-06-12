`timescale 1ns / 1ps

module objectbank(
   input clk,
   input shift_object_left,
   input shift_object_right,
   
   input  [10:0] cntr_h,
   input  [ 9:0] cntr_v,
   output [ 5:0] pixel,
   output gameOver
);

parameter BACKGROUND_COLOR = 6'b110000;
parameter OBJECT_BANK_SIZE = 16;
 
`define ObjectPositionH  9: 0	// Position on the screen (0-799)
`define ObjectPositionV 19:10 // Position on the screen (0-599)
`define ObjectExists       20 // Whether the object exists
`define ObjectBitmap    24:21 // The bitmap's address (Might be better to switch to "object types")
`define ObjectWidth        25 // Width in 16 pixel blocks
`define ObjectHeight       26 // Height in 16 pixel blocks
reg [26:0] ObjectsBank[OBJECT_BANK_SIZE-1:0];

integer k;
initial
begin
   ObjectsBank[0] = {1'b0, 1'b0, 4'b0000, 1'b1, 10'd550, 10'd100};
   ObjectsBank[1] = {1'b0, 1'b1, 4'b0100, 1'b1, 10'd10,  10'd10};
   ObjectsBank[2] = {1'b1, 1'b0, 4'b1000, 1'b1, 10'd80,  10'd400};
   ObjectsBank[3] = {1'b1, 1'b1, 4'b1100, 1'b1, 10'd300, 10'd200};
   for (k = 4; k < OBJECT_BANK_SIZE; k=k+1)
   begin
      ObjectsBank[k] = 27'b0;
   end
end

`define ObjectActive        0 // Object is on the current pixel
`define ObjectPixelH     5: 1 // Position within the object
`define ObjectPixelV    10: 6 // Position witihn the object
wire [10:0] ObjectsStatus[OBJECT_BANK_SIZE-1:0];

genvar i;
generate
   for (i=0; i < OBJECT_BANK_SIZE; i=i+1) 
   begin: GenerateObjectsStatus
   
      assign ObjectsStatus[i][`ObjectActive] =
         (cntr_v >= ObjectsBank[i][`ObjectPositionV]) &
         (cntr_v < (ObjectsBank[i][`ObjectPositionV] + 5'd16 + (ObjectsBank[i][`ObjectHeight] << 4))) &
         (cntr_h >= ObjectsBank[i][`ObjectPositionH]) &
         (cntr_h < (ObjectsBank[i][`ObjectPositionH] + 5'd16 + (ObjectsBank[i][`ObjectWidth]  << 4)));
      assign ObjectsStatus[i][`ObjectPixelH] = cntr_h - ObjectsBank[i][`ObjectPositionH];
      assign ObjectsStatus[i][`ObjectPixelV] = cntr_v - ObjectsBank[i][`ObjectPositionV];
      
   end
endgenerate

always@(posedge clk)
begin
   if(cntr_h == 11'd800 & cntr_v == 10'd600)
   begin
      if(shift_object_right)
         ObjectsBank[0][`ObjectPositionH] <= ObjectsBank[0][`ObjectPositionH] + 1'b1;
      else if(shift_object_left)
         ObjectsBank[0][`ObjectPositionH] <= ObjectsBank[0][`ObjectPositionH] - 1'b1;
   end
end

always@(posedge clk)
begin
   if(cntr_h == 11'd800 & cntr_v == 10'd600)
   begin
      for(k=1; k < OBJECT_BANK_SIZE; k=k+1)
      begin
         ObjectsBank[k][`ObjectPositionV] <= ObjectsBank[k][`ObjectPositionV] + 1'b1;
      end
   end
end

reg [4:0] objaddr;
reg gameOver_reg;
always@(*)
begin
   objaddr = 5'b11111;
   gameOver_reg = 1'b0;
   for(k=OBJECT_BANK_SIZE-1; k >= 0; k=k-1)
   begin
      if(ObjectsStatus[k][`ObjectActive] == 1'b1 & ObjectsBank[k][`ObjectExists] == 1'b1) begin
         objaddr = k;
         if( (k>0) & (ObjectsStatus[0][`ObjectActive] == 1'b1) )
            gameOver_reg = 1'b1;
      end
   end
end

assign gameOver = gameOver_reg;

// Bitmap bank
wire [5:0] rgb;
bitmapbank bitmapbank(
   .clk(clk),
   .addr(ObjectsBank[objaddr][`ObjectBitmap]),
   .width(ObjectsBank[objaddr][`ObjectWidth]),
   .height(ObjectsBank[objaddr][`ObjectHeight]),
   .hpos(ObjectsStatus[objaddr][`ObjectPixelH]),
   .vpos(ObjectsStatus[objaddr][`ObjectPixelV]),
   .pixel(rgb)
);

assign pixel = (objaddr == 5'b11111) ? BACKGROUND_COLOR : rgb;

endmodule
