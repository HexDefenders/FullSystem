module controllers (clk, rst, gpins, playerInput, playerInputFlag, allButtons, gameHasStarted, firstPlayerFlag, switchInput, led);
	input						clk, rst;
	input	     	[40:1]	gpins;
	input		  	[15:0] 	playerInput;
	output reg				playerInputFlag, allButtons;
	output					gameHasStarted;
	output		 [1:0]	firstPlayerFlag;
	output		 [7:0]	switchInput;
	output					led;
	
	wire [7:0] mux4playeroutput, mux2playeroutput;
	
	reg  [1:0] firstPlayerFlagRaw;
	reg 		  firstPlayerFlagEn;
	
	// Players Input Mapping
	wire [7:0] p1_sw, p2_sw, p3_sw, p4_sw;
	wire db_btn1, db_btn2, db_btn3, db_btn4;
	wire p1_btn, p2_btn, p3_btn, p4_btn;
	wire ms_btn1, ms_btn2, ms_btn3, ms_btn4;
	wire sec5_btn1, sec5_btn2, sec5_btn3, sec5_btn4;
	
	// testing revealed ~2ms debounce time (50MHz clk * 2ms = 100,000)
	//		waiting 100,000 cycles before reveals output of btn
	btn_debounce #(100000) bd1 (.clk(clk), .in_btn(gpins[37]), .out_btn(db_btn1));
	btn_debounce #(100000) bd2 (.clk(clk), .in_btn(gpins[24]), .out_btn(db_btn2));
	btn_debounce #(100000) bd3 (.clk(clk), .in_btn(gpins[16]), .out_btn(db_btn3));
	btn_debounce #(100000) bd4 (.clk(clk), .in_btn(gpins[9]), .out_btn(db_btn4));
	
	sec5_counter _sec5_btn1 (.clk(clk), .in(gpins[37]), .out(sec5_btn1));
	sec5_counter _sec5_btn2 (.clk(clk), .in(gpins[24]), .out(sec5_btn2));
	sec5_counter _sec5_btn3 (.clk(clk), .in(gpins[16]), .out(sec5_btn3));
	sec5_counter _sec5_btn4 (.clk(clk), .in(gpins[9]), .out(sec5_btn4));
	
	
	assign led = sec5_btn1;
	assign gameHasStarted = sec5_btn1 | sec5_btn2 | sec5_btn3 | sec5_btn4;
	
	assign p1_sw = {gpins[35],gpins[21],gpins[33],gpins[23],gpins[31],gpins[25],gpins[39],gpins[27]};
	assign p1_btn = db_btn1;
	
	assign p2_sw = {gpins[36],gpins[34],gpins[38],gpins[32],gpins[40],gpins[28],gpins[22],gpins[26]};
	assign p2_btn = db_btn2;
	
	assign p3_sw = {gpins[6],gpins[4],gpins[8],gpins[2],gpins[10],gpins[20],gpins[14],gpins[18]};
	assign p3_btn = db_btn3;
	
	assign p4_sw = {gpins[1],gpins[15],gpins[3],gpins[17],gpins[5],gpins[19],gpins[7],gpins[13]};
	assign p4_btn = db_btn4;
	
	// Sensitivity list is all the GPIO pins for the buttons.
	// If any are activated, the firstPlayerFlag will be swapped in
	// order to process the correct player's pins and sets the 
	// playerInputFlag to 1 in order to use the player's input rather 
	// than the default of all 0's.
	always @(rst, p1_btn, p2_btn, p3_btn, p4_btn) begin
		if (p1_btn & p2_btn & p3_btn & p4_btn) begin
			firstPlayerFlagRaw = 2'b00;
			firstPlayerFlagEn = 1'b0;
			playerInputFlag = 1'b0;
			allButtons = 1'b1;
		end
		else if (p1_btn) begin
			firstPlayerFlagRaw = 2'b00;
			firstPlayerFlagEn = 1'b1;
			playerInputFlag = 1'b1;
			allButtons = 1'b0;
		end
		else if (p2_btn) begin
			firstPlayerFlagRaw = 2'b01;
			firstPlayerFlagEn = 1'b1;
			playerInputFlag = 1'b1;
			allButtons = 1'b0;
		end
		else if (p3_btn) begin
			firstPlayerFlagRaw = 2'b10;
			firstPlayerFlagEn = 1'b1;
			playerInputFlag = 1'b1;
			allButtons = 1'b0;
		end
		else if (p4_btn) begin
			firstPlayerFlagRaw = 2'b11;
			firstPlayerFlagEn = 1'b1;
			playerInputFlag = 1'b1;
			allButtons = 1'b0;
		end
		else begin
			playerInputFlag = 1'b0;
			firstPlayerFlagEn = 1'b0;
			firstPlayerFlagRaw = 2'b00;
			allButtons = 1'b0;
		end
	end
	
	mux4 #(8) whichPlayer (
		.d0(p1_sw),				// 00 - p1
		.d1(p2_sw), 			// 01 - p2
		.d2(p3_sw),				// 10 - p3
		.d3(p4_sw), 			// 11 - p4
		.s(firstPlayerFlag), // select
		.y(mux4playeroutput)	// output
	);
	
	mux2 #(8) playerOrDefault(
		.d0(8'b0), 					// 0 - default
		.d1(mux4playeroutput), 	// 1 - player
		.s(playerInputFlag), 	// select
		.y(mux2playeroutput)		// output
	);
	
	register #(8) switchInputReg(
		.D(mux2playeroutput), 
		.En(playerInputFlag), 
		.clk(clk), 
		.Q(switchInput)
	);
	
	register #(2) playerInputFlagReg(
		.D(firstPlayerFlagRaw),
		.En(firstPlayerFlagEn),
		.clk(clk),
		.Q(firstPlayerFlag)
	);
		
endmodule 

module sec5_counter (clk, rst, in, out);
	input clk, rst, in;
	output reg out;
	
	reg [27:0] counter;
	
	parameter[27:0] MAX = 28'd250000000;
	
	always @(posedge clk) begin
		if (!rst) begin
			counter <= 0;
			out <= 0;
		end
		else if (in) begin
			if (counter >= MAX) begin
				out <= 1;
			end
			counter <= counter + 1;
		end
		else begin
			out <= 0;
			counter <= 0;
		end
	end

endmodule
