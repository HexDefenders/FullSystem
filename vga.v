module vga (clk, rst, value, p1, p2, p3, p4, p1Btn, p2Btn, p3Btn, p4Btn, gameOver, hsync, vsync, vga_blank_n, vga_clk, r, g, b);
	input		     clk, rst, p1Btn, p2Btn, p3Btn, p4Btn;
	input	 [7:0]  value;
	input  [15:0] p1, p2, p3, p4, gameOver;

	output		  hsync, vsync, vga_blank_n, vga_clk;
	output [7:0]  r, g, b;
	
	wire   [23:0] rgb_color;
	wire	 [9:0]  hcount, vcount, x_start, x_end, y_start, y_end;
	wire   [5:0]  val, bval;
	wire 			  bright;
	wire	 [1:0]  mode;
	
	wire	 [63:0] 	 glyph;
	wire	 [4095:0] bglyph;
	
	wire	 [7:0]  switches;
	
	vga_control uut1 (
		.clk(clk), .rst(rst), .value(value), .p1(p1), .p2(p2), .p3(p3), .p4(p4), .p1Btn(p1Btn), .p2Btn(p2Btn), .p3Btn(p3Btn), .p4Btn(p4Btn), 
		.gameOver(gameOver), .gval(val), .gbval(bval), 
		.hsync(hsync), .vsync(vsync), .vga_blank_n(vga_blank_n), .vga_clk(vga_clk), .bright(bright), 
		.mode(mode), .x_start(x_start), .x_end(x_end), .y_start(y_start), .y_end(y_end),
		.rgb_color(rgb_color), .hcount(hcount), .vcount(vcount)
	);

	glyphs uut2 (
		.clk(~clk), .value(val), .glyph(glyph)
	);
	
	glyphs2x uut3 (
		.clk(~clk), .value(bval), .glyph(bglyph)
	);
	
	bitgen uut4 (
		.bright(bright), .hcount(hcount), .vcount(vcount), .glyph(glyph), .bglyph(bglyph), .mode(mode),
		.x_start(x_start), .x_end(x_end), .y_start(y_start), .y_end(y_end), .rgb_color(rgb_color), .rgb({r,g,b})
	);

//	switch_tester uut5 (
//		.gpins(gpins), .bright(bright), .hcount(hcount), .vcount(vcount), .rgb({r,g,b})
//	);
	
endmodule
