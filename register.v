module register(D, En, clk, Q);
	input [15:0] D;
	input En, clk;
	output reg [15:0] Q;
	
	always@(posedge clk)
			if(En)
				Q <= D;
			else 
				Q <= Q;
				
endmodule 