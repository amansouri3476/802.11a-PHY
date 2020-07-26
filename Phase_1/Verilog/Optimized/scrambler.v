`timescale 1ns/1ns

// Note that tail 6 bits should be set to zero after scrambling but we are NOT concerned with that issue in this module. This module solely operates the scrambling
// and that issue should be handled elsewhere in the integration and matching phase.

module scrambler(input x, input [6:0] initialState, input run, // 
		input clk, input reset, output reg x_scrambled
		// , output wire [6:0] scrambled_seq
		, output reg valid, output rdy);
	
	parameter seed_init = 1'b0, ready = 1'b1;
	wire valid_run, internal_xor;
	reg [6:0] scramblerInitBits;
	reg State;
	
	assign rdy = State; // S == ready
	assign valid_run = run & rdy; // we run circuit only when we are ready! (internal protection)
	assign internal_xor = scramblerInitBits[6] ^ scramblerInitBits[3];
	
	always @(posedge clk, negedge reset) begin
		if(~reset) begin
			State <= 1'b0; // seed_init state
			scramblerInitBits[6:0] <= 7'd0;
			x_scrambled <= 1'b0;
			valid <= 1'b0;
		end
		else begin
			valid <= valid_run; // if we do a valid run, in the next clock we will have valid output
			if(State == seed_init) begin
				State <= ready;
				scramblerInitBits[6:0] <= initialState[6:0];
				x_scrambled <= x_scrambled;
			end
			else begin  // S == ready
				State <= State;
				if(valid_run) begin
					scramblerInitBits[6:1] <= scramblerInitBits[5:0]; 
					scramblerInitBits[0] <= internal_xor;
					x_scrambled <= x ^ internal_xor;
				end
				else begin // invalid run, so we don't do any action
					scramblerInitBits[6:0] <= scramblerInitBits[6:0];
					x_scrambled <= x_scrambled;
				end
			end
		end
	end
	
endmodule
