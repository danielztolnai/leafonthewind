module keyboard(
   input  clk,
   input  rst,
   
   input  ps2_c,
   input  ps2_d,
   
   output reg [4:0] keys_pressed
);

// PS2 clock falling edge detection
reg [1:0] ps2c_dl;
always @ (posedge clk)
begin
	ps2c_dl <= {ps2c_dl[0], ps2_c};
end

wire smpl_en;
assign smpl_en = (ps2c_dl == 2'b10);

// Bit counter (start bit, 8 data bits, parity bit, stop bit)
reg [3:0] bit_cntr;
always @ (posedge clk)
begin
   if (rst)
      bit_cntr <= 0;
   else if (smpl_en)
   begin
      if (bit_cntr==4'd10)
         bit_cntr <= 4'b0;
      else
         bit_cntr <= bit_cntr + 1'b1;
   end
end

// Data is valid in the shr
reg data_valid;
always @ (posedge clk)
begin
   if(rst)
      data_valid <= 1'b0;
   else if(smpl_en)
	begin
		if(bit_cntr == 4'd10)
			data_valid <= 1'b1;
		else
			data_valid <= 1'b0;
	end
end

// Data shift register
reg [10:0] data_shr;
always @ (posedge clk)
begin
   if(smpl_en)
      data_shr <= {ps2_d, data_shr[10:1]};
end

// Store the last valid byte
reg [7:0] data_last;
always @ (posedge clk)
begin
   if(rst)
      data_last <= 8'b0;
   else if(smpl_en)
   begin
      if (data_valid)
      begin
         data_last <= data_shr[8:1];
      end
   end
end

// Scand code interpretation
always @ ( posedge clk )
begin
	if (data_valid)
	begin
   case (data_shr[8:1])
      8'h75: keys_pressed[0] <= (data_last[7:0] == 8'hF0) ? 1'b0 : 1'b1;  // UP    and keypad 8
      8'h6B: keys_pressed[1] <= (data_last[7:0] == 8'hF0) ? 1'b0 : 1'b1;  // LEFT  and keypad 4
      8'h72: keys_pressed[2] <= (data_last[7:0] == 8'hF0) ? 1'b0 : 1'b1;  // DOWN  and keypad 2
      8'h74: keys_pressed[3] <= (data_last[7:0] == 8'hF0) ? 1'b0 : 1'b1;  // RIGHT and keypad 6

		8'h1D: keys_pressed[0] <= (data_last[7:0] == 8'hF0) ? 1'b0 : 1'b1;  // W
		8'h1C: keys_pressed[1] <= (data_last[7:0] == 8'hF0) ? 1'b0 : 1'b1;  // A
		8'h1B: keys_pressed[2] <= (data_last[7:0] == 8'hF0) ? 1'b0 : 1'b1;  // S
		8'h23: keys_pressed[3] <= (data_last[7:0] == 8'hF0) ? 1'b0 : 1'b1;  // D
		
		8'h29: keys_pressed[4] <= (data_last[7:0] == 8'hF0) ? 1'b0 : 1'b1;  // SPACE
		default: ;
   endcase
	end
end

endmodule
