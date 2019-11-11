module signExtend(in, s, out);
	input [7:0] in;
	input s;
	output reg [15:0] out;
	
	always @(*)
		if (s == 1) // signExtend
			out <= {{8{in[7]}}, in[7:0]};
		else // zeroExtend
			out <= {{8{1'b0}}, in[7:0]};
		
endmodule 