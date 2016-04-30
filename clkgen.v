`timescale 1ps/1ps

module clkgen(
	input  CLK_IN1,
	output CLK_OUT1
);

IBUFG clkin1_buf(
	.O(clkin1),
   .I(CLK_IN1)
);

wire clkfb;
wire clk2x;

DCM_SP #(
	.CLKDV_DIVIDE          (2.000),
   .CLKFX_DIVIDE          (1),
   .CLKFX_MULTIPLY        (4),
   .CLKIN_DIVIDE_BY_2     ("FALSE"),
   .CLKIN_PERIOD          (20.0),
   .CLKOUT_PHASE_SHIFT    ("NONE"),
   .CLK_FEEDBACK          ("2X"),
   .DESKEW_ADJUST         ("SYSTEM_SYNCHRONOUS"),
   .PHASE_SHIFT           (0),
   .STARTUP_WAIT          ("FALSE")
)
dcm_sp_inst(
	.CLKIN                 (clkin1),
   .CLKFB                 (clkfb),
   // Output clocks
   .CLK0                  (),
   .CLK90                 (),
   .CLK180                (),
   .CLK270                (),
   .CLK2X                 (clk2x),
   .CLK2X180              (),
   .CLKFX                 (),
   .CLKFX180              (),
   .CLKDV                 (),
   // Ports for dynamic phase shift
   .PSCLK                 (1'b0),
   .PSEN                  (1'b0),
   .PSINCDEC              (1'b0),
   .PSDONE                (),
   // Other control and status signals
   .LOCKED                (),
   .STATUS                (),
   .RST                   (1'b0),
   // Unused pin- tie low
   .DSSEN                 (1'b0)
);

BUFG clkf_buf(
	.O(clkfb),
   .I(clk2x)
);

BUFG clkout1_buf(
	.O(CLK_OUT1),
   .I(clk2x)
);

endmodule
