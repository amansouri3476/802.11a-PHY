`timescale 1ns/1ns
module encoder(input clk, input rst, input x, input run, output [1:0]x_encoded, output valid);
// we will add some register at the encoder's output to improve timing in phase 4 if needed

reg [5:0]state;

assign valid = run;
assign x_encoded[1] = x ^ state[4] ^ state[3] ^ state[1] ^ state[0];
assign x_encoded[0] = x ^ state[5] ^ state[4] ^ state[3] ^ state[0];

always @ (posedge clk, negedge rst) begin
	if(~rst) begin
		state <= 6'd0;
	end
	else begin
		if(valid) begin
			state[4:0] <= state[5:1];
			state[5] <= x;
			end
		else begin // if our input isn't valid encoder states will not change
			state[5:0] <= state[5:0]; 
		end
	end
end

endmodule
