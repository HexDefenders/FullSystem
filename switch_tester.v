module switch_tester(clk, rst, bright, gpins, hcount, vcount, rgb);
	input					clk, rst, bright;
	input 	  [40:1] gpins;
	input 	  [9:0]  hcount, vcount;
	output reg [23:0] rgb;
	
	reg [23:0] rgbout;
	
	// Players Input Mapping
	wire [7:0] p1_sw, p2_sw, p3_sw, p4_sw;
	wire p1_btn, p2_btn, p3_btn, p4_btn;
	
	assign p1_sw = {gpins[35],gpins[21],gpins[33],gpins[23],gpins[31],gpins[25],gpins[39],gpins[27]};
	assign p1_btn = gpins[37];
	
	assign p2_sw = {gpins[36],gpins[34],gpins[38],gpins[32],gpins[40],gpins[28],gpins[22],gpins[26]};
	assign p2_btn = gpins[24];
	
	assign p3_sw = {gpins[6],gpins[4],gpins[8],gpins[2],gpins[10],gpins[20],gpins[14],gpins[18]};
	assign p3_btn = gpins[16];
	
	assign p4_sw = {gpins[1],gpins[15],gpins[3],gpins[17],gpins[5],gpins[19],gpins[7],gpins[13]};
	assign p4_btn = gpins[9];
	
	parameter rgb_bg    = 24'hf8f9fa;
	parameter rgb_swon  = 24'hdc3545;
	parameter rgb_swoff = 24'h6c757d;
	
	parameter size = 10'd20;
	parameter x_start = 10'd220;
	parameter y_start = 10'd50;
	parameter offset = 10'd50;
	
	always @(*) begin
		rgbout <= rgb_bg;
		
		// CONTROLLER 1
		
		// switch 0
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= x_start && hcount < (x_start + size))
				if (p1_sw[7])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
	
		
		// switch 1
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + offset + size) && hcount < (x_start + offset + 2*size))
				if (p1_sw[6])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 2
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 2*offset + 2*size) && hcount < (x_start + 2*offset + 3*size))
				if (p1_sw[5])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		
		// switch 3
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 3*offset + 3*size) && hcount < (x_start + 3*offset + 4*size))
				if (p1_sw[4])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 4
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 4*offset + 4*size) && hcount < (x_start + 4*offset + 5*size))
				if (p1_sw[3])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 5
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 5*offset + 5*size) && hcount < (x_start + 5*offset + 6*size))
				if (p1_sw[2])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;			
		
		// switch 6
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 6*offset + 6*size) && hcount < (x_start + 6*offset + 7*size))
				if (p1_sw[1])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// switch 7
		if (vcount >= y_start && vcount < (y_start + size))
			if (hcount >= (x_start + 7*offset + 7*size) && hcount < (x_start + 7*offset + 8*size))
				if (p1_sw[0])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// button
		if (vcount >= (y_start + 2*size) && vcount < (y_start + 3*size))
			if (hcount >= x_start && hcount < (x_start + 7*offset + 8*size))
				if (p1_btn)
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		// CONTROLLER 2
		
		// switch 0
		if (vcount >= (y_start + 5*size) && vcount < (y_start + 6*size))
			if (hcount >= x_start && hcount < (x_start + size))
				if (p2_sw[7])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
	
		
		// switch 1
		if (vcount >= (y_start + 5*size) && vcount < (y_start + 6*size))
			if (hcount >= (x_start + offset + size) && hcount < (x_start + offset + 2*size))
				if (p2_sw[6])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 2
		if (vcount >= (y_start + 5*size) && vcount < (y_start + 6*size))
			if (hcount >= (x_start + 2*offset + 2*size) && hcount < (x_start + 2*offset + 3*size))
				if (p2_sw[5])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		
		// switch 3
		if (vcount >= (y_start + 5*size) && vcount < (y_start + 6*size))
			if (hcount >= (x_start + 3*offset + 3*size) && hcount < (x_start + 3*offset + 4*size))
				if (p2_sw[4])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 4
		if (vcount >= (y_start + 5*size) && vcount < (y_start + 6*size))
			if (hcount >= (x_start + 4*offset + 4*size) && hcount < (x_start + 4*offset + 5*size))
				if (p2_sw[3])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 5
		if (vcount >= (y_start + 5*size) && vcount < (y_start + 6*size))
			if (hcount >= (x_start + 5*offset + 5*size) && hcount < (x_start + 5*offset + 6*size))
				if (p2_sw[2])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;			
		
		// switch 6
		if (vcount >= (y_start + 5*size) && vcount < (y_start + 6*size))
			if (hcount >= (x_start + 6*offset + 6*size) && hcount < (x_start + 6*offset + 7*size))
				if (p2_sw[1])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// switch 7
		if (vcount >= (y_start + 5*size) && vcount < (y_start + 6*size))
			if (hcount >= (x_start + 7*offset + 7*size) && hcount < (x_start + 7*offset + 8*size))
				if (p2_sw[0])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// button
		if (vcount >= (y_start + 7*size) && vcount < (y_start + 8*size))
			if (hcount >= x_start && hcount < (x_start + 7*offset + 8*size))
				if (p2_btn)
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// CONTROLLER 3
		
		// switch 0
		if (vcount >= (y_start + 10*size) && vcount < (y_start + 11*size))
			if (hcount >= x_start && hcount < (x_start + size))
				if (p3_sw[7])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
	
		
		// switch 1
		if (vcount >= (y_start + 10*size) && vcount < (y_start + 11*size))
			if (hcount >= (x_start + offset + size) && hcount < (x_start + offset + 2*size))
				if (p3_sw[6])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 2
		if (vcount >= (y_start + 10*size) && vcount < (y_start + 11*size))
			if (hcount >= (x_start + 2*offset + 2*size) && hcount < (x_start + 2*offset + 3*size))
				if (p3_sw[5])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		
		// switch 3
		if (vcount >= (y_start + 10*size) && vcount < (y_start + 11*size))
			if (hcount >= (x_start + 3*offset + 3*size) && hcount < (x_start + 3*offset + 4*size))
				if (p3_sw[4])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 4
		if (vcount >= (y_start + 10*size) && vcount < (y_start + 11*size))
			if (hcount >= (x_start + 4*offset + 4*size) && hcount < (x_start + 4*offset + 5*size))
				if (p3_sw[3])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 5
		if (vcount >= (y_start + 10*size) && vcount < (y_start + 11*size))
			if (hcount >= (x_start + 5*offset + 5*size) && hcount < (x_start + 5*offset + 6*size))
				if (p3_sw[2])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;			
		
		// switch 6
		if (vcount >= (y_start + 10*size) && vcount < (y_start + 11*size))
			if (hcount >= (x_start + 6*offset + 6*size) && hcount < (x_start + 6*offset + 7*size))
				if (p3_sw[1])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// switch 7
		if (vcount >= (y_start + 10*size) && vcount < (y_start + 11*size))
			if (hcount >= (x_start + 7*offset + 7*size) && hcount < (x_start + 7*offset + 8*size))
				if (p3_sw[0])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// button
		if (vcount >= (y_start + 12*size) && vcount < (y_start + 13*size))
			if (hcount >= x_start && hcount < (x_start + 7*offset + 8*size))
				if (p3_btn)
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// CONTROLLER 4
		
		// switch 0
		if (vcount >= (y_start + 15*size) && vcount < (y_start + 16*size))
			if (hcount >= x_start && hcount < (x_start + size))
				if (p4_sw[7])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
	
		
		// switch 1
		if (vcount >= (y_start + 15*size) && vcount < (y_start + 16*size))
			if (hcount >= (x_start + offset + size) && hcount < (x_start + offset + 2*size))
				if (p4_sw[6])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 2
		if (vcount >= (y_start + 15*size) && vcount < (y_start + 16*size))
			if (hcount >= (x_start + 2*offset + 2*size) && hcount < (x_start + 2*offset + 3*size))
				if (p4_sw[5])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		
		// switch 3
		if (vcount >= (y_start + 15*size) && vcount < (y_start + 16*size))
			if (hcount >= (x_start + 3*offset + 3*size) && hcount < (x_start + 3*offset + 4*size))
				if (p4_sw[4])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 4
		if (vcount >= (y_start + 15*size) && vcount < (y_start + 16*size))
			if (hcount >= (x_start + 4*offset + 4*size) && hcount < (x_start + 4*offset + 5*size))
				if (p4_sw[3])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
		
		
		// switch 5
		if (vcount >= (y_start + 15*size) && vcount < (y_start + 16*size))
			if (hcount >= (x_start + 5*offset + 5*size) && hcount < (x_start + 5*offset + 6*size))
				if (p4_sw[2])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;			
		
		// switch 6
		if (vcount >= (y_start + 15*size) && vcount < (y_start + 16*size))
			if (hcount >= (x_start + 6*offset + 6*size) && hcount < (x_start + 6*offset + 7*size))
				if (p4_sw[1])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// switch 7
		if (vcount >= (y_start + 15*size) && vcount < (y_start + 16*size))
			if (hcount >= (x_start + 7*offset + 7*size) && hcount < (x_start + 7*offset + 8*size))
				if (p4_sw[0])
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;
					
		// button
		if (vcount >= (y_start + 17*size) && vcount < (y_start + 18*size))
			if (hcount >= x_start && hcount < (x_start + 7*offset + 8*size))
				if (p4_btn)
					rgbout <= rgb_swon;
				else
					rgbout <= rgb_swoff;

		if (bright)
			rgb <= rgbout;
		else
			rgb <= rgb_bg;
	
	end

endmodule
