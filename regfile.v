module regfile(clk, regwrite, ra1, ra2, wd, rd1, rd2);
	input clk, regwrite;
	input [3:0] ra1, ra2;// read register 1 & 2
	input [15:0] wd; // write data
	output [15:0] rd1, rd2; // read data 1 & 2
	
	reg [15:0] RAM [15:0];
	
	always@(posedge clk)
		if (regwrite)
			RAM[ra2] <= wd; // One of the read addresses is also the write address
	
//	initial begin
//			RAM[16'h1] = 16'h2; // address
//			RAM[16'h2] = 16'h4; // value
//			RAM[16'h3] = 16'h3; // value
//	end
	
	assign rd1 = ra1 ? RAM[ra1] : 16'b0;
	assign rd2 = ra2 ? RAM[ra2] : 16'b0;
endmodule
