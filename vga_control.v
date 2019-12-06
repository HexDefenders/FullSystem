module vga_control (clk, rst, value, p1, p2, p3, p4, game_over, gval, gbval, vga_blank_n, hsync, vsync, vga_clk, bright, mode, x_start, x_end, y_start, y_end, rgb_color, hcount, vcount);
	input			      clk, rst;
	input	     [7:0]  value;
	input		  [15:0] p1, p2, p3, p4, game_over;
	output				hsync, vsync;
	output reg			vga_blank_n, vga_clk, bright;
	output reg [1:0]	mode;
	output reg [5:0]  gval, gbval;
	
	// size of registers log2(800) ~ 10
	//							log2(525) ~ 10
	output reg [9:0] 	x_start, x_end, y_start, y_end, hcount, vcount;
	output reg [23:0] rgb_color;
	reg		 			counter;
	
	// ###############################
	//  Drawing Modes
	// ###############################
	
	parameter MODE_BG 	= 2'b00;  	// background
	parameter MODE_8x8 	= 2'b01; 	// 8x8 glyph
	parameter MODE_64x64 = 2'b10;	// 64x64 glyph
	
	
	// ###############################
	//  Counter Statistics
	// ###############################
	
	parameter HS_START = 10'd16;
	parameter HS_SYNC  = 10'd96;
	parameter HS_END   = 10'd48;
	parameter HS_TOTAL = 10'd800;
	
	parameter VS_INIT  = 10'd480;
	parameter VS_START = 10'd10;
	parameter VS_SYNC  = 10'd2;
	parameter VS_END   = 10'd33;
	parameter VS_TOTAL = 10'd525;
	
	
	// ###############################
	//  Colors
	// ###############################
	
	parameter rgb_text = 24'h343a40;
	parameter rgb_bg	 = 24'hf8f9fa;
	parameter rgb_p1 	 = 24'hff2121;
	parameter rgb_p2   = 24'h003fad;
	parameter rgb_p3   = 24'hfff609;
	parameter rgb_p4   = 24'h78dc52;
	
	
	// ###############################
	//  Main Display
	// ###############################
	
	parameter main_x_start = 10'd335;
	parameter main_y_start = 10'd150;
	parameter main_x_dim   = 10'd64;  // exact match to size of glyph projection width
	parameter main_y_dim   = 10'd64; // exact match to size of glyph projection height
	
	
	// ###############################
	//  8x8 Glyph Dimensions
	// ###############################
	
	parameter p_x_dim  = 10'd8; // exact match to size of glyph projection width
	parameter p_y_dim  = 10'd8; // exact match to size of glyph projection height
	
	
	// ###############################
	//  Player Banners
	// ###############################
	parameter p_bg_x_start = 10'd140;
	parameter p_bg_y_start = 10'd284;
	parameter p_bg_x_dim   = 10'd160;
	parameter p_bg_y_dim   = 10'd15;
	
	
	// ###############################
	//  Player Glyphs
	// ###############################
	parameter p1_gl_x_start = 10'd240;
	parameter p2_gl_x_start = 10'd400;
	parameter p3_gl_x_start = 10'd560;
	parameter p4_gl_x_start = 10'd720;
	parameter p_gl_y_start  = 10'd270;
	
	
	// ###############################
	//  GAME OVER Glyphs
	// ###############################
	parameter over_x_start = 10'd200;
	parameter over_y_start = 10'd350;
	parameter over_x_dim = 10'd50;
	parameter over_y_dim = 10'd64;
	

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
		gval  <= 6'h0;
		gbval <= 6'h0;
		rgb_color <= 23'h0;
		x_start <= 10'd0;
		x_end <= 10'd0;
		y_start <= 10'd0;
		y_end <= 10'd0;
		mode <= MODE_BG;
	
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
		
		if (game_over) begin
			if ((vcount >= over_y_start) && (vcount < (over_y_start + over_y_dim))) begin
				// G
				if ((hcount >= (VS_START + over_x_start)) && (hcount < (VS_START + over_x_start + over_x_dim))) begin
					gbval <= 6'd16;
					
					rgb_color <= rgb_text;
					x_start 	 <= VS_START + over_x_start;
					x_end 	 <= VS_START + over_x_start + over_x_dim;
					y_start	 <= over_y_start;
					y_end 	 <= over_y_start + main_y_dim;
					mode		 <= MODE_64x64;
				end
				
				// A
				else if ((hcount >= (VS_START + over_x_start + over_x_dim)) && (hcount < (VS_START + over_x_start + 2*over_x_dim))) begin
					gbval <= 6'ha;
					
					rgb_color <= rgb_text;
					x_start 	 <= VS_START + over_x_start + over_x_dim;
					x_end 	 <= VS_START + over_x_start + 2*over_x_dim;
					y_start	 <= over_y_start;
					y_end 	 <= over_y_start + main_y_dim;
					mode		 <= MODE_64x64;
				end
				
				// M
				else if ((hcount >= (VS_START + over_x_start + 2*over_x_dim)) && (hcount < (VS_START + over_x_start + 3*over_x_dim))) begin
					gbval <= 6'd22;
					
					rgb_color <= rgb_text;
					x_start 	 <= VS_START + over_x_start + 2*over_x_dim;
					x_end 	 <= VS_START + over_x_start + 3*over_x_dim;
					y_start	 <= over_y_start;
					y_end 	 <= over_y_start + main_y_dim;
					mode		 <= MODE_64x64;
				end
				
				// E
				else if ((hcount >= (VS_START + over_x_start + 3*over_x_dim)) && (hcount < (VS_START + over_x_start + 4*over_x_dim))) begin
					gbval <= 6'he;
					
					rgb_color <= rgb_text;
					x_start 	 <= VS_START + over_x_start + 3*over_x_dim;
					x_end 	 <= VS_START + over_x_start + 4*over_x_dim;
					y_start	 <= over_y_start;
					y_end 	 <= over_y_start + main_y_dim;
					mode		 <= MODE_64x64;
				end
				
				// O
				else if ((hcount >= (VS_START + over_x_start + 5*over_x_dim)) && (hcount < (VS_START + over_x_start + 6*over_x_dim))) begin
					gbval <= 6'd24;
					
					rgb_color <= rgb_text;
					x_start 	 <= VS_START + over_x_start + 5*over_x_dim;
					x_end 	 <= VS_START + over_x_start + 6*over_x_dim;
					y_start	 <= over_y_start;
					y_end 	 <= over_y_start + main_y_dim;
					mode		 <= MODE_64x64;
				end
				
				// V
				else if ((hcount >= (VS_START + over_x_start + 6*over_x_dim)) && (hcount < (VS_START + over_x_start + 7*over_x_dim))) begin
					gbval <= 6'd31;
					
					rgb_color <= rgb_text;
					x_start 	 <= VS_START + over_x_start + 6*over_x_dim;
					x_end 	 <= VS_START + over_x_start + 7*over_x_dim;
					y_start	 <= over_y_start;
					y_end 	 <= over_y_start + main_y_dim;
					mode		 <= MODE_64x64;
				end
				
				// E
				else if ((hcount >= (VS_START + over_x_start + 7*over_x_dim)) && (hcount < (VS_START + over_x_start + 8*over_x_dim))) begin
					gbval <= 6'he;
					
					rgb_color <= rgb_text;
					x_start 	 <= VS_START + over_x_start + 7*over_x_dim;
					x_end 	 <= VS_START + over_x_start + 8*over_x_dim;
					y_start	 <= over_y_start;
					y_end 	 <= over_y_start + main_y_dim;
					mode		 <= MODE_64x64;
				end
				
				// R
				else if ((hcount >= (VS_START + over_x_start + 8*over_x_dim)) && (hcount < (VS_START + over_x_start + 9*over_x_dim))) begin
					gbval <= 6'd27;
					
					rgb_color <= rgb_text;
					x_start 	 <= VS_START + over_x_start + 8*over_x_dim;
					x_end 	 <= VS_START + over_x_start + 9*over_x_dim;
					y_start	 <= over_y_start;
					y_end 	 <= over_y_start + main_y_dim;
					mode		 <= MODE_64x64;
				end
				
				// !
				else if ((hcount >= (VS_START + over_x_start + 9*over_x_dim)) && (hcount < (VS_START + over_x_start + 10*over_x_dim))) begin
					gbval <= 6'd39;
					
					rgb_color <= rgb_text;
					x_start 	 <= VS_START + over_x_start + 9*over_x_dim;
					x_end 	 <= VS_START + over_x_start + 10*over_x_dim;
					y_start	 <= over_y_start;
					y_end 	 <= over_y_start + main_y_dim;
					mode		 <= MODE_64x64;
				end
			end
		end
		
		// Player 1 Score glyphs
		if ((vcount >= p_gl_y_start) && (vcount < (p_gl_y_start + p_y_dim))) begin
			// P
			if ((hcount >= VS_START + p1_gl_x_start) && (hcount < (VS_START + p1_gl_x_start + p_x_dim))) begin
				gval <= 6'd26;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p1_gl_x_start;
				x_end 	 <= VS_START + p1_gl_x_start + p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
		
			// 1
			else if ((hcount >= VS_START + p1_gl_x_start + p_x_dim) && (hcount < (VS_START + p1_gl_x_start + 2*p_x_dim))) begin
				gval <= 6'h01;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p1_gl_x_start + p_x_dim;
				x_end 	 <= VS_START + p1_gl_x_start + 2*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
		
			// :
			else if ((hcount >= VS_START + p1_gl_x_start + 2*p_x_dim) && (hcount < (VS_START + p1_gl_x_start + 3*p_x_dim))) begin
				gval <= 6'd38;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p1_gl_x_start + 2*p_x_dim;
				x_end 	 <= VS_START + p1_gl_x_start + 3*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
			
			else if ((hcount >= VS_START + p1_gl_x_start + 3*p_x_dim) && (hcount < (VS_START + p1_gl_x_start + 4*p_x_dim))) begin
				gval <= p1;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p1_gl_x_start + 3*p_x_dim;
				x_end 	 <= VS_START + p1_gl_x_start + 4*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
		
		// Player 2 Score glyphs
			// P
			else if ((hcount >= VS_START + p2_gl_x_start) && (hcount < (VS_START + p2_gl_x_start + p_x_dim))) begin
				gval <= 6'd26;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p2_gl_x_start;
				x_end 	 <= VS_START + p2_gl_x_start + p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
		
			// 2
			else if ((hcount >= VS_START + p2_gl_x_start + p_x_dim) && (hcount < (VS_START + p2_gl_x_start + 2*p_x_dim))) begin
				gval <= 6'h02;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p2_gl_x_start + p_x_dim;
				x_end 	 <= VS_START + p2_gl_x_start + 2*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
		
			// :
			else if ((hcount >= VS_START + p2_gl_x_start + 2*p_x_dim) && (hcount < (VS_START + p2_gl_x_start + 3*p_x_dim))) begin
				gval <= 6'd38;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p2_gl_x_start + 2*p_x_dim;
				x_end 	 <= VS_START + p2_gl_x_start + 3*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
			
			else if ((hcount >= VS_START + p2_gl_x_start + 3*p_x_dim) && (hcount < (VS_START + p2_gl_x_start + 4*p_x_dim))) begin
				gval <= p2;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p2_gl_x_start + 3*p_x_dim;
				x_end 	 <= VS_START + p2_gl_x_start + 4*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
			
		// Player 3 Score glyphs
			// P
			else if ((hcount >= VS_START + p3_gl_x_start) && (hcount < (VS_START + p3_gl_x_start + p_x_dim))) begin
				gval <= 6'd26;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p3_gl_x_start;
				x_end 	 <= VS_START + p3_gl_x_start + p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
		
			// 3
			else if ((hcount >= VS_START + p3_gl_x_start + p_x_dim) && (hcount < (VS_START + p3_gl_x_start + 2*p_x_dim))) begin
				gval <= 6'h03;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p3_gl_x_start + p_x_dim;
				x_end 	 <= VS_START + p3_gl_x_start + 2*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
		
			// :
			else if ((hcount >= VS_START + p3_gl_x_start + 2*p_x_dim) && (hcount < (VS_START + p3_gl_x_start + 3*p_x_dim))) begin
				gval <= 6'd38;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p3_gl_x_start + 2*p_x_dim;
				x_end 	 <= VS_START + p3_gl_x_start + 3*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
			
			else if ((hcount >= VS_START + p3_gl_x_start + 3*p_x_dim) && (hcount < (VS_START + p3_gl_x_start + 4*p_x_dim))) begin
				gval <= p3;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p3_gl_x_start + 3*p_x_dim;
				x_end 	 <= VS_START + p3_gl_x_start + 4*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
			
		// Player 4 Score glyphs
			// P
			else if ((hcount >= VS_START + p4_gl_x_start) && (hcount < (VS_START + p4_gl_x_start + p_x_dim))) begin
				gval <= 6'd26;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p4_gl_x_start;
				x_end 	 <= VS_START + p4_gl_x_start + p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
		
			// 4
			else if ((hcount >= VS_START + p4_gl_x_start + p_x_dim) && (hcount < (VS_START + p4_gl_x_start + 2*p_x_dim))) begin
				gval <= 6'h4;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p4_gl_x_start + p_x_dim;
				x_end 	 <= VS_START + p4_gl_x_start + 2*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
		
			// :
			else if ((hcount >= VS_START + p4_gl_x_start + 2*p_x_dim) && (hcount < (VS_START + p4_gl_x_start + 3*p_x_dim))) begin
				gval <= 6'd38;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p4_gl_x_start + 2*p_x_dim;
				x_end 	 <= VS_START + p4_gl_x_start + 3*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
			
			else if ((hcount >= VS_START + p4_gl_x_start + 3*p_x_dim) && (hcount < (VS_START + p4_gl_x_start + 4*p_x_dim))) begin
				gval <= p4;
				
				rgb_color <= rgb_text;
				x_start 	 <= VS_START + p4_gl_x_start + 3*p_x_dim;
				x_end 	 <= VS_START + p4_gl_x_start + 4*p_x_dim;
				y_start	 <= p_gl_y_start;
				y_end 	 <= p_gl_y_start + p_y_dim;
				mode		 <= MODE_8x8;
			end
		end
		
		// Banners
		else if ((vcount >= p_bg_y_start) && (vcount < (p_bg_y_start + p_bg_y_dim))) begin
			// Player 1 (red) 
			if ((hcount >= VS_START + p_bg_x_start) && (hcount < (VS_START + p_bg_x_start + p_bg_x_dim))) begin
				rgb_color <= rgb_p1;
				x_start   <= VS_START + p_bg_x_start;
				x_end     <= VS_START + p_bg_x_start + p_bg_x_dim;
				y_start   <= p_bg_y_start;
				y_end     <= p_bg_y_start + p_bg_y_dim;
				mode		 <= MODE_BG;
			end
		
			// Player 2 (blue) 
			else if ((hcount >= VS_START + p_bg_x_start + p_bg_x_dim) && (hcount < (VS_START + p_bg_x_start + 2*p_bg_x_dim))) begin
				rgb_color <= rgb_p2;
				x_start   <= VS_START + p_bg_x_start + p_bg_x_dim;
				x_end     <= VS_START + p_bg_x_start + 2*p_bg_x_dim;
				y_start   <= p_bg_y_start;
				y_end     <= p_bg_y_start + p_bg_y_dim;
				mode		 <= MODE_BG;
			end
			
			// Player 3 (yellow)
			else if ((hcount >= VS_START + p_bg_x_start + 2*p_bg_x_dim) && (hcount < (VS_START + p_bg_x_start + 3*p_bg_x_dim))) begin
				rgb_color <= rgb_p3;
				x_start   <= VS_START + p_bg_x_start + 2*p_bg_x_dim;
				x_end     <= VS_START + p_bg_x_start + 3*p_bg_x_dim;
				y_start   <= p_bg_y_start;
				y_end     <= p_bg_y_start + p_bg_y_dim;
				mode		 <= MODE_BG;
			end
			
			// Player 4 (green)
			else if ((hcount >= VS_START + p_bg_x_start + 3*p_bg_x_dim) && (hcount < (VS_START + p_bg_x_start + 4*p_bg_x_dim))) begin
				rgb_color <= rgb_p4;
				x_start   <= VS_START + p_bg_x_start + 3*p_bg_x_dim;
				x_end     <= VS_START + p_bg_x_start + 4*p_bg_x_dim;
				y_start   <= p_bg_y_start;
				y_end     <= p_bg_y_start + p_bg_y_dim;
				mode		 <= MODE_BG;
			end
		end
		
		// Load main value
		else if ((vcount >= main_y_start) && (vcount < (main_y_start + main_y_dim))) begin
			// 0
			if ((hcount >= main_x_start) && (hcount < (main_x_start + main_x_dim))) begin
				gbval <= 6'h0;
				
				rgb_color <= rgb_text;
				x_start   <= VS_START + main_x_start;
				x_end     <= VS_START + main_x_start + main_x_dim;
				y_start   <= main_y_start;
				y_end     <= main_y_start + main_y_dim;
				mode 		 <= MODE_64x64;
			end
			
			// x
			else if ((hcount >= (main_x_start + main_x_dim)) && (hcount < (main_x_start + main_x_dim + main_x_dim))) begin
				gbval <= 6'd37;
				
				rgb_color <= rgb_text;
				x_start   <= VS_START + main_x_start + main_x_dim;
				x_end     <= VS_START + main_x_start + main_x_dim + main_x_dim;
				y_start   <= main_y_start;
				y_end     <= main_y_start + main_y_dim;
				mode 		 <= MODE_64x64;
			end
			
			// hex1
			else if ((hcount >= (main_x_start + 2*main_x_dim)) && (hcount < (main_x_start + 3*main_x_dim))) begin
				gbval <= value[7:4];
				
				rgb_color <= rgb_text;
				x_start   <= VS_START + main_x_start + 2*main_x_dim;
				x_end     <= VS_START + main_x_start + 3*main_x_dim;
				y_start   <= main_y_start;
				y_end     <= main_y_start + main_y_dim;
				mode		 <= MODE_64x64;
				
			end
			
			// hex0
			else if ((hcount >= (main_x_start + 3*main_x_dim)) && (hcount < (main_x_start + 4*main_x_dim))) begin
				gbval <= value[3:0];
				
				rgb_color <= rgb_text;
				x_start   <= VS_START + main_x_start + 3*main_x_dim;
				x_end     <= VS_START + main_x_start + 4*main_x_dim;
				y_start   <= main_y_start;
				y_end     <= main_y_start + 2*main_y_dim;
				mode		 <= MODE_64x64;
			end
		end
	end
	
endmodule
