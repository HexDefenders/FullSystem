module vga_control (clk, rst, value, p1, p2, p3, p4, gval, gbval, vga_blank_n, hsync, vsync, vga_clk, bright, main, x_start, x_end, y_start, y_end, rgb_color, hcount, vcount);
	input			      clk, rst;
	input	     [7:0]  value;
	input		  [15:0] p1, p2, p3, p4;
	output				hsync, vsync;
	output reg			vga_blank_n, vga_clk, bright, main;
	output reg [5:0]  gval, gbval;
	
	// size of registers log2(800) ~ 10
	//							log2(525) ~ 10
	output reg [9:0] 	x_start, x_end, y_start, y_end, hcount, vcount;
	output reg [23:0] rgb_color;
	reg		 			counter;
	
	parameter HS_START = 10'd16;
	parameter HS_SYNC  = 10'd96;
	parameter HS_END   = 10'd48;
	parameter HS_TOTAL = 10'd800;
	
	parameter VS_INIT  = 10'd480;
	parameter VS_START = 10'd10;
	parameter VS_SYNC  = 10'd2;
	parameter VS_END   = 10'd33;
	parameter VS_TOTAL = 10'd525;
	
	parameter rgb_text = 24'h343a40;
	
	// dimensions of player glyphs
	parameter p_x_dim  = 10'd8; // exact match to size of glyph projection width
	parameter p_y_dim  = 10'd8; // exact match to size of glyph projection height
	
	// Player 1
	parameter p1_x_start = 10'd100;
	parameter p1_y_start = 10'd100;
	
	// Player 2
	parameter p2_x_start = 10'd100;
	parameter p2_y_start = 10'd200;

	// Player 3
	parameter p3_x_start = 10'd100;
	parameter p3_y_start = 10'd300;
	
	// Player 4
	parameter p4_x_start = 10'd100;
	parameter p4_y_start = 10'd400;
	
	// Main display
	parameter main_x_start = 10'd272;
	parameter main_y_start = 10'd175;
	parameter main_x_dim  = 10'd64;  // exact match to size of glyph projection width
	parameter main_y_dim  = 10'd64; // exact match to size of glyph projection height

	always @(posedge clk) begin
		if (rst == 1'b0) begin
			vcount  = 10'd0; 	
			hcount  = 10'd0;
			counter = 1'b0; 	
			vga_clk = 1'b0;
		end
		
		else if (counter == 1'b1) begin
			hcount = hcount + 1'b1;
			if (hcount == HS_TOTAL) begin
				hcount = 10'd0;
				vcount = vcount + 1'b1;
				if (vcount == VS_TOTAL)
					vcount = 10'd0;
			end
		end
		
		vga_clk = ~vga_clk;
		counter = counter + 1'b1;
	end
	
	assign hsync = ~((hcount >= HS_START) & (hcount < HS_START + HS_SYNC));
	assign vsync = ~((vcount >= VS_INIT + VS_START) & (vcount < VS_INIT + VS_START + VS_SYNC));
	
	always @(*) begin
		gval  <= 5'h0;
		gbval <= 5'h0;
		rgb_color <= 23'h0;
		x_start <= 0;
		x_end <= 0;
		y_start <= 0;
		y_end <= 0;
		main <= 0;
	
		// bright
		if ((hcount >= HS_START + HS_SYNC + HS_END)
					&& (hcount < HS_TOTAL - HS_START) 
					&& (vcount < VS_INIT)) begin
			bright <= 1'b1;
			vga_blank_n <= 1'b1;
		end
		
		else begin
			bright <= 1'b0;
			vga_blank_n <= 1'b0;
		end
		
		// Load P1 glyph
//		if ((hcount >= p1_x_start) && (hcount < (p1_x_start + p_x_dim))) begin
//			if ((vcount >= p1_y_start) && (vcount < (p1_y_start + p_y_dim))) begin
//				gval <= p1;
//				
//				rgb_color <= rgb_text;
//				x_start   <= p1_x_start;
//				x_end     <= p1_x_start + p_x_dim;
//				y_start   <= p1_y_start;
//				y_end     <= p1_y_start + p_y_dim;
//				main_disp <= 0;
//			end
//		end
//		
//		// Load P2 glyph
//		if ((hcount >= p2_x_start) && (hcount < (p2_x_start + p_x_dim))) begin
//			if ((vcount >= p2_y_start) && (vcount < (p2_y_start + p_y_dim))) begin
//				gval <= p2;
//				
//				rgb_color <= rgb_text;
//				x_start   <= p2_x_start;
//				x_end     <= p2_x_start + p_x_dim;
//				y_start   <= p2_y_start;
//				y_end     <= p2_y_start + p_y_dim;
//				main_disp <= 0;
//			end
//		end
//		
//		// Load P3 glyph
//		if ((hcount >= p3_x_start) && (hcount < (p3_x_start + p_x_dim))) begin
//			if ((vcount >= p3_y_start) && (vcount < (p3_y_start + p_y_dim))) begin
//				gval <= p3;
//				
//				rgb_color <= rgb_text;
//				x_start   <= p3_x_start;
//				x_end     <= p3_x_start + p_x_dim;
//				y_start   <= p3_y_start;
//				y_end     <= p3_y_start + p_y_dim;
//				main_disp <= 0;
//			end
//		end
//		
//		// Load P4 glyph
//		if ((hcount >= p4_x_start) && (hcount < (p4_x_start + p_x_dim))) begin
//			if ((vcount >= p4_y_start) && (vcount < (p4_y_start + p_y_dim))) begin
//				gval <= p4;
//				
//				rgb_color <= rgb_text;
//				x_start   <= p4_x_start;
//				x_end     <= p4_x_start + p_x_dim;
//				y_start   <= p4_y_start;
//				y_end     <= p4_y_start + p_y_dim;
//				main_disp <= 0;
//			end
//		end
		
		// Load main value
		
		if ((vcount >= main_y_start) && (vcount < (main_y_start + main_y_dim))) begin
			// 0
			if ((hcount >= main_x_start) && (hcount < (main_x_start + main_x_dim))) begin
				gbval <= 5'h0;
				
				rgb_color <= rgb_text;
				x_start   <= main_x_start;
				x_end     <= main_x_start + main_x_dim;
				y_start   <= main_y_start;
				y_end     <= main_y_start + main_y_dim;
				main 		 <= 1;
			end
			
			// x
			else if ((hcount >= (main_x_start + main_x_dim)) && (hcount < (main_x_start + main_x_dim + main_x_dim))) begin
				gbval <= 5'h11;
				
				rgb_color <= rgb_text;
				x_start   <= main_x_start + main_x_dim;
				x_end     <= main_x_start + main_x_dim + main_x_dim;
				y_start   <= main_y_start;
				y_end     <= main_y_start + main_y_dim;
				main 		 <= 1;
			end
			
			// hex1
			else if ((hcount >= (main_x_start + 2*main_x_dim)) && (hcount < (main_x_start + 3*main_x_dim))) begin
				gbval <= value[7:4];
				
				rgb_color <= rgb_text;
				x_start   <= main_x_start + 2*main_x_dim;
				x_end     <= main_x_start + 3*main_x_dim;
				y_start   <= main_y_start;
				y_end     <= main_y_start + main_y_dim;
				main		 <= 1;
				
			end
			
			// hex0
			else if ((hcount >= (main_x_start + 3*main_x_dim)) && (hcount < (main_x_start + 4*main_x_dim))) begin
				gbval <= value[3:0];
				
				rgb_color <= rgb_text;
				x_start   <= main_x_start + 3*main_x_dim;
				x_end     <= main_x_start + 4*main_x_dim;
				y_start   <= main_y_start;
				y_end     <= main_y_start + 2*main_y_dim;
				main		 <= 1;
			end
		end
	end
	
endmodule
