module shifter(in, s, out);
	input [15:0] in;
	input [15:0] s;
	output reg [15:0] out;
	
	always@(*) 
		out <= in << s;
	
endmodule
