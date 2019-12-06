module LFSR(clk, rst, mem_val, out);
	input clk, rst;
	input [15:0] mem_val;
	inout [15:0] out;
	
	reg [15:0] temp_out;
	reg [15:0] rand1;
	reg [15:0] rand2;
	wire feedback;

	//Configure so that lower 8 bits of register get the random hex number.
	//assign feedback = ~(out[7] ^ out[6]);
	
	always@(posedge clk, negedge rst) begin
		if(!rst) begin
			temp_out = 16'b0;
			rand1 = 16'b0110101001000111;
			rand2 = 16'b1111001011011010;
		end
		else begin
			//temp_out = {8'b0,temp_out[6:0], ~(temp_out[7] ^ temp_out[6])};
			//temp_out = {8'b0,~(temp_out[3] ^ temp_out[0]), temp_out[6:0]};
			//temp_out = {8'b0,temp_out[7:6],~(temp_out[4] ^ temp_out[5]), temp_out[4], ~(temp_out[2] ^ temp_out[5]), temp_out[2:0]};
			rand1 = {rand1[14:0], ~(rand1[15] ^ rand1[14])};
			rand2 = {rand2[14:0], ~(rand2[15] ^ rand2[14])};
			temp_out = {8'b0, rand1[7], rand2[10], rand1[3], rand1[12], rand2[1], rand2[4], rand1[8], rand2[0]};
			if (mem_val[7:0] == temp_out[7:0] || temp_out[7:0] == 8'b0) begin
				//temp_out = {8'b0,temp_out[6:0], ~(temp_out[7] ^ temp_out[6])};
				//temp_out = {8'b0,~(temp_out[3] ^ temp_out[0]), temp_out[6:0]};
				//temp_out = {8'b0,temp_out[7:6], ~(temp_out[4] ^ temp_out[5]), temp_out[4], ~(temp_out[2] ^ temp_out[5]), temp_out[2:0]};
				rand1 = {rand1[14:0], ~(rand1[15] ^ rand1[14])};
				rand2 = {rand2[14:0], ~(rand2[15] ^ rand2[14])};
				temp_out = {8'b0, rand1[7], rand2[10], rand1[3], rand1[12], rand2[1], rand2[4], rand1[8], rand2[0]};
			end
		end
	end

	assign out = temp_out;
	
endmodule 