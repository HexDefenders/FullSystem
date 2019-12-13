module programcounter(clk, rst, en, newAdr, imm, nextpc);
	input clk, rst;
	input [1:0] en;
	input [15:0] newAdr, imm;
	output reg [15:0] nextpc = 16'b0;
	
	always@(posedge clk, negedge rst) begin
		if (!rst)
			nextpc <= 0;
		else begin
			case(en)
				2'b01: nextpc <= nextpc + 1'b1; // most instructions
				2'b10: nextpc <= newAdr; // jumps
				2'b11: nextpc <= nextpc + imm; // branches
				default: nextpc <= nextpc;
			endcase
		end
	end
endmodule 