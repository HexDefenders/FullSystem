module controllers (clk, rst, gpins, playerInput, playerInputFlag, firstPlayerFlag, switchInput);
	input						clk, rst;
	input	     	[40:1]	gpins;
	input		  	[15:0] 	playerInput;
	output reg				playerInputFlag;
	output reg 	 [1:0]	firstPlayerFlag;
	output		 [7:0]	switchInput;
	
	wire [7:0] mux4playeroutput, mux2playeroutput;
	
	// Players Input Mapping
	wire [7:0] p1_sw, p2_sw, p3_sw, p4_sw;
	wire db_btn1, db_btn2, db_btn3, db_btn4;
	wire p1_btn, p2_btn, p3_btn, p4_btn;
	
	// testing revealed ~2ms debounce time (50MHz clk * 2ms = 100,000)
	//		waiting 100,000 cycles before reveals output of btn
	btn_debounce #(100000) bd1 (.clk(clk), .in_btn(gpins[37]), .out_btn(db_btn1));
	btn_debounce #(100000) bd2 (.clk(clk), .in_btn(gpins[24]), .out_btn(db_btn2));
	btn_debounce #(100000) bd3 (.clk(clk), .in_btn(gpins[16]), .out_btn(db_btn3));
	btn_debounce #(100000) bd4 (.clk(clk), .in_btn(gpins[9]), .out_btn(db_btn4));
	
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
		if (p1_btn) begin
			firstPlayerFlag = 2'b00;
			playerInputFlag = 1'b1;
		end
		else if (p2_btn) begin
			firstPlayerFlag = 2'b01;
			playerInputFlag = 1'b1;
		end
		else if (p3_btn) begin
			firstPlayerFlag = 2'b10;
			playerInputFlag = 1'b1;
		end
		else if (p4_btn) begin
			firstPlayerFlag = 2'b11;
			playerInputFlag = 1'b1;
		end
		else begin
			playerInputFlag = 1'b0;
			firstPlayerFlag = 2'b00;
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
		.y(mux2playeroutput)			// output
	);
	
	register #(8) switchInputReg(
		.D(mux2playeroutput), 
		.En(playerInputFlag), 
		.clk(clk), 
		.Q(switchInput)
	);

		
endmodule 
