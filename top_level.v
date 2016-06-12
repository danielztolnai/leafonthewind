`timescale 1ns / 1ps

module top_level(
   // Clock and reset
   input  clk50M,
	input  rstn,
	
   // CPLD
   output cpld_clk,
   output cpld_rstn,
   output cpld_load,
   output cpld_mosi,
   output cpld_jtagen,
	
   // VGA
	output       vga_hsync,
	output       vga_vsync,
	output [1:0] vga_red,
	output [1:0] vga_green,
	output [1:0] vga_blue,
	
   // PS2
	input ps2_c,
	input ps2_d,
	
   // Sound
	output speaker
);

wire rst;
assign rst = ~rstn;
assign cpld_jtagen = 1'b0;

// 100 MHz clock generator
wire clk;
clkgen clkgen(
   .CLK_IN1(clk50M),
   .CLK_OUT1(clk)
);

// Game over signal
wire gameOver;
reg gameOverReg;
always@(posedge clk)
begin
   if(rst)
      gameOverReg <= 1'b0;
   else if(gameOver)
      gameOverReg <= 1'b1;
end

// speaker output
//reg [17:0] speaker_cntr;
//always@(posedge clk)
//begin
//   if(rst)
//      speaker_cntr <= 18'b0;
//   else
//      speaker_cntr <= speaker_cntr + 1'b1;
//end
assign speaker = 1'b0; //speaker_cntr[17];

// VGA controller
reg [1:0] vga_en;
always@(posedge clk)
begin
	if(rst)
		vga_en <= 2'b0;
   else
		vga_en <= vga_en + 1'b1;
end

wire [10:0] cntr_h;
wire [ 9:0] cntr_v;
wire [ 5:0] pixel;

vga vga_controller(
	.clk(clk),
   .rst(rst),
	.en(vga_en[1]),
   .red(vga_red),
   .green(vga_green),
   .blue(vga_blue),
   .hsync(vga_hsync),
   .vsync(vga_vsync),
   
   .nextH(cntr_h),
   .nextV(cntr_v),
   .nextActive(),
   .pixel(pixel)
);

// Object bank and game logic
reg shift_object_left  = 1'b0;
reg shift_object_right = 1'b0;

objectbank objectbank(
   .clk(clk),
   .cntr_h(cntr_h), 
   .cntr_v(cntr_v), 
   .pixel(pixel),
   
   .shift_object_left(shift_object_left),
   .shift_object_right(shift_object_right),
   .gameOver(gameOver)
);


reg [25:0] cntr;
always@(posedge clk)
begin
   if(rst)
		cntr <= 26'b0;
	else
		cntr <= cntr + 1'b1;
end

// Keyboard management
wire [4:0] keys_pressed;
keyboard keyboard_controller(
	.clk(clk),
   .rst(rst),
   .ps2_c(ps2_c),
   .ps2_d(ps2_d),
	.keys_pressed(keys_pressed)
);

always@(posedge clk)
begin
   if(keys_pressed[0])      // up
		vpos <= vpos - 1'b1;
	else if(keys_pressed[2]) // down
		vpos <= vpos + 1'b1;
	else if(keys_pressed[1]) // left
	begin
      shift_object_left <= 1'b1;
		hpos <= hpos - 1'b1;
   end
	else if(keys_pressed[3]) // right
	begin
      shift_object_right <= 1'b1;
		hpos <= hpos + 1'b1;
   end
	else
	begin
      shift_object_right <= 1'b0;
      shift_object_left <= 1'b0;
	end
end

// Visual Feedback
leds leds_controller(
   .clk(clk),
   .rst(rst),
   .led({2'b0, gameOverReg, keys_pressed}),
   .dig0(4'b0),
   .dig1(4'b0),
   .cpld_clk(cpld_clk),
   .cpld_rstn(cpld_rstn),
   .cpld_ld(cpld_load),
   .cpld_mosi(cpld_mosi)
);

endmodule
