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
   reg [WIDTH-1:0] ram [(2**RAM_ADDR_BITS)-1:0];
	
	initial begin
		
		/* Tara's Path */	
		// $readmemh("/home/pzamani/Downloads/FullSystem-master_Previous/FullSystem-master/RunFullTest_V2.dat", ram);
		// $readmemh("/home/pzamani/Documents/FullSystem/test.dat", ram);
		
		/* Kris' Path*/
		$readmemh("C:\\Users\\u1014583\\Documents\\School\\ECE 3710 - Computer Design Lab\\HexDefenders\\FullSystem\\test.dat", ram);
		
		/* Cameron's Path */
//		$readmemh("C:\\intelFPGA_lite\\18.1\\FullSystem\\test.dat", ram);

		/* Kressa's Path*/
		//$readmemh("C:\\Users\\brand\\Documents\\HW_FA19\\FullSystem-master\\FullSystem-master\\RunFullTest_V3.dat", ram);

	end
	
	LFSR randomNum (.clk(clk), .rst(rst), .mem_val(randomVal), .out(out));
	
	always @(posedge clk) begin
		ram[16'd529] <= {14'b0, firstPlayerFlag};
		ram[16'd530] <= {15'b0,playerInputFlag};
		ram[16'd531] <= {8'b0, switchInput};
		ram[16'd532] <= out; 
		
		ram[16'd537] <= {15'b0, allButtons};
		ram[16'd539] <= {15'b0, gameHasStarted};
		
		instruction <= ram[pc];
		gameStatus <= ram[16'd528];
		winnerPlayerNum <= ram[16'd540];
		screenStatus <= ram[16'd538];
		
		// en is high when not in I/O space
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
				p1 <= ram[16'd533];
				p2 <= ram[16'd534];
				p3 <= ram[16'd535];
				p4 <= ram[16'd536];
			end
		
		end
	end
			
endmodule
