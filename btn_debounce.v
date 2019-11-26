module btn_debounce #(parameter CLK_PERIOD = 50)
							(clk, in_btn, out_btn);
	input clk, in_btn;
	output out_btn;
	
	wire en;
	
	en_counter 	#(CLK_PERIOD) ec 	(.clk(clk), .btn(in_btn), .en(en));
	single_register  			  r1 	(.clk(clk), .en(en), .d(in_btn), .q(out_btn));
	
	
endmodule


module en_counter #(parameter CLK_PERIOD = 50)
						(clk, btn, en);
	input clk, btn;
	output reg en;
	
	integer counter = 0;
	
	always @(posedge clk, negedge btn) begin
		if (!btn) begin
			counter <= 0;
			en <= 1'b1;
		end
		else if (counter > CLK_PERIOD)
			counter <= 0;	
		else begin
			if (counter == CLK_PERIOD)
				en <= 1'b1;
			else
				en <= 1'b0;
			counter <= counter + 1;
		end
	end
	
endmodule

