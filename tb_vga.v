`timescale 1ns / 1ps

module tb_vga;

	// Inputs
	reg clk;
	reg rst;
	reg en;
	reg [5:0] pixel;

	// Outputs
	wire [1:0] red;
	wire [1:0] green;
	wire [1:0] blue;
	wire hsync;
	wire vsync;
	wire [10:0] nextH;
	wire [9:0] nextV;
	wire nextActive;

	// Instantiate the Unit Under Test (UUT)
	vga uut (
		.clk(clk), 
		.rst(rst), 
		.en(en), 
		.red(red), 
		.green(green), 
		.blue(blue), 
		.hsync(hsync), 
		.vsync(vsync), 
		.nextH(nextH), 
		.nextV(nextV), 
		.nextActive(nextActive), 
		.pixel(pixel)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		en = 0;
		pixel = 0;

		// Wait 100 ns for global reset to finish
		#100;
      rst=0;
      en = 1;
      pixel = 6'b111111;
        
		// Add stimulus here

	end
   
   always #1 begin
      clk = ~clk;
   end
      
endmodule

