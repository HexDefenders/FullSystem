module statemachine(clk, reset, C, L, F, Z, N, instruction, aluControl, pcRegEn, srcRegEn, dstRegEn, immRegEn, resultRegEn, signEn,
						regFileEn, pcRegMuxEn, mux4En, shiftALUMuxEn, regImmMuxEn, exMemResultEn, memread, memwrite, pcEn, irS, regpcCont);
	input clk, reset, C, L, F, Z, N;
	input [15:0] instruction;
	output reg [3:0] aluControl;
	output reg pcRegEn, srcRegEn, dstRegEn, immRegEn, resultRegEn, signEn, regFileEn, pcRegMuxEn, shiftALUMuxEn, regImmMuxEn, 
							memread, memwrite, irS;
	output reg [1:0] mux4En, regpcCont, pcEn, exMemResultEn;
	reg [5:0] PS, NS;
	parameter [5:0] FETCH = 6'd0, DECODE = 6'd1, ADD = 6'd2, SUB = 6'd3, CMP = 6'd4, AND = 6'd5, OR = 6'd6, XOR = 6'd7, MOV = 6'd8, LOAD = 6'd9, STOR = 6'd10, 
						 JAL = 6'd11, JCOND = 6'd12, LSH = 6'd13, LSHI = 6'd14, S15 = 6'd15, BCOND = 6'd16, ANDI = 6'd17, ORI = 6'd18, XORI = 6'd19, ADDI = 6'd20,
						 SUBI = 6'd21, CMPI = 6'd22, MOVI = 6'd23, LUI = 6'd24;
						 
	always @(posedge reset, posedge clk) begin
		if (reset) PS <= FETCH;
		else PS <= NS;
	end
	
	always@(clk, reset, instruction, PS) begin
		// initialize control signals
		{pcRegEn, srcRegEn, dstRegEn, immRegEn, resultRegEn, signEn, regFileEn, pcRegMuxEn, 
		shiftALUMuxEn, regImmMuxEn, resultRegEn, memread, memwrite, irS} <= 1'd0;
		{mux4En, regpcCont, pcEn, exMemResultEn} <= 2'b0;
		aluControl <= 4'b0;
		NS <= 6'b0;
		
		case(PS)
			FETCH: begin // FETCH
				pcRegEn <= 1;
				memread <= 1;
				NS <= DECODE;
				if (instruction[7:4] == 4'b1011) // CMP
						aluControl <= 4'b0010;
			end
			
			DECODE: begin // DECODE
				if (instruction[15:12] == 4'b0000) begin // Register
					if (instruction[7:4] == 4'b0101) begin // ADD
						srcRegEn <= 1;
						dstRegEn <= 1;
						NS <= ADD;
					end
					else if (instruction[7:4] == 4'b1001) begin // SUB
						srcRegEn <= 1;
						dstRegEn <= 1;
						NS <= SUB;
					end
					else if (instruction[7:4] == 4'b1011) begin // CMP
						//aluControl <= 4'b0010;
						srcRegEn <= 1;
						dstRegEn <= 1;
						NS <= CMP;
					end
					else if (instruction[7:4] == 4'b0001) begin // AND
						srcRegEn <= 1;
						dstRegEn <= 1;
						NS <= AND;
					end
					else if (instruction[7:4] == 4'b0010) begin // OR
						srcRegEn <= 1;
						dstRegEn <= 1;
						NS <= OR;
					end
					else if (instruction[7:4] == 4'b0011) begin // XOR
						srcRegEn <= 1;
						dstRegEn <= 1;
						NS <= XOR;
					end 
					else if (instruction[7:4] == 4'b1101) begin // MOV
						srcRegEn <= 1;
						dstRegEn <= 1;
						NS <= MOV;
					end
				end
				
				else if (instruction[15:12] == 4'b0100) begin // Special
					if (instruction[7:4] == 4'b0000) begin // LOAD
						srcRegEn <= 1;
						dstRegEn <= 1;
						NS <= LOAD;
					end
					else if (instruction[7:4] == 4'b0100) begin // STOR
						srcRegEn <= 1;
						dstRegEn <= 1;
						NS <= STOR;
					end
					else if (instruction[7:4] == 4'b1000) begin// JAL
						srcRegEn <= 1;
						dstRegEn <= 1;
						NS <= JAL;
					end
					else if (instruction[7:4] == 4'b1100) begin// Jcond
						NS <= JCOND;
					end
				end
				
				else if (instruction[15:12] == 4'b1000) begin // Shift
					if (instruction[7:4] == 4'b0100) begin // LSH
						NS <= LSH;
					end
					else if (instruction[7:4] == 4'b0000) begin // LSHI 
						NS <= LSHI;
					end
					else if (instruction[7:4] == 4'b0001) begin // LSHI
						NS <= S15;
					end
				end
				
				else if (instruction[15:12] == 4'b1100) begin // Bcond
					
					NS <= BCOND;
				end
				else if (instruction[15:12] == 4'b0001) begin // ANDI
					immRegEn <= 1;
					dstRegEn <= 1;
					irS <= 1;
					NS <= ANDI;
				end
				else if (instruction[15:12] == 4'b0010) begin // ORI
					immRegEn <= 1;
					dstRegEn <= 1;
					irS <= 1;
					NS <= ORI;
				end
				else if (instruction[15:12] == 4'b0011) begin // XORI
					immRegEn <= 1;
					dstRegEn <= 1;
					irS <= 1;
					NS <= XORI;
				end
				else if (instruction[15:12] == 4'b0101) begin // ADDI
					immRegEn <= 1;
					dstRegEn <= 1;
					irS <= 1;
					NS <= ADDI;
				end
				else if (instruction[15:12] == 4'b1001) begin // SUBI
					immRegEn <= 1;
					dstRegEn <= 1;
					irS <= 1;
					NS <= SUBI;
				end
				else if (instruction[15:12] == 4'b1011) begin // CMPI
					immRegEn <= 1;
					dstRegEn <= 1;
					irS <= 1;
					NS <= CMPI;
				end
				else if (instruction[15:12] == 4'b1101) begin // MOVI
					immRegEn <= 1;
					dstRegEn <= 1;
					irS <= 1;
					NS <= MOVI;
				end
				else if (instruction[15:12] == 4'b1111) begin // LUI
					immRegEn <= 1;
					dstRegEn <= 1;
					irS <= 1;
					NS <= LUI;
				end
			end
					
			ADD: begin 
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 0;
				aluControl <= 4'b1000;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				pcEn <= 2'b01;
				NS <= FETCH; 
			end
			
			SUB: begin 
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 0;
				aluControl <= 4'b0001;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				pcEn <= 2'b01;
				NS <= FETCH; 
			end
			
			CMP: begin 
				//regFileEn <= 1; // Don't delete yet
				//pcRegMuxEn <= 1;
				mux4En <= 0;
				aluControl <= 4'b0010;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				pcEn <= 2'b01;	
				NS <= FETCH;
			end
			
			AND: begin 
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 0;
				aluControl <= 4'b0011;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				pcEn <= 2'b01;
				NS <= FETCH; 
			end
			
			OR: begin 
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 0;
				aluControl <= 4'b0100;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				pcEn <= 2'b01;
				NS <= FETCH;
			end
			
			XOR: begin 
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 0;
				aluControl <= 4'b0101;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				pcEn <= 2'b01;
				NS <= FETCH;
			end
			
			MOV: begin // MOV
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 0;
				//aluControl <= 4'b0110;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				pcEn <= 2'b01;
				exMemResultEn <= 2'b10;
				NS <= FETCH;
			end
			
			LOAD: begin // LOAD
				regFileEn <= 1;
				memread <= 1;
				memwrite <= 0;
				exMemResultEn <= 2'b1;
				pcEn <= 2'b01;
				NS <= FETCH; // Added 11/10
			end
			
			STOR: begin // STOR
				regFileEn <= 0;
				memread <= 0;
				memwrite <= 1;
				exMemResultEn <= 2'b1;
				pcEn <= 2'b01;
				NS <= FETCH; // Added 11/10
			end
			
			JAL: begin // JAL
				//add more to this
				pcEn <= 2'b10;
				NS <= FETCH; 
			end
			
			JCOND: begin // Jcond
				pcEn <= 2'b01;
				case(instruction[11:8])
					4'b0000: // EQ Equal
						if (Z == 1)
							pcEn <= 2'b10;
					4'b0001: // NE Not Equal
						if (Z == 0)
							pcEn <= 2'b10;
					4'b1101: // GE Greater than or Equal
						if (N == 1 || Z == 1)
							pcEn <= 2'b10;
					4'b0010: // CS Carry Set
						if (C == 1)
							pcEn <= 2'b10;
					4'b0011: // CC Carry Clear
						if (C == 0)
							pcEn <= 2'b10;
					4'b0100: // HI Higher than
						if (L == 1)
							pcEn <= 2'b10;
					4'b0101: // LS Lower than or Same as
						if (L == 0)
							pcEn <= 2'b10;
					4'b1010: // LO Lower than
						if (L == 0 && Z == 0)
							pcEn <= 2'b10;
					4'b1011: // HS Higher than or Same as
						if (L == 1 || Z == 1)
							pcEn <= 2'b10;
					4'b0110: // GT Greater than
						if (N == 1)
							pcEn <= 2'b10;
					4'b0111: // LE Less than or Equal
						if (N == 0)
							pcEn <= 2'b10;
					4'b1000: // FS Flag Set
						if (F == 1)
							pcEn <= 2'b10;
					4'b1001: // FC Flag Clear
						if (F == 0)	
							pcEn <= 2'b10;
					4'b1100: // LT Less Than
						if (N == 0 && Z == 0)
							pcEn <= 2'b10;
					4'b1110: // UC Unconditional
						pcEn <= 2'b10;
					default:
						pcEn <= 2'b01;
				endcase
			end
			
			LSH: begin // LSH
				NS <= FETCH; 
			end
			
			LSHI: begin // LSHI
				NS <= FETCH; 
			end
			
			S15: begin // LSHI
				NS <= FETCH; 
			end
			
			BCOND: begin // Bcond
				pcEn <= 2'b11;
				NS <= FETCH; 
			end
			
			ANDI: begin // ANDI
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 2'b01;
				aluControl <= 4'b0011;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				irS <= 1;
				pcEn <= 2'b01;
				NS <= FETCH; 
			end
			
			ORI: begin // ORI
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 2'b01;
				aluControl <= 4'b0100;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				irS <= 1;
				pcEn <= 2'b01;
				NS <= FETCH;
			end
			
			XORI: begin // XORI
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 2'b01;
				aluControl <= 4'b0101;
				shiftALUMuxEn <=0;
				//resultRegEn <= 1;
				irS <= 1;
				pcEn <= 2'b01;
				NS <= FETCH;
			end
			
			ADDI: begin // ADDI
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 2'b01;
				aluControl <= 4'b1000;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				irS <= 1;
				pcEn <= 2'b01;
				NS <= FETCH; 
			end
			
			SUBI: begin // SUBI
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 2'b01;
				aluControl <= 4'b0001;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				irS <= 1;
				pcEn <= 2'b01;
				NS <= FETCH; 
			end
			
			CMPI: begin // CMPI
				//regFileEn <= 1; Don't delete yet
				//pcRegMuxEn <= 1;
				mux4En <= 2'b01;
				aluControl <= 4'b0010;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				irS <= 1;
				pcEn <= 2'b01;
				NS <= FETCH;
			end
			
			MOVI: begin // MOVI
				regFileEn <= 1;
				//pcRegMuxEn <= 1;
				mux4En <= 2'b01;
				shiftALUMuxEn <= 0;
				//resultRegEn <= 1;
				irS <= 1;
				pcEn <= 2'b01;
				exMemResultEn <= 2'b10;
				NS <= FETCH;
			end
			
			LUI: begin // LUI
				regFileEn <= 1;
				mux4En <= 2'b01;
				aluControl <= 4'b0110;
				shiftALUMuxEn <= 0;
				irS <= 1;
				pcEn <= 2'b01;
				memread <= 1;
				NS <= FETCH;
			end					
		endcase
	end
endmodule
