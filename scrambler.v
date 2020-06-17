`timescale 1ns/1ns

// Note that tail 6 bits should be set to zero after scrambling but we are NOT concerned with that issue in this module. This module solely operates the scrambling
// and that issue should be handled elsewhere in the integration and matching phase.

module scrambler(input x, input [6:0] initialState, input MODE, // MODE determines whether we are using this module in scrambler or descrambler mode
		input clk, input reset, output reg x_scrambled
		// , output wire [6:0] scrambled_seq
		, output reg valid); // valid bit is required since after first posedge, there's no valid output to be read by the next module or be written to a file.
									// After one clk, the output is ready to be propagated through subsequent modules.
	
	reg [6:0] scramblerInitBits;
	integer counter;
	always@(posedge clk, negedge reset) begin
		
		if(reset == 0) begin
			scramblerInitBits <= initialState;
			valid <= 0;
			counter = 0;
			
		end
		else begin 
			if (MODE == 1'b1 && counter >= 1) begin
				valid <= 1'b1;
				// counter = counter + 1;
				scramblerInitBits[6:1] <= scramblerInitBits[5:0]; 				     // Left-shift
				scramblerInitBits[0] <= (scramblerInitBits[6])^(scramblerInitBits[3]); // Update x1 and x7 xor x4
				x_scrambled <= x^((scramblerInitBits[6])^(scramblerInitBits[3]));
			end
			else if(MODE == 1'b0 && counter >= 2) begin
				valid <= 1'b1;
				// counter = counter + 1;
				scramblerInitBits[6:1] <= scramblerInitBits[5:0]; 				     // Left-shift
				scramblerInitBits[0] <= (scramblerInitBits[6])^(scramblerInitBits[3]); // Update x1 and x7 xor x4
				x_scrambled <= x^((scramblerInitBits[6])^(scramblerInitBits[3]));
			end
			counter = counter + 1;
		end
	
	end
	
endmodule
