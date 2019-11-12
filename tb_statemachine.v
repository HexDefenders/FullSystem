module tb_statemachine();
	reg clk, reset;
	reg [15:0] instruction;
	wire [3:0] aluControl;
	wire pcRegEn, srcRegEn, dstRegEn, immRegEn, resultRegEn, signEn, regFileEn, pcRegMuxEn, 
			mux4En, shiftALUMuxEn, regImmMuxEn, memRead, memwrite,pcEn;
	
	statemachine uut(
		.clk(clk), .reset(reset), .instruction(instruction), .aluControl(aluControl), 
		.pcRegEn(pcRegEn), .srcRegEn(srcRegEn), .dstRegEn(dstRegEn), .immRegEn(immRegEn), 
		.resultRegEn(resultRegEn), .signEn(signEn), .regFileEn(regFileEn), .pcRegMuxEn(pcRegMuxEn), 
		.mux4En(mux4En), .shiftALUMuxEn(shiftALUMuxEn), .regImmMuxEn(regImmMuxEn), .memread(memRead), 
		.memwrite(memwrite), .pcEn(pcEn)
	);
	
	initial begin
		// Initiaize values
		clk = 0;
		reset = 0; #5;
		
		reset = 1; #10;
		reset = 0; #20;
		
		instruction = 16'b0010000001000000; #7; // STORE 
	end		
		
endmodule 