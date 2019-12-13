`timescale 1ps / 1ps

module tb_alu();
	reg [15:0] a, b; 
	reg [3:0] aluControl;
	wire  C, L, F, Z, N;
	wire [15:0] result;
	
	alu uut(.a(a), .b(b), .aluControl(aluControl), .C(C), .L(L), .F(F), .Z(Z), .N(N), .result(result));
	
	
	initial begin 
		a = 16'b0;
		b = 16'b0;
		aluControl = 4'b0; #200
	
		// ADD or ADDI
		a = 16'h0003;
		b = 16'h0001;
		aluControl = 4'b1000; #300;
		if (!(result == 16'h0004)) 
			$display("ADD ERROR");
		
		// SUB or SUBI
		a = 16'h0003;
		b = 16'h0001;
		aluControl = 4'b0001; #300;
		if (!(result == 16'h0002)) 
			$display("SUB ERROR");
			
		// CMP or CMPI EQUAL
		a = 16'h0003;
		b = 16'h0003;
		aluControl = 4'b0010; #300;
		if (!(Z == 1)) 
			$display("CMP EQUAL ERROR");
			
		// CMP or CMPI LESS THAN
		a = 16'h0002;
		b = 16'h0003;
		aluControl = 4'b0010; #300;
		if (!(L == 1)) 
			$display("CMP LESS ERROR");
			
		// CMP or CMPI GREATER THAN
		a = 16'h0003;
		b = 16'h0002;
		aluControl = 4'b0010; #200;
		if (!(L == 0)) 
			$display("CMP GREATER ERROR");
			
		// AND or ANDI
		a = 16'h0002;
		b = 16'h0003;
		aluControl = 4'b0011; #200;
		if (!(result == 16'h0002)) 
			$display("AND ERROR");
			
		// OR or ORI
		a = 16'h0002;
		b = 16'h0003;
		aluControl = 4'b0100; #200;
		if (!(result == 16'h0003)) 
			$display("OR ERROR");
			
		// XOR or XORI
		a = 16'h0002;
		b = 16'h0003;
		aluControl = 4'b0101; #200;
		if (!(result == 16'h0001)) 
			$display("XOR ERROR");
			
		// MOV or MOVI
		a = 16'h0002;
		b = 16'h0003;
		aluControl = 4'b0011; #200;
		if (!(result == 16'h0002)) 
			$display("MOV ERROR");
			
		// Check N flag
		a = 16'h0001;
		b = 16'h0002;
		aluControl = 4'b0001; #200;
		if (!(C == 1))
			$display("UNSIGNED OVERFLOW ERROR");
			
		// Check C flag
		a = 16'hFFFF;
		b = 16'h0001;
		aluControl = 4'b0000; #200;
		if (!(C == 1)) 
			$display("UNSIGNED OVERFLOW ERROR 2");
			
		// Check F flag
		a = 16'hFFFF;
		b = 16'h0001;
		aluControl = 4'b0001; #200;
		if (!(F == 1)) 
			$display("SIGNED OVERFLOW ERROR");
	end
endmodule 