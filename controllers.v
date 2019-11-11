module controllers (gpins, playerInput, playerInputFlag, firstPlayerFlag, switchInput);
	input	     	[35:0]	gpins;
	input		  	[15:0] 	playerInput;
	inout reg				playerInputFlag;
	output reg 	 [1:0]	firstPlayerFlag;
	output		 [7:0]	switchInput;
	
	wire [7:0] mux4playeroutput;
	
	// Players Input Mapping
	wire p1_sw = {gpins[33:26]};
	wire p1_btn = gpins[25];
	
	wire p2_sw = 0;
	wire p2_btn = 0;
	
	wire p3_sw = 0;
	wire p3_btn = 0;
	
	wire p4_sw = 0;
	wire p4_btn = 0;
	
	// Sensitivity list is all the GPIO pins for the buttons.
	// If any are activated, the firstPlayerFlag will be swapped in
	// order to process the correct player's pins and sets the 
	// playerInputFlag to 1 in order to use the player's input rather 
	// than the default of all 0's.
	always @(p1_btn, p2_btn, p3_btn, p4_btn) begin
		if (p1_btn)
			firstPlayerFlag = 2'b00;
		else if (p2_btn)
			firstPlayerFlag = 2'b01;
		else if (p3_btn)
			firstPlayerFlag = 2'b10;
		else
			firstPlayerFlag = 2'b11;
		playerInputFlag = 1'b1;
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
		.y(switchInput)			// output
	);
		
endmodule 
