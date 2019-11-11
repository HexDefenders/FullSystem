module top(clk, rst, hsync, vsync, vga_blank_n, vga_clk, r, g, b);

	input clk, rst;
	output hsync, vsync, vga_blank_n, vga_clk;
	output [7:0] r, g, b;
	
	wire memread, memwrite;
	wire [15:0] memdata, adr, writedata, instruction, srcData, dstData, imm;
	wire [3:0] aluControl;
	wire [1:0] mux4En, regpcCont, pcEn, exMemResultEn;
	wire [3:0] currentpc, nextpc;
	wire C, L, F, Z, N, pcRegEn, srcRegEn, dstRegEn, immRegEn, resultRegEn, signEn, regFileEn, pcRegMuxEn, shiftALUMuxEn, regImmMuxEn, irS;
	wire en;
	
	
	programcounter programcounter(.clk(clk), .en(pcEn), .newAdr(srcData), .imm(imm), .nextpc(nextpc));
	
	statemachine SM(.clk(clk), .reset(rst), .C(C), .L(L), .F(F), .Z(Z), .N(N), .instruction(instruction), .aluControl(aluControl), .pcRegEn(pcRegEn), .srcRegEn(srcRegEn), 
						.dstRegEn(dstRegEn), .immRegEn(immRegEn), .resultRegEn(resultRegEn), .signEn(signEn), .regFileEn(regFileEn), .pcRegMuxEn(pcRegMuxEn), .mux4En(mux4En), 
						.shiftALUMuxEn(shiftALUMuxEn), .regImmMuxEn(regImmMuxEn), .exMemResultEn(exMemResultEn), .memread(memread), .memwrite(memwrite), .pcEn(pcEn), .irS(irS), 
						.regpcCont(regpcCont));
						
	dataPath DP(.clk(clk), .memdata(memdata), .instruction(instruction), .aluControl(aluControl), .exMemResultEn(exMemResultEn), .pcRegEn(pcRegEn), .srcRegEn(srcRegEn), 
					.dstRegEn(dstRegEn), .immRegEn(immRegEn), .resultRegEn(resultRegEn), .signEn(signEn), .regFileEn(regFileEn), .pcRegMuxEn(pcRegMuxEn), .mux4En(mux4En), 
					.shiftALUMuxEn(shiftALUMuxEn), .irS(irS), .regImmMuxEn(regImmMuxEn), .regpcCont(regpcCont), .srcData(srcData), .dstData(dstData), .adr(adr), .signOut(imm),
					.C(C), .L(L), .F(F), .Z(Z), .N(N));
		
	assign en = 1;
	exmem mem(.clk(~clk), .en(en), .pc(nextpc), .memwrite(memwrite), .memread(memread), .adr(adr), .writedata(dstData), .memdata(memdata), .instruction(instruction));
	
	vga vga (
		.clk(clk), .rst(rst), 
		.value(), .p1(), .p2(), .p3(), .p4(), 
		.hsync(hsync), .vsync(vsync), .vga_blank_n(vga_blank_n), .vga_clk(vga_clk), .r(r), .g(g), .b(b)
	);

	
endmodule  