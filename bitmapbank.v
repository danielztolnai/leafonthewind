`timescale 1ns / 1ps

module bitmapbank #(
   parameter SIZE=4          // Maximum number of bitmaps, (log2)
                             // each takes up 1536 bits (192 bytes)
   ) (
   input             clk,
   input  [SIZE-1:0] addr,   // Start address (16x16 blocks)
   input             width,  // Number of 16 blocks horizontally (0-1)
   input             height, // Number of 16 blocks vertically (0-1)
   input  [4:0]      hpos,   // Horizontal poistion in bitmap (0-31)
   input  [4:0]      vpos,   // Vertical poistion in bitmap (0-31)
   output [5:0]      pixel   // Output pixel (RRGGBB)
);

wire [3:0] bhpos, bvpos;
assign bhpos = hpos[3:0];
assign bvpos = vpos[3:0];

reg [5:0] bitmap_array[(2**SIZE)-1:0][15:0][15:0];

/*
 * width==0 || height==0 -> addr = addr + hpos[4] + vpos[4]           // top/left | bottom/right
 * width==1 && height==1 -> addr = addr + hpos[4] + vpos[4] + vpos[4] // top left | top right | bottom left | bottom right
 */
wire [SIZE-1:0] real_addr;
assign real_addr = ((width & height) == 0) ? (addr + hpos[4] + vpos[4]) : (addr + hpos[4] + vpos[4] + vpos[4]);

assign pixel = bitmap_array[real_addr][bvpos][bhpos];

integer i, j, k;
initial
begin
for (i=0; i<4; i=i+1)
   for (j=0; j<16; j=j+1)
      for (k=0; k<16; k=k+1)
         bitmap_array[i][j][k] = 6'b001100;
		
for (i=4; i<8; i=i+1)
   for (j=0; j<16; j=j+1)
      for (k=0; k<16; k=k+1)
         bitmap_array[i][j][k] = 6'b000011;
		
for (i=8; i<12; i=i+1)
   for (j=0; j<16; j=j+1)
      for (k=0; k<16; k=k+1)
         bitmap_array[i][j][k] = 6'b001111;

for (i=12; i<16; i=i+1)
   for (j=0; j<16; j=j+1)
      for (k=0; k<16; k=k+1)
         bitmap_array[i][j][k] = 6'b111001;
end

endmodule
