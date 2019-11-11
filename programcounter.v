module programcounter(clk, en, newAdr, imm, nextpc);
	//ultimately, currentpc and nextpc are going to be 16 bits
	input clk;
	input [1:0] en;
	//input [3:0] currentpc;
	input [15:0] newAdr, imm;
	output reg [3:0] nextpc = 4'b0;
	//reg [3:0] currentpc = 4'b0;
	
	always@(posedge clk) begin
		case(en)
			2'b01: nextpc <= nextpc + 1'b1; // most instructions
			2'b10: nextpc <= newAdr; // jumps
			2'b11: nextpc <= nextpc + imm; // branches
			default: nextpc <= nextpc;
		endcase
		
		//if(en == 2'b01)
		//	nextpc <= nextpc + 1'b1;
		//else if(en == 2'b10)
		//	nextpc <= newAdr;
		//else if(en == 2'b11)
		//	nextpc <= nextpc + imm; //check for negative displacement
		//else
		//	nextpc <= nextpc;
	end
endmodule 