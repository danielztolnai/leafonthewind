`timescale 1ns / 1ps

module leds(
   input clk,
   input rst,
   input [7:0] led,
   input [3:0] dig0,
   input [3:0] dig1,
   output cpld_clk,
   output cpld_rstn,
   output cpld_ld,
   output cpld_mosi
);

reg [15:0] cntr;
always @ (posedge clk)
if (rst)
   cntr <= 0;
else
   cntr <= cntr + 1'b1;

wire [3:0] dig_data;
assign dig_data = (cntr[15]) ? dig1 : dig0;

reg [7:0] seg_data;
always @(dig_data)
   case (dig_data)
      4'b0001 : seg_data = 8'b11111001;   // 1
      4'b0010 : seg_data = 8'b10100100;   // 2
      4'b0011 : seg_data = 8'b10110000;   // 3
      4'b0100 : seg_data = 8'b10011001;   // 4
      4'b0101 : seg_data = 8'b10010010;   // 5
      4'b0110 : seg_data = 8'b10000010;   // 6
      4'b0111 : seg_data = 8'b11111000;   // 7
      4'b1000 : seg_data = 8'b10000000;   // 8
      4'b1001 : seg_data = 8'b10010000;   // 9
      4'b1010 : seg_data = 8'b10001000;   // A
      4'b1011 : seg_data = 8'b10000011;   // b
      4'b1100 : seg_data = 8'b11000110;   // C
      4'b1101 : seg_data = 8'b10100001;   // d
      4'b1110 : seg_data = 8'b10000110;   // E
      4'b1111 : seg_data = 8'b10001110;   // F
      default : seg_data = 8'b11000000;   // 0
   endcase

wire cpld_clk_fall;
assign cpld_clk_fall = (cntr[10:0]==11'b11111111111);

reg [15:0] mosi_shr;
always @ (posedge clk)
if (rst)
   mosi_shr <= {8'hff, 8'h0};
else if (cntr[14:0]==15'h7fff)
   mosi_shr <= {~seg_data, led};
else if (cpld_clk_fall)
   mosi_shr <= {1'b0, mosi_shr[15:1]};

assign cpld_clk  = cntr[10];
assign cpld_rstn = ~rst;
assign cpld_ld   = (cntr[14:11]==15);
assign cpld_mosi = mosi_shr[0];

endmodule
