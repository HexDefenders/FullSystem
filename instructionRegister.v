module instructionRegister(inst, s, OpCode, Rdest, OpCodeExt, Rsrc, imm);
	input [15:0] inst;
	input s;
	output reg unsigned [3:0] OpCode, Rdest, OpCodeExt, Rsrc;
	output reg [7:0] imm;
	
	always @(*) begin 
		OpCode <= inst[15:12];
		Rdest <= inst[11:8];
		
		if (s == 1) begin // uses immediate
			OpCodeExt <= 0;
			Rsrc <= 0;
			imm <= inst[7:0];
		end
		else begin // uses Rsrc
			OpCodeExt <= inst[7:4];
			Rsrc <= inst[3:0];
			imm <= 8'b0; 
		end
	end 
	
endmodule
