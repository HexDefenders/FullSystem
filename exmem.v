`timescale 1ns / 1ps

module exmem #(parameter WIDTH = 16, RAM_ADDR_BITS = 16)
   (input clk, en,
    input memwrite, memread,
    input [RAM_ADDR_BITS-1:0] adr,
    input [WIDTH-1:0] writedata,
	 input [3:0] pc,
    output reg [WIDTH-1:0] memdata,
	 output reg [WIDTH-1:0] instruction
	 //output reg [WIDTH-1:0] playerInputVal,
	 //inout reg playerInputFlag
    );

   reg [WIDTH-1:0] ram [(2*RAM_ADDR_BITS)-1:0];
	
 initial begin

 // The following $readmemh statement is only necessary if you wish
 // to initialize the RAM contents via an external file (use
 // $readmemb for binary data). The fib.dat file is a list of bytes,
 // one per line, starting at address 0.  Note that in order to
 // synthesize correctly, fib.dat must have exactly 256 lines
 // (bytes). If that's the case, then the resulting bitstream will
 // correctly initialize the synthesized block RAM with the data. 
 
 // Kris' Path
 //$readmemh("C:\\Users\\u1014583\\Documents\\HexDefenders\\Processor\\new_test.dat", ram);
 // Cameron's Path
 $readmemh("C:\\intelFPGA_lite\\18.1\\Processor\\testfile.dat", ram);
 
 // This "always" block simulates as a RAM, and synthesizes to a block
 // RAM on the Spartan-3E part. Note that the RAM is clocked. Reading
 // and writing happen on the rising clock edge. This is very important
 // to keep in mind when you're using the RAM in your system! 
 
   //I think in lab 2 "en" was like memread since we were always reading from memory except if reading form swtiches. look at mini_mips.v...
//	initial begin
//			ram[16'h0] = 16'h1; // address
//			ram[16'h1] = 16'h4; // value
	end
	
	always @(posedge clk) begin
		//playerInputVal <= ram[/*adr for flag*/];
		instruction <= ram[pc];
      if (en) begin
         if (memwrite)
            ram[adr] <= writedata;
			if (memread)
				memdata <= ram[adr];
      end
	end
	
//	always @(playerInputFlag)
//		ram[/*adr for flag*/] <= playerInputFlag;
						
endmodule
