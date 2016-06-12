`timescale 1ns / 1ps

module bitmapbank #(
   parameter SIZE=4          // Maximum number of bitmaps, (log2)
                             // each takes up 1536 bits (192 bytes)
   ) (
   input             clk,
   input  [SIZE-1:0] addr,   // Start address (16x16 blocks)
   input             width,  // Number of 16 blocks horizontally (0-1)
   input  [4:0]      hpos,   // Horizontal poistion in bitmap (0-31)
   input  [4:0]      vpos,   // Vertical poistion in bitmap (0-31)
   output [5:0]      pixel   // Output pixel (RRGGBB)
);

reg [5:0] bitmap_array[((2**SIZE)*256)-1:0];
initial $readmemh("bitmap.txt", bitmap_array);

wire [8+SIZE:0] memaddr;
//                addr *256  +   vpos * 16  *(width+1) + hpos
assign memaddr = (addr << 8) + ((vpos << 4) <<  width) + hpos;

reg [5:0] pixelReg;
always@(posedge clk)
begin
   pixelReg <= bitmap_array[memaddr];
end
assign pixel = pixelReg;

endmodule
