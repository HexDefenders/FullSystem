module LFSR(clk, rst, out);
	input clk, rst;
	output reg [15:0] out;
	
	wire feedback;

	//Configure so that lower 8 bits of register get the random hex number.
	assign feedback = ~(out[7] ^ out[6]);
	
	always@(posedge clk, posedge rst) begin
		if(rst)
			out = 16'b0;
		else 
			out = {8'b0,out[6:0],feedback};
	end

endmodule 