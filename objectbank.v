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

parameter BACKGROUND_COLOR = 6'b010000;
parameter OBJECT_BANK_SIZE = 16;
 
`define ObjectPositionH  9: 0
`define ObjectPositionV 19:10
`define ObjectExists       20
`define ObjectBitmap    22:21
`define ObjectWidth     28:23
`define ObjectHeight    34:29
reg [34:0] ObjectsBank[OBJECT_BANK_SIZE-1:0];

integer k;
initial
begin
   ObjectsBank[0] = {6'd32, 6'd32, 2'b11, 1'b1, 10'd550, 10'd100};
   ObjectsBank[1] = {6'd32, 6'd32, 2'b00, 1'b1, 10'd120, 10'd120};
   ObjectsBank[2] = {6'd32, 6'd32, 2'b01, 1'b1, 10'd80,  10'd400};
   for (k = 3; k < OBJECT_BANK_SIZE; k=k+1)
   begin
      ObjectsBank[k] = 35'b0;
   end
end

`define ObjectActive        0
`define ObjectPixelH     6: 1
`define ObjectPixelV    12: 7
wire [12:0] ObjectsStatus[OBJECT_BANK_SIZE-1:0];

genvar i;
generate
   for (i=0; i < OBJECT_BANK_SIZE; i=i+1) 
   begin: GenerateObjectsStatus
   
      assign ObjectsStatus[i][`ObjectActive] =
         (cntr_v >= ObjectsBank[i][`ObjectPositionV]) & (cntr_v < (ObjectsBank[i][`ObjectPositionV] + ObjectsBank[i][`ObjectHeight])) &
         (cntr_h >= ObjectsBank[i][`ObjectPositionH]) & (cntr_h < (ObjectsBank[i][`ObjectPositionH] + ObjectsBank[i][`ObjectWidth] ));
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

reg [5:0] rgb;
reg gameOver_reg;
always@(*)
begin
   rgb = BACKGROUND_COLOR; // Background color, temporary
   gameOver_reg = 1'b0;
   for(k=OBJECT_BANK_SIZE-1; k >= 0; k=k-1)
   begin
         rgb = {ObjectsBank[k][`ObjectBitmap], 2'b11, ObjectsBank[k][`ObjectBitmap]};
      if(ObjectsStatus[k][`ObjectActive] == 1'b1 & ObjectsBank[k][`ObjectExists] == 1'b1) begin
         if( (k>0) & (ObjectsStatus[0][`ObjectActive] == 1'b1) )
            gameOver_reg = 1'b1;
      end
   end
end

assign pixel = rgb;
assign gameOver = gameOver_reg;

endmodule
