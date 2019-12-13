`timescale 1ns / 1ps

module tb_top();
	reg clk, rst;
	reg [40:1] gpins;
	wire hsync, vsync, vga_blank_n, vga_clk;
	wire [7:0] r, g, b;

	top uut1 (
		.clk(clk), .rst(rst), .gpio1(gpins),
		.hsync(hsync), .vsync(vsync), .vga_blank_n(vga_blank_n), 
		.vga_clk(vga_clk), .r(r), .g(g), .b(b));

	
	initial begin
			
		clk = 0;
		rst = 1;
		gpins = 0; #5;
		
		rst = 0; #10;
		rst = 1; #1000;
		
		gpins[37] = 1; #120000;
		gpins[37] = 0; #1000;
		
		{gpins[35],gpins[21],gpins[33],gpins[23],gpins[31],gpins[25],gpins[39],gpins[27]} = 8'hfc;
		gpins[37] = 1; #200000;
		gpins[37] = 0; #2000;
		
	end
	
	always #10 clk = ~clk;
	
	
endmodule
