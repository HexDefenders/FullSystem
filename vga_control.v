module vga_control (clk, rst, value, p1, p2, p3, p4, p1Btn, p2Btn, p3Btn, p4Btn, screenStatus, winnerPlayerNum, gval, gbval, vga_blank_n, hsync, vsync, vga_clk, bright, mode, x_start, x_end, y_start, y_end, rgb_color, hcount, vcount);
	input			      clk, rst, p1Btn, p2Btn, p3Btn, p4Btn;
	input		  [1:0]  screenStatus, winnerPlayerNum;
	input	     [7:0]  value;
	input		  [15:0] p1, p2, p3, p4;
	output				hsync, vsync;
	output reg			vga_blank_n, vga_clk, bright;
	output reg [1:0]	mode;
	output reg [5:0]  gval, gbval;
	
	// size of registers log2(800) ~ 10
	//							log2(525) ~ 10
	output reg [9:0] 	x_start, x_end, y_start, y_end, hcount, vcount;
	output reg [23:0] rgb_color;
	
	reg		 			counter;
	
	wire		  [23:0] rgb_p1, rgb_p2, rgb_p3, rgb_p4;
	
	// ###############################
	//  Drawing Modes
	// ###############################
	
	parameter MODE_BG 	= 2'b00;  	// background
	parameter MODE_8x8 	= 2'b01; 	// 8x8 glyph
	parameter MODE_64x64 = 2'b10;		// 64x64 glyph
	
	// ###############################
	//  Screen Statuses
	// ###############################
	parameter MAIN_MENU = 2'b00;
	parameter IN_GAME = 2'b01;
	parameter GAME_OVER = 2'b10;
	
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
	
	parameter rgb_text 	 = 24'h343a40;
	parameter rgb_bg	 	 = 24'hf8f9fa;
	
	parameter rgb_p1_norm = 24'hbf1919;
	parameter rgb_p1_lite = 24'hff2121;
	assign	 rgb_p1 		 = p1Btn ? rgb_p1_lite : rgb_p1_norm; 
	
	parameter rgb_p2_norm = 24'h003fad;
	parameter rgb_p2_lite = 24'h005cfa;
	assign	 rgb_p2		 = p2Btn ? rgb_p2_lite : rgb_p2_norm;
	
	parameter rgb_p3_norm = 24'he6de09;
	parameter rgb_p3_lite = 24'hfff609;
	assign 	 rgb_p3		 = p3Btn ? rgb_p3_lite : rgb_p3_norm;
	
	parameter rgb_p4_norm = 24'h559C3A;
	parameter rgb_p4_lite = 24'h78dc52;
	assign	 rgb_p4		 = p4Btn ? rgb_p4_lite : rgb_p4_norm;
	
	
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
	parameter p_bg_x_start = 10'd150;
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
	parameter win1_x_start = 10'd210;
	parameter win2_x_start = 10'd370;
	parameter win3_x_start = 10'd530;
	parameter win4_x_start = 10'd690;
	parameter win_y_start  = 10'd270;
	
	
	// ###############################
	//  GAME OVER Glyphs
	// ###############################
	parameter over_x_start = 10'd200;
	parameter over_y_start = 10'd350;
	parameter over_x_dim = 10'd50;
	parameter over_y_dim = 10'd64;

	
	// ###############################
	//  START MENU Glyphs
	// ###############################
	parameter start_x_start = 10'd235;
	parameter start_y_start = 10'd100;
	parameter start_x_dim = 10'd50;
	parameter start_y_dim = 10'd64;	
	parameter start_r1offset = 10'd118;

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
	
	
		// ###############################
		//  BRIGHT
		// ###############################
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
		
		case (screenStatus)
		
			MAIN_MENU: begin
				// ###############################
				//  HEX DEFENDERS
				// ###############################
				if ((vcount >= start_y_start) && (vcount < (start_y_start + start_y_dim))) begin
					// H
					if ((hcount >= (start_x_start + start_r1offset)) && (hcount < (start_x_start + start_r1offset + start_x_dim))) begin
						gbval <= 6'd17;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + start_r1offset;
						x_end     <= start_x_start + start_r1offset + start_x_dim;
						y_start   <= start_y_start;
						y_end     <= start_y_start + start_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// E
					else if ((hcount >= (start_x_start + start_r1offset + start_x_dim)) && (hcount < (start_x_start + start_r1offset + 2*start_x_dim))) begin
						gbval <= 6'd14;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + start_r1offset + start_x_dim;
						x_end     <= start_x_start + start_r1offset + 2*start_x_dim;
						y_start   <= start_y_start;
						y_end     <= start_y_start + start_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// X
					else if ((hcount >= (start_x_start + start_r1offset + 2*start_x_dim)) && (hcount < (start_x_start + start_r1offset + 3*start_x_dim))) begin
						gbval <= 6'd33;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + start_r1offset + 2*start_x_dim;
						x_end     <= start_x_start + start_r1offset + 3*start_x_dim;
						y_start   <= start_y_start;
						y_end     <= start_y_start + start_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// shield
					else if ((hcount >= (start_x_start + start_r1offset + 3*start_x_dim)) && (hcount < (start_x_start + start_r1offset + 4*start_x_dim + 14))) begin
						gbval <= 6'd40;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + start_r1offset + 3*start_x_dim;
						x_end     <= start_x_start + start_r1offset + 4*start_x_dim + 14;
						y_start   <= start_y_start;
						y_end     <= start_y_start + start_y_dim;
						mode 		 <= MODE_64x64;
					end
				end
				else if ((vcount >= (start_y_start + start_y_dim)) && (vcount < (start_y_start + 2*start_y_dim))) begin
					// D
					if ((hcount >= (start_x_start)) && (hcount < (start_x_start + start_x_dim))) begin
						gbval <= 6'd13;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start;
						x_end     <= start_x_start + start_x_dim;
						y_start   <= start_y_start + start_y_dim;
						y_end     <= start_y_start + 2*start_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// E
					else if ((hcount >= (start_x_start + start_x_dim)) && (hcount < (start_x_start + 2*start_x_dim))) begin
						gbval <= 6'd14;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + start_x_dim;
						x_end     <= start_x_start + 2*start_x_dim;
						y_start   <= start_y_start + start_y_dim;
						y_end     <= start_y_start + 2*start_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// F
					else if ((hcount >= (start_x_start + 2*start_x_dim)) && (hcount < (start_x_start + 3*start_x_dim))) begin
						gbval <= 6'd15;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + 2*start_x_dim;
						x_end     <= start_x_start + 3*start_x_dim;
						y_start   <= start_y_start + start_y_dim;
						y_end     <= start_y_start + 2*start_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// E
					else if ((hcount >= (start_x_start + 3*start_x_dim)) && (hcount < (start_x_start + 4*start_x_dim))) begin
						gbval <= 6'd14;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + 3*start_x_dim;
						x_end     <= start_x_start + 4*start_x_dim;
						y_start   <= start_y_start + start_y_dim;
						y_end     <= start_y_start + 2*start_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// N
					else if ((hcount >= (start_x_start + 4*start_x_dim)) && (hcount < (start_x_start + 5*start_x_dim))) begin
						gbval <= 6'd23;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + 4*start_x_dim;
						x_end     <= start_x_start + 5*start_x_dim;
						y_start   <= start_y_start + start_y_dim;
						y_end     <= start_y_start + 2*start_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// D
					else if ((hcount >= (start_x_start + 5*start_x_dim)) && (hcount < (start_x_start + 6*start_x_dim))) begin
						gbval <= 6'd13;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + 5*start_x_dim;
						x_end     <= start_x_start + 6*start_x_dim;
						y_start   <= start_y_start + start_y_dim;
						y_end     <= start_y_start + 2*start_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// E
					else if ((hcount >= (start_x_start + 6*start_x_dim)) && (hcount < (start_x_start + 7*start_x_dim))) begin
						gbval <= 6'd14;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + 6*start_x_dim;
						x_end     <= start_x_start + 7*start_x_dim;
						y_start   <= start_y_start + start_y_dim;
						y_end     <= start_y_start + 2*start_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// R
					else if ((hcount >= (start_x_start + 7*start_x_dim)) && (hcount < (start_x_start + 8*start_x_dim))) begin
						gbval <= 6'd27;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + 7*start_x_dim;
						x_end     <= start_x_start + 8*start_x_dim;
						y_start   <= start_y_start + start_y_dim;
						y_end     <= start_y_start + 2*start_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// S
					else if ((hcount >= (start_x_start + 8*start_x_dim)) && (hcount < (start_x_start + 9*start_x_dim))) begin
						gbval <= 6'd28;
						
						rgb_color <= rgb_text;
						x_start   <= start_x_start + 8*start_x_dim;
						x_end     <= start_x_start + 9*start_x_dim;
						y_start   <= start_y_start + start_y_dim;
						y_end     <= start_y_start + 2*start_y_dim;
						mode 		 <= MODE_64x64;
					end
				end
			end
			
			IN_GAME: begin
				// ###############################
				//  PLAYER 1 glyphs
				// ###############################
				if ((vcount >= p_gl_y_start) && (vcount < (p_gl_y_start + p_y_dim))) begin
					// P
					if ((hcount >= (p1_gl_x_start)) && (hcount < (p1_gl_x_start + p_x_dim))) begin
						gval <= 6'd25;
						
						rgb_color <= rgb_text;
						x_start 	 <= p1_gl_x_start;
						x_end 	 <= p1_gl_x_start + p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
				
					// 1
					else if ((hcount >= p1_gl_x_start + p_x_dim) && (hcount < (p1_gl_x_start + 2*p_x_dim))) begin
						gval <= 6'h01;
						
						rgb_color <= rgb_text;
						x_start 	 <= p1_gl_x_start + p_x_dim;
						x_end 	 <= p1_gl_x_start + 2*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
				
					// :
					else if ((hcount >= p1_gl_x_start + 2*p_x_dim) && (hcount < (p1_gl_x_start + 3*p_x_dim))) begin
						gval <= 6'd38;
						
						rgb_color <= rgb_text;
						x_start 	 <= p1_gl_x_start + 2*p_x_dim;
						x_end 	 <= p1_gl_x_start + 3*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
					
					else if ((hcount >= p1_gl_x_start + 3*p_x_dim) && (hcount < (p1_gl_x_start + 4*p_x_dim))) begin
						gval <= p1;
						
						rgb_color <= rgb_text;
						x_start 	 <= p1_gl_x_start + 3*p_x_dim;
						x_end 	 <= p1_gl_x_start + 4*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
				
				// ###############################
				//  PLAYER 2 glyphs
				// ###############################
					// P
					else if ((hcount >= p2_gl_x_start) && (hcount < (p2_gl_x_start + p_x_dim))) begin
						gval <= 6'd25;
						
						rgb_color <= rgb_text;
						x_start 	 <= p2_gl_x_start;
						x_end 	 <= p2_gl_x_start + p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
				
					// 2
					else if ((hcount >= p2_gl_x_start + p_x_dim) && (hcount < (p2_gl_x_start + 2*p_x_dim))) begin
						gval <= 6'h02;
						
						rgb_color <= rgb_text;
						x_start 	 <= p2_gl_x_start + p_x_dim;
						x_end 	 <= p2_gl_x_start + 2*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
				
					// :
					else if ((hcount >= p2_gl_x_start + 2*p_x_dim) && (hcount < (p2_gl_x_start + 3*p_x_dim))) begin
						gval <= 6'd38;
						
						rgb_color <= rgb_text;
						x_start 	 <= p2_gl_x_start + 2*p_x_dim;
						x_end 	 <= p2_gl_x_start + 3*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
					
					else if ((hcount >= p2_gl_x_start + 3*p_x_dim) && (hcount < (p2_gl_x_start + 4*p_x_dim))) begin
						gval <= p2;
						
						rgb_color <= rgb_text;
						x_start 	 <= p2_gl_x_start + 3*p_x_dim;
						x_end 	 <= p2_gl_x_start + 4*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
					
				// ###############################
				//  PLAYER 3 glyphs
				// ###############################
					// P
					else if ((hcount >= p3_gl_x_start) && (hcount < (p3_gl_x_start + p_x_dim))) begin
						gval <= 6'd25;
						
						rgb_color <= rgb_text;
						x_start 	 <= p3_gl_x_start;
						x_end 	 <= p3_gl_x_start + p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
				
					// 3
					else if ((hcount >= p3_gl_x_start + p_x_dim) && (hcount < (p3_gl_x_start + 2*p_x_dim))) begin
						gval <= 6'h03;
						
						rgb_color <= rgb_text;
						x_start 	 <= p3_gl_x_start + p_x_dim;
						x_end 	 <= p3_gl_x_start + 2*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
				
					// :
					else if ((hcount >= p3_gl_x_start + 2*p_x_dim) && (hcount < (p3_gl_x_start + 3*p_x_dim))) begin
						gval <= 6'd38;
						
						rgb_color <= rgb_text;
						x_start 	 <= p3_gl_x_start + 2*p_x_dim;
						x_end 	 <= p3_gl_x_start + 3*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
					
					else if ((hcount >= p3_gl_x_start + 3*p_x_dim) && (hcount < (p3_gl_x_start + 4*p_x_dim))) begin
						gval <= p3;
						
						rgb_color <= rgb_text;
						x_start 	 <= p3_gl_x_start + 3*p_x_dim;
						x_end 	 <= p3_gl_x_start + 4*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
					
				// ###############################
				//  PLAYER 4 glyphs
				// ###############################
					// P
					else if ((hcount >= p4_gl_x_start) && (hcount < (p4_gl_x_start + p_x_dim))) begin
						gval <= 6'd25;
						
						rgb_color <= rgb_text;
						x_start 	 <= p4_gl_x_start;
						x_end 	 <= p4_gl_x_start + p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
				
					// 4
					else if ((hcount >= p4_gl_x_start + p_x_dim) && (hcount < (p4_gl_x_start + 2*p_x_dim))) begin
						gval <= 6'h4;
						
						rgb_color <= rgb_text;
						x_start 	 <= p4_gl_x_start + p_x_dim;
						x_end 	 <= p4_gl_x_start + 2*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
				
					// :
					else if ((hcount >= p4_gl_x_start + 2*p_x_dim) && (hcount < (p4_gl_x_start + 3*p_x_dim))) begin
						gval <= 6'd38;
						
						rgb_color <= rgb_text;
						x_start 	 <= p4_gl_x_start + 2*p_x_dim;
						x_end 	 <= p4_gl_x_start + 3*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
					
					else if ((hcount >= p4_gl_x_start + 3*p_x_dim) && (hcount < (p4_gl_x_start + 4*p_x_dim))) begin
						gval <= p4;
						
						rgb_color <= rgb_text;
						x_start 	 <= p4_gl_x_start + 3*p_x_dim;
						x_end 	 <= p4_gl_x_start + 4*p_x_dim;
						y_start	 <= p_gl_y_start;
						y_end 	 <= p_gl_y_start + p_y_dim;
						mode		 <= MODE_8x8;
					end
				end
			
				// ###############################
				//  MAIN VALUE
				// ###############################
				if ((vcount >= main_y_start) && (vcount < (main_y_start + main_y_dim))) begin
					// 0
					if ((hcount >= main_x_start) && (hcount < (main_x_start + main_x_dim))) begin
						gbval <= 6'h0;
						
						rgb_color <= rgb_text;
						x_start   <= main_x_start;
						x_end     <= main_x_start + main_x_dim;
						y_start   <= main_y_start;
						y_end     <= main_y_start + main_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// x
					else if ((hcount >= (main_x_start + main_x_dim)) && (hcount < (main_x_start + main_x_dim + main_x_dim))) begin
						gbval <= 6'd37;
						
						rgb_color <= rgb_text;
						x_start   <= main_x_start + main_x_dim;
						x_end     <= main_x_start + main_x_dim + main_x_dim;
						y_start   <= main_y_start;
						y_end     <= main_y_start + main_y_dim;
						mode 		 <= MODE_64x64;
					end
					
					// hex1
					else if ((hcount >= (main_x_start + 2*main_x_dim)) && (hcount < (main_x_start + 3*main_x_dim))) begin
						gbval <= value[7:4];
						
						rgb_color <= rgb_text;
						x_start   <= main_x_start + 2*main_x_dim;
						x_end     <= main_x_start + 3*main_x_dim;
						y_start   <= main_y_start;
						y_end     <= main_y_start + main_y_dim;
						mode		 <= MODE_64x64;
						
					end
					
					// hex0
					else if ((hcount >= (main_x_start + 3*main_x_dim)) && (hcount < (main_x_start + 4*main_x_dim))) begin
						gbval <= value[3:0];
						
						rgb_color <= rgb_text;
						x_start   <= main_x_start + 3*main_x_dim;
						x_end     <= main_x_start + 4*main_x_dim;
						y_start   <= main_y_start;
						y_end     <= main_y_start + 2*main_y_dim;
						mode		 <= MODE_64x64;
					end
				end
			end
			
			GAME_OVER: begin
				if ((vcount >= win_y_start) && (vcount < (win_y_start + p_y_dim))) begin
					case (winnerPlayerNum)
						2'b00: begin
							// W
							if ((hcount >= (win1_x_start)) && (hcount < (win1_x_start + p_x_dim))) begin
								gval <= 6'd33;
								
								rgb_color <= rgb_text;
								x_start 	 <= win1_x_start;
								x_end 	 <= win1_x_start + p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// I
							else if ((hcount >= (win1_x_start + p_x_dim)) && (hcount < (win1_x_start + 2*p_x_dim))) begin
								gval <= 6'd18;
								
								rgb_color <= rgb_text;
								x_start 	 <= win1_x_start + p_x_dim;
								x_end 	 <= win1_x_start + 2*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// N
							else if ((hcount >= (win1_x_start + 2*p_x_dim)) && (hcount < (win1_x_start + 3*p_x_dim))) begin
								gval <= 6'd23;
								
								rgb_color <= rgb_text;
								x_start 	 <= win1_x_start + 2*p_x_dim;
								x_end 	 <= win1_x_start + 3*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// N
							else if ((hcount >= (win1_x_start + 3*p_x_dim)) && (hcount < (win1_x_start + 4*p_x_dim))) begin
								gval <= 6'd23;
								
								rgb_color <= rgb_text;
								x_start 	 <= win1_x_start + 3*p_x_dim;
								x_end 	 <= win1_x_start + 4*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// E
							else if ((hcount >= (win1_x_start + 4*p_x_dim)) && (hcount < (win1_x_start + 5*p_x_dim))) begin
								gval <= 6'he;
								
								rgb_color <= rgb_text;
								x_start 	 <= win1_x_start + 4*p_x_dim;
								x_end 	 <= win1_x_start + 5*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// R
							else if ((hcount >= (win1_x_start + 5*p_x_dim)) && (hcount < (win1_x_start + 6*p_x_dim))) begin
								gval <= 6'd28;
								
								rgb_color <= rgb_text;
								x_start 	 <= win1_x_start + 5*p_x_dim;
								x_end 	 <= win1_x_start + 6*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
						end
						
						2'b01: begin
							// W
							if ((hcount >= (win2_x_start)) && (hcount < (win2_x_start + p_x_dim))) begin
								gval <= 6'd33;
								
								rgb_color <= rgb_text;
								x_start 	 <= win2_x_start;
								x_end 	 <= win2_x_start + p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// I
							else if ((hcount >= (win2_x_start + p_x_dim)) && (hcount < (win2_x_start + 2*p_x_dim))) begin
								gval <= 6'd18;
								
								rgb_color <= rgb_text;
								x_start 	 <= win2_x_start + p_x_dim;
								x_end 	 <= win2_x_start + 2*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// N
							else if ((hcount >= (win2_x_start + 2*p_x_dim)) && (hcount < (win2_x_start + 3*p_x_dim))) begin
								gval <= 6'd23;
								
								rgb_color <= rgb_text;
								x_start 	 <= win2_x_start + 2*p_x_dim;
								x_end 	 <= win2_x_start + 3*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// N
							else if ((hcount >= (win2_x_start + 3*p_x_dim)) && (hcount < (win2_x_start + 4*p_x_dim))) begin
								gval <= 6'd23;
								
								rgb_color <= rgb_text;
								x_start 	 <= win2_x_start + 3*p_x_dim;
								x_end 	 <= win2_x_start + 4*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// E
							else if ((hcount >= (win2_x_start + 4*p_x_dim)) && (hcount < (win2_x_start + 5*p_x_dim))) begin
								gval <= 6'he;
								
								rgb_color <= rgb_text;
								x_start 	 <= win2_x_start + 4*p_x_dim;
								x_end 	 <= win2_x_start + 5*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// R
							else if ((hcount >= (win2_x_start + 5*p_x_dim)) && (hcount < (win2_x_start + 6*p_x_dim))) begin
								gval <= 6'd28;
								
								rgb_color <= rgb_text;
								x_start 	 <= win2_x_start + 5*p_x_dim;
								x_end 	 <= win2_x_start + 6*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
						end
						
						2'b10: begin
							// W
							if ((hcount >= (win3_x_start)) && (hcount < (win3_x_start + p_x_dim))) begin
								gval <= 6'd33;
								
								rgb_color <= rgb_text;
								x_start 	 <= win3_x_start;
								x_end 	 <= win3_x_start + p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// I
							else if ((hcount >= (win3_x_start + p_x_dim)) && (hcount < (win3_x_start + 2*p_x_dim))) begin
								gval <= 6'd18;
								
								rgb_color <= rgb_text;
								x_start 	 <= win3_x_start + p_x_dim;
								x_end 	 <= win3_x_start + 2*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// N
							else if ((hcount >= (win3_x_start + 2*p_x_dim)) && (hcount < (win3_x_start + 3*p_x_dim))) begin
								gval <= 6'd23;
								
								rgb_color <= rgb_text;
								x_start 	 <= win3_x_start + 2*p_x_dim;
								x_end 	 <= win3_x_start + 3*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// N
							else if ((hcount >= (win3_x_start + 3*p_x_dim)) && (hcount < (win3_x_start + 4*p_x_dim))) begin
								gval <= 6'd23;
								
								rgb_color <= rgb_text;
								x_start 	 <= win3_x_start + 3*p_x_dim;
								x_end 	 <= win3_x_start + 4*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// E
							else if ((hcount >= (win3_x_start + 4*p_x_dim)) && (hcount < (win3_x_start + 5*p_x_dim))) begin
								gval <= 6'he;
								
								rgb_color <= rgb_text;
								x_start 	 <= win3_x_start + 4*p_x_dim;
								x_end 	 <= win3_x_start + 5*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// R
							else if ((hcount >= (win3_x_start + 5*p_x_dim)) && (hcount < (win3_x_start + 6*p_x_dim))) begin
								gval <= 6'd28;
								
								rgb_color <= rgb_text;
								x_start 	 <= win3_x_start + 5*p_x_dim;
								x_end 	 <= win3_x_start + 6*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
						end
						
						2'b11: begin
							// W
							if ((hcount >= (win4_x_start)) && (hcount < (win4_x_start + p_x_dim))) begin
								gval <= 6'd33;
								
								rgb_color <= rgb_text;
								x_start 	 <= win4_x_start;
								x_end 	 <= win4_x_start + p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// I
							else if ((hcount >= (win4_x_start + p_x_dim)) && (hcount < (win4_x_start + 2*p_x_dim))) begin
								gval <= 6'd18;
								
								rgb_color <= rgb_text;
								x_start 	 <= win4_x_start + p_x_dim;
								x_end 	 <= win4_x_start + 2*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// N
							else if ((hcount >= (win4_x_start + 2*p_x_dim)) && (hcount < (win4_x_start + 3*p_x_dim))) begin
								gval <= 6'd23;
								
								rgb_color <= rgb_text;
								x_start 	 <= win4_x_start + 2*p_x_dim;
								x_end 	 <= win4_x_start + 3*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// N
							else if ((hcount >= (win4_x_start + 3*p_x_dim)) && (hcount < (win4_x_start + 4*p_x_dim))) begin
								gval <= 6'd23;
								
								rgb_color <= rgb_text;
								x_start 	 <= win4_x_start + 3*p_x_dim;
								x_end 	 <= win4_x_start + 4*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// E
							else if ((hcount >= (win4_x_start + 4*p_x_dim)) && (hcount < (win4_x_start + 5*p_x_dim))) begin
								gval <= 6'he;
								
								rgb_color <= rgb_text;
								x_start 	 <= win4_x_start + 4*p_x_dim;
								x_end 	 <= win4_x_start + 5*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
							// R
							else if ((hcount >= (win4_x_start + 5*p_x_dim)) && (hcount < (win4_x_start + 6*p_x_dim))) begin
								gval <= 6'd28;
								
								rgb_color <= rgb_text;
								x_start 	 <= win4_x_start + 5*p_x_dim;
								x_end 	 <= win4_x_start + 6*p_x_dim;
								y_start	 <= win_y_start;
								y_end 	 <= win_y_start + p_y_dim;
								mode		 <= MODE_8x8;
							end
						end
						
						default: begin
							gbval <= 0;
							rgb_color <= rgb_bg;
							x_start   <= 0;
							x_end     <= 0;
							y_start   <= 0;
							y_end     <= 0;
							mode		 <= 0;
						end
					endcase
				end
				
				if ((vcount >= over_y_start) && (vcount < (over_y_start + over_y_dim))) begin
					// G
					if ((hcount >= (over_x_start)) && (hcount < (over_x_start + over_x_dim))) begin
						gbval <= 6'd16;
						
						rgb_color <= rgb_text;
						x_start 	 <= over_x_start;
						x_end 	 <= over_x_start + over_x_dim;
						y_start	 <= over_y_start;
						y_end 	 <= over_y_start + main_y_dim;
						mode		 <= MODE_64x64;
					end
					
					// A
					else if ((hcount >= (over_x_start + over_x_dim)) && (hcount < (over_x_start + 2*over_x_dim))) begin
						gbval <= 6'ha;
						
						rgb_color <= rgb_text;
						x_start 	 <= over_x_start + over_x_dim;
						x_end 	 <= over_x_start + 2*over_x_dim;
						y_start	 <= over_y_start;
						y_end 	 <= over_y_start + main_y_dim;
						mode		 <= MODE_64x64;
					end
					
					// M
					else if ((hcount >= (over_x_start + 2*over_x_dim)) && (hcount < (over_x_start + 3*over_x_dim))) begin
						gbval <= 6'd22;
						
						rgb_color <= rgb_text;
						x_start 	 <= over_x_start + 2*over_x_dim;
						x_end 	 <= over_x_start + 3*over_x_dim;
						y_start	 <= over_y_start;
						y_end 	 <= over_y_start + main_y_dim;
						mode		 <= MODE_64x64;
					end
					
					// E
					else if ((hcount >= (over_x_start + 3*over_x_dim)) && (hcount < (over_x_start + 4*over_x_dim))) begin
						gbval <= 6'he;
						
						rgb_color <= rgb_text;
						x_start 	 <= over_x_start + 3*over_x_dim;
						x_end 	 <= over_x_start + 4*over_x_dim;
						y_start	 <= over_y_start;
						y_end 	 <= over_y_start + main_y_dim;
						mode		 <= MODE_64x64;
					end
					
					// O
					else if ((hcount >= (over_x_start + 5*over_x_dim)) && (hcount < (over_x_start + 6*over_x_dim))) begin
						gbval <= 6'd24;
						
						rgb_color <= rgb_text;
						x_start 	 <= over_x_start + 5*over_x_dim;
						x_end 	 <= over_x_start + 6*over_x_dim;
						y_start	 <= over_y_start;
						y_end 	 <= over_y_start + main_y_dim;
						mode		 <= MODE_64x64;
					end
					
					// V
					else if ((hcount >= (over_x_start + 6*over_x_dim)) && (hcount < (over_x_start + 7*over_x_dim))) begin
						gbval <= 6'd31;
						
						rgb_color <= rgb_text;
						x_start 	 <= over_x_start + 6*over_x_dim;
						x_end 	 <= over_x_start + 7*over_x_dim;
						y_start	 <= over_y_start;
						y_end 	 <= over_y_start + main_y_dim;
						mode		 <= MODE_64x64;
					end
					
					// E
					else if ((hcount >= (over_x_start + 7*over_x_dim)) && (hcount < (over_x_start + 8*over_x_dim))) begin
						gbval <= 6'he;
						
						rgb_color <= rgb_text;
						x_start 	 <= over_x_start + 7*over_x_dim;
						x_end 	 <= over_x_start + 8*over_x_dim;
						y_start	 <= over_y_start;
						y_end 	 <= over_y_start + main_y_dim;
						mode		 <= MODE_64x64;
					end
					
					// R
					else if ((hcount >= (over_x_start + 8*over_x_dim)) && (hcount < (over_x_start + 9*over_x_dim))) begin
						gbval <= 6'd27;
						
						rgb_color <= rgb_text;
						x_start 	 <= over_x_start + 8*over_x_dim;
						x_end 	 <= over_x_start + 9*over_x_dim;
						y_start	 <= over_y_start;
						y_end 	 <= over_y_start + main_y_dim;
						mode		 <= MODE_64x64;
					end
					
					// !
					else if ((hcount >= (over_x_start + 9*over_x_dim)) && (hcount < (over_x_start + 10*over_x_dim))) begin
						gbval <= 6'd39;
						
						rgb_color <= rgb_text;
						x_start 	 <= over_x_start + 9*over_x_dim;
						x_end 	 <= over_x_start + 10*over_x_dim;
						y_start	 <= over_y_start;
						y_end 	 <= over_y_start + main_y_dim;
						mode		 <= MODE_64x64;
					end
				end
			end
			
			default: begin
				gbval <= 0;
				rgb_color <= rgb_bg;
				x_start   <= 0;
				x_end     <= 0;
				y_start   <= 0;
				y_end     <= 0;
				mode		 <= 0;
			end
		
		endcase
		
		// ###############################
		//  BANNERS
		// ###############################
		if ((vcount >= p_bg_y_start) && (vcount < (p_bg_y_start + p_bg_y_dim))) begin
			// Player 1 (red) 
			if ((hcount >= p_bg_x_start) && (hcount < (p_bg_x_start + p_bg_x_dim))) begin
				rgb_color <= rgb_p1;
				x_start   <= p_bg_x_start;
				x_end     <= p_bg_x_start + p_bg_x_dim;
				y_start   <= p_bg_y_start;
				y_end     <= p_bg_y_start + p_bg_y_dim;
				mode		 <= MODE_BG;
			end
		
			// Player 2 (blue) 
			else if ((hcount >= p_bg_x_start + p_bg_x_dim) && (hcount < (p_bg_x_start + 2*p_bg_x_dim))) begin
				rgb_color <= rgb_p2;
				x_start   <= p_bg_x_start + p_bg_x_dim;
				x_end     <= p_bg_x_start + 2*p_bg_x_dim;
				y_start   <= p_bg_y_start;
				y_end     <= p_bg_y_start + p_bg_y_dim;
				mode		 <= MODE_BG;
			end
			
			// Player 3 (yellow)
			else if ((hcount >= p_bg_x_start + 2*p_bg_x_dim) && (hcount < (p_bg_x_start + 3*p_bg_x_dim))) begin
				rgb_color <= rgb_p3;
				x_start   <= p_bg_x_start + 2*p_bg_x_dim;
				x_end     <= p_bg_x_start + 3*p_bg_x_dim;
				y_start   <= p_bg_y_start;
				y_end     <= p_bg_y_start + p_bg_y_dim;
				mode		 <= MODE_BG;
			end
			
			// Player 4 (green)
			else if ((hcount >= p_bg_x_start + 3*p_bg_x_dim) && (hcount < (p_bg_x_start + 4*p_bg_x_dim))) begin
				rgb_color <= rgb_p4;
				x_start   <= p_bg_x_start + 3*p_bg_x_dim;
				x_end     <= p_bg_x_start + 4*p_bg_x_dim;
				y_start   <= p_bg_y_start;
				y_end     <= p_bg_y_start + p_bg_y_dim;
				mode		 <= MODE_BG;
			end
		end // end banners
	end
	
endmodule
