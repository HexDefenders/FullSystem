`timescale 1ns / 1ps

module tb_top();
	reg clk, rst;
	reg [35:0] gpio1;
//	reg [15:0] instruction;
	wire hsync, vsync, vga_blank_n, vga_clk;
	wire [7:0] r, g, b;

	top uut1 (
		.clk(clk), .rst(rst), .gpio1(gpio1),
		.hsync(hsync), .vsync(vsync), .vga_blank_n(vga_blank_n), 
		.vga_clk(vga_clk), .r(r), .g(g), .b(b));

	
	initial begin
			
		clk = 0;
		rst = 0;
		gpio1[25] = 0; #5;
		
		rst = 1; #10;
		rst = 0; #1000;
		
		gpio1[25] = 1; #200;
		gpio1[25] = 0; #20;
		
		
		//Pre-existing values hardcoded into Registers
		//R[1] = 2
		//R[2] = 4
		//R[3] = 3
		
//		// Value 
//		instruction = 16'b0100000101000010; // Store R[1] = 2 into M[R[2]] = M[address 4]
//		#120;
//		instruction = 16'b0100010000000010; // Load M[R[2]] = M[address 4] = 2 into R[4]
//		#120;
//		instruction = 16'b0000001001010011; // Add R[2] = R[2] + R[3] = 4 + 3 = 7 (111)
//		#120;
//		instruction = 16'b0000001010010001; // Sub R[2] = R[2] - R[1] = 7 - 2 = 5 (101)
//		#120;
//		instruction = 16'b0000010111010010; // MOV R[2] into R[5] = 5 (101)
//		#120;
//		instruction = 16'b0000001100010010; // And R[3] = R[3] & R[2] = 3 & 5 = 1 (001)
//		#120;
//		instruction = 16'b0000000100100101; // Or R[1] = R[1] | R[5] = 2 | 5 = 7 (111)
//		#120;
//		instruction = 16'b0000001100110001; // Xor R[3] = R[3] ^ R[1] = 1 ^ 7 = 6 (110)
//		#120;
//		instruction = 16'b0000000110110011; // Cmp R[3] to R[1] = 6 cmp 7 --> L = 1, N = 1
//		#120;
//		instruction = 16'b0101001000000110; // Addi R[2] = R[2] + 6 = 5 + 6 = 11; (1011)
//		#120;
//		instruction = 16'b1001001000000101; // Subi R[2] = R[2] - 5 = 11 - 5 = 6; (110)
//		#80;
//		instruction = 16'b1101010100000100; // Movi 4 into R[5] = 4 (100) 
//		#120;
//		instruction = 16'b0001010100000100; // Andi R[5] = R[5] & 4 = 4 & 4 = 4 (100) 
//		#120;
//		instruction = 16'b0010001000000011; // Ori R[2] = R[2] | 3 = 6 | 3 = 2 (010)
//		#120;
//		instruction = 16'b0011001000000101; // Xori R[2] = R[2] ^ 5 = 2 ^ 5 = 7 (111)
//		#120;
//		instruction = 16'b1011001000000111; // Cmpi R[2] to 7 = 7 cmp 7 => Z = 1
//		#120;
//		instruction = 16'b0000000000000000; // End of File Instruction
//		
		
	end
	
	always #10 clk = ~clk;
	
	
endmodule
