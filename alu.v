module alu(a, b, aluControl, C, L, F, Z, N, result);		
	input [15:0] a, b;
	input [3:0] aluControl;
	output reg C, L, F, Z, N;
	output reg [15:0] result;
	
	always@(*) begin
		C = 0;
		L = 0;
		F = 0;
		Z = 0; 
		N = 0;
		result = 4'd0;
		case(aluControl) 
			4'b0000: begin
				C = 0;
				L = 0;
				F = 0;
				Z = 0; 
				N = 0;
			end
			4'b0001: begin //SUB or SUBI
			result = b - a; 
				if (result > b) begin
					C = 1;
					F = 1;
				end
				else begin
					C = 0;
					F = 0;
				end
			end
			4'b0010: begin //CMP or CMPI
				if (b < a) begin
					L = 1;
					N = 1;
					Z = 0;
				end
				else if (a == b) begin
					L = 0;
					N = 0;
					Z = 1;
				end
				else begin
					L = 0;
					N = 0;
					Z = 0;
				end
			end
			4'b0011: begin //AND or ANDI
				result = a & b; 	
			end
			4'b0100: begin //OR or ORI
				result = a | b;
			end
			4'b0101: begin //XOR or XORI
				result = a ^ b; 
			end
			
			4'b0110: begin //LUI
				result = {a[7:0], b[7:0]};	
			end
			//4'b0111: begin //MOVI
			//	result = b;
			//end
			
			4'b1000: begin //ADD or ADDI
				result = a + b; 
				if (result < b || result < a) begin
					C = 1;
					F = 1;
				end
				else begin 
					C = 0;
					F = 0;
				end
			end
			
			default: begin
				C = 0;
				L = 0;
				F = 0;
				Z = 0; 
				N = 0;
			end
		endcase
	end
endmodule
