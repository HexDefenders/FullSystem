module LFSR(clk, rst, out);
	input clk, rst;
	inout [15:0] out;
	
	reg [15:0] temp_out;
	wire feedback;

	//Configure so that lower 8 bits of register get the random hex number.
	//assign feedback = ~(out[7] ^ out[6]);
	
	always@(posedge clk, negedge rst) begin
		if(!rst)
			temp_out = 16'b0;
		else 
			temp_out = {8'b0,temp_out[6:0], ~(temp_out[7] ^ temp_out[6])};
	end

	assign out = temp_out;
	
endmodule 