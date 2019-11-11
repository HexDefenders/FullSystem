module switch_tester(bright, btn, switches, hcount, vcount, rgb);
	input					bright, btn;
	input 	  [7:0] 	switches;
	input 	  [9:0]  hcount, vcount;
	output reg [23:0] rgb;
	
	reg [23:0] rgbout;
	
	parameter rgb_bg    = 24'hf8f9fa;
	parameter rgb_swon  = 24'hdc3545;
	parameter rgb_swoff = 24'h6c757d;
	
	parameter size = 10'd20;
	parameter x_start = 10'd200;
	parameter y_start = 10'd200;
	parameter offset = 10'd50;
	
	always @(*) begin
		rgbout <= rgb_bg;
		
		// switch 0
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= x_start && hcount < (x_start + size))
				if (switches[7])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
	
		
		// switch 1
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + offset + size) && hcount < (x_start + offset + 2*size))
				if (switches[6])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 2
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 2*offset + 2*size) && hcount < (x_start + 2*offset + 3*size))
				if (switches[5])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		
		// switch 3
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 3*offset + 3*size) && hcount < (x_start + 3*offset + 4*size))
				if (switches[4])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 4
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 4*offset + 4*size) && hcount < (x_start + 4*offset + 5*size))
				if (switches[3])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 5
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 5*offset + 5*size) && hcount < (x_start + 5*offset + 6*size))
				if (switches[2])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;			
		
		// switch 6
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 6*offset + 6*size) && hcount < (x_start + 6*offset + 7*size))
				if (switches[1])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// switch 7
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 7*offset + 7*size) && hcount < (x_start + 7*offset + 8*size))
				if (switches[0])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// button
		if (vcount >= (y_start + 2*size) && vcount < (y_start + 3*size))
			if (hcount >= x_start && hcount < (x_start + 7*offset + 8*size))
				if (btn)
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;

		if (bright)
			rgb <= rgbout;
		else
			rgb <= rgb_bg;
	
	end

endmodule
