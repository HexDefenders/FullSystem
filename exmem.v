`timescale 1ns / 1ps

module exmem #(parameter WIDTH = 16, RAM_ADDR_BITS = 10)
   (input clk, rst, en,	
    input [8:0] pc,
    input memwrite, memread, link,
    input [RAM_ADDR_BITS-1:0] adr,
    input [WIDTH-1:0] writedata,
	 input playerInputFlag, allButtons, gameHasStarted,
	 input [1:0] firstPlayerFlag,
	 input [7:0] switchInput,
    output reg [WIDTH-1:0] memdata,
	 output reg [WIDTH-1:0] instruction,
	 output reg [WIDTH-1:0] randomVal,
	 output reg [WIDTH-1:0] p1, p2, p3, p4,
	 output reg [1:0] winnerPlayerNum, screenStatus,
	 output reg [2:0] gameStatus
    );
	 
	reg playerInputFlagReg;
	wire [15:0] out;
	//Currently 48 adressess available --> This will be expanded to 64k ultimately
   reg [WIDTH-1:0] ram [(2**RAM_ADDR_BITS)-1:0];
	
	initial begin
		
		 // The following $readmemh statement is only necessary if you wish
		 // to initialize the RAM contents via an external file (use
		 // $readmemb for binary data). The fib.dat file is a list of bytes,
		 // one per line, starting at address 0.  Note that in order to
		 // synthesize correctly, fib.dat must have exactly 256 lines
		 // (bytes). If that's the case, then the resulting bitstream will
		 // correctly initialize the synthesized block RAM with the data. 
		
		/* Tara's Path */	
		// $readmemh("/home/pzamani/Downloads/FullSystem-master_Previous/FullSystem-master/RunFullTest_V2.dat", ram);
		// $readmemh("/home/pzamani/Documents/FullSystem/test.dat", ram);
		
		/* Kris' Path*/
		$readmemh("C:\\Users\\u1014583\\Documents\\School\\ECE 3710 - Computer Design Lab\\HexDefenders\\FullSystem\\test.dat", ram);
		
		/* Cameron's Path */
//		$readmemh("C:\\intelFPGA_lite\\18.1\\FullSystem-master\\RunFullTest_V3.dat", ram);


		/* Kressa's Path*/
//		$readmemh("C:\\Users\\brand\\Documents\\HW_FA19\\FullSystem-master\\FullSystem-master\\RunFullTest_V3.dat", ram);
	
 // This "always" block simulates as a RAM, and synthesizes to a block
 // RAM on the Spartan-3E part. Note that the RAM is clocked. Reading
 // and writing happen on the rising clock edge. This is very important
 // to keep in mind when you're using the RAM in your system! 
 
   //I think in lab 2 "en" was like memread since we were always reading from memory except if reading form swtiches. look at mini_mips.v...
//	initial begin
//			ram[16'h0] = 16'h1; // address
//			ram[16'h1] = 16'h4; // value
	end
	
	LFSR randomNum (.clk(clk), .rst(rst), .mem_val(randomVal), .out(out));
	
	//assign playerInputFlag = playerInputFlag & ram[16'd37][0];
	
	always @(posedge clk) begin
		//playerInputVal <= ram[/*adr for flag*/];
		ram[16'd529] <= {14'b0, firstPlayerFlag};
		ram[16'd530] <= {15'b0,playerInputFlag};
		ram[16'd531] <= {8'b0, switchInput};
		ram[16'd532] <= out; //CHANGE THIS LATER WHEN MEM MAPPING IS EXPANDED
		
		ram[16'd537] <= {15'b0, allButtons};
		ram[16'd539] <= {15'b0, gameHasStarted};
		
		instruction <= ram[pc];
		gameStatus <= ram[16'd528];
		winnerPlayerNum <= ram[16'd540];
		screenStatus <= ram[16'd538];
		
      if (en) begin
         if (memwrite) 
            ram[adr] <= writedata;
			if (memread)
				memdata <= ram[adr];
			if (link)
				memdata <= pc + 1'b1;
      end
		else begin
			if (adr == 16'd1007 && instruction[7:4] == 4'b0100) begin
				randomVal <= writedata;
				p1 <= ram[16'd533]; //tEMP VALUES: NEEDS TO BE CHANGED LATER
				p2 <= ram[16'd534];
				p3 <= ram[16'd535];
				p4 <= ram[16'd536];
			end
		
		end
	end
			
endmodule
