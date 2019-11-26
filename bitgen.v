module bitgen(bright, hcount, vcount, glyph, bglyph, mode, x_start, x_end, y_start, y_end, rgb_color, rgb);
	input  			     bright;
	input		  [1:0]	  mode;
	input  	  [9:0]    hcount, vcount, x_start, x_end, y_start, y_end;
	input  	  [63:0]   glyph;
	input 	  [4095:0] bglyph;
	input		  [23:0]   rgb_color;
	output reg [23:0]   rgb;
	
	reg [23:0] rgbout;
	reg [9:0]  xoffset, yoffset;
	
	// ###############################
	//  Small Font configurations
	// ###############################
	
	wire [7:0] lglyph [7:0];
	assign lglyph[0] = glyph[63:56];
	assign lglyph[1] = glyph[55:48];
	assign lglyph[2] = glyph[47:40];
	assign lglyph[3] = glyph[39:32];
	assign lglyph[4] = glyph[31:24];
	assign lglyph[5] = glyph[23:16];
	assign lglyph[6] = glyph[15:8];
	assign lglyph[7] = glyph[7:0];
	
	// ###############################
	//  Large Font configurations
	// ###############################
	
	wire [0:63] lbglyph [63:0];
	assign lbglyph[0] = bglyph[4095:4032];
	assign lbglyph[1] = bglyph[4031:3968];
	assign lbglyph[2] = bglyph[3967:3904];
	assign lbglyph[3] = bglyph[3903:3840];
	assign lbglyph[4] = bglyph[3839:3776];
	assign lbglyph[5] = bglyph[3775:3712];
	assign lbglyph[6] = bglyph[3711:3648];
	assign lbglyph[7] = bglyph[3647:3584];
	assign lbglyph[8] = bglyph[3583:3520];
	assign lbglyph[9] = bglyph[3519:3456];
	assign lbglyph[10] = bglyph[3455:3392];
	assign lbglyph[11] = bglyph[3391:3328];
	assign lbglyph[12] = bglyph[3327:3264];
	assign lbglyph[13] = bglyph[3263:3200];
	assign lbglyph[14] = bglyph[3199:3136];
	assign lbglyph[15] = bglyph[3135:3072];
	assign lbglyph[16] = bglyph[3071:3008];
	assign lbglyph[17] = bglyph[3007:2944];
	assign lbglyph[18] = bglyph[2943:2880];
	assign lbglyph[19] = bglyph[2879:2816];
	assign lbglyph[20] = bglyph[2815:2752];
	assign lbglyph[21] = bglyph[2751:2688];
	assign lbglyph[22] = bglyph[2687:2624];
	assign lbglyph[23] = bglyph[2623:2560];
	assign lbglyph[24] = bglyph[2559:2496];
	assign lbglyph[25] = bglyph[2495:2432];
	assign lbglyph[26] = bglyph[2431:2368];
	assign lbglyph[27] = bglyph[2367:2304];
	assign lbglyph[28] = bglyph[2303:2240];
	assign lbglyph[29] = bglyph[2239:2176];
	assign lbglyph[30] = bglyph[2175:2112];
	assign lbglyph[31] = bglyph[2111:2048];
	assign lbglyph[32] = bglyph[2047:1984];
	assign lbglyph[33] = bglyph[1983:1920];
	assign lbglyph[34] = bglyph[1919:1856];
	assign lbglyph[35] = bglyph[1855:1792];
	assign lbglyph[36] = bglyph[1791:1728];
	assign lbglyph[37] = bglyph[1727:1664];
	assign lbglyph[38] = bglyph[1663:1600];
	assign lbglyph[39] = bglyph[1599:1536];
	assign lbglyph[40] = bglyph[1535:1472];
	assign lbglyph[41] = bglyph[1471:1408];
	assign lbglyph[42] = bglyph[1407:1344];
	assign lbglyph[43] = bglyph[1343:1280];
	assign lbglyph[44] = bglyph[1279:1216];
	assign lbglyph[45] = bglyph[1215:1152];
	assign lbglyph[46] = bglyph[1151:1088];
	assign lbglyph[47] = bglyph[1087:1024];
	assign lbglyph[48] = bglyph[1023:960];
	assign lbglyph[49] = bglyph[959:896];
	assign lbglyph[50] = bglyph[895:832];
	assign lbglyph[51] = bglyph[831:768];
	assign lbglyph[52] = bglyph[767:704];
	assign lbglyph[53] = bglyph[703:640];
	assign lbglyph[54] = bglyph[639:576];
	assign lbglyph[55] = bglyph[575:512];
	assign lbglyph[56] = bglyph[511:448];
	assign lbglyph[57] = bglyph[447:384];
	assign lbglyph[58] = bglyph[383:320];
	assign lbglyph[59] = bglyph[319:256];
	assign lbglyph[60] = bglyph[255:192];
	assign lbglyph[61] = bglyph[191:128];
	assign lbglyph[62] = bglyph[127:64];
	assign lbglyph[63] = bglyph[63:0];
	
	// ###############################
	//  Colors
	// ###############################	
	
	parameter rgb_bg = 24'hf8f9fa;
	
	always @(*) begin
		rgbout <= rgb_bg;
		
		if (vcount >= y_start && vcount < y_end) begin
			if (hcount >= x_start && hcount < x_end) begin
				case (mode) 
					// Background
					2'b00:	rgbout <= rgb_color;
					
					// 8x8 text
					2'b01: begin
						if (lglyph[vcount-y_start][hcount-x_start] == 1'b1)
							rgbout <= rgb_color;
					end
					
					// 64x64 text
					2'b10: begin
						if (lbglyph[vcount-y_start][hcount-x_start] == 1'b1)
							rgbout <= rgb_color;
					end
					
					default:	rgbout <= rgb_color;
				endcase
			end
		end
		
		if (bright)
			rgb <= rgbout;
		else
			rgb <= rgb_bg;
	end
	
endmodule
