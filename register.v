module register #(parameter SIZE = 16)
					  (D, En, clk, Q);
	input [SIZE-1:0] D;
	input En, clk;
	output reg [SIZE-1:0] Q;
	
	always@(posedge clk)
			if(En)
				Q <= D;
			else 
				Q <= Q;
				
endmodule


module single_register (clk, en, d, q);
	input clk, en, d;
	output reg q;
	
	always @(posedge clk)
		if (en)
			q <= d;
		else
			q <= q;

endmodule
