module alu(a, b, aluControl, C, L, F, Z, N, result);		
	input [15:0] a, b;
	input [3:0] aluControl;
	output reg C, L, F, Z, N;
	output reg [15:0] result;
	
	always@(*) begin
		C = C;
		L = L;
		F = F;
		Z = Z; 
		N = N;
		result = 4'd0;
		
		case(aluControl) 
			4'b0000: begin
				C = C;
				L = L;
				F = F;
				Z = Z; 
				N = N;
			end
			4'b0001: begin //SUB or SUBI
			result = b - a; 
				if (result > b) begin
					C = 1;
					F = 1;
					L = 0;
					Z = 0; 
					N = 0;
				end
				else begin
					C = 0;
					F = 0;
					L = 0;
					Z = 0; 
					N = 0;
				end
			end
			4'b0010: begin //CMP or CMPI
				result = result;
				if (b < a) begin
					C = 0;
					F = 0;
					L = 1;
					Z = 0; 
					N = 1;
				end
				else if (a == b) begin
					C = 0;
					F = 0;
					L = 0;
					Z = 1; 
					N = 0;
				end
				else begin
					C = 0;
					F = 0;
					L = 0;
					Z = 0; 
					N = 0;
				end
			end
			4'b0011: begin //AND or ANDI
				result = a & b; 	
				C = 0;
				F = 0;
				L = 0;
				Z = 0; 
				N = 0;
			end
			4'b0100: begin //OR or ORI
				result = a | b;
				C = 0;
				F = 0;
				L = 0;
				Z = 0; 
				N = 0;
			end
			4'b0101: begin //XOR or XORI
				result = a ^ b; 
				C = 0;
				F = 0;
				L = 0;
				Z = 0; 
				N = 0;
			end
			
			4'b0110: begin //LUI
				result = {a[7:0], b[7:0]};	
				C = C;
				F = F;
				L = L;
				Z = Z; 
				N = N;
			end
			//4'b0111: begin //MOVI
			//	result = b;
			//end
			
			4'b1000: begin //ADD or ADDI
				result = a + b; 
				if (result < b || result < a) begin
					C = 1;
					F = 1;
					L = 0;
					Z = 0; 
					N = 0;
				end
				else begin 
					C = 0;
					F = 0;
					L = 0;
					Z = 0; 
					N = 0;
				end
			end
			
			default: begin
				C = 0;
				L = 0;
				F = 0;
				Z = 0; 
				N = 0;
				result = 0;
			end
		endcase
	end
endmodule
