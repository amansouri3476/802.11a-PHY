`timescale 1ns/1ns
module cr_matcher(input rst, input clk, input [1:0]cr, input [1:0]x, input run, output valid, output [1:0]x_matched);
parameter s0 = 2'b00, s1 = 2'b01, s2 = 2'b10, s3 = 2'b11;
reg [1:0]s;
reg r1, r2;
wire [1:0]c1;
wire c2;
wire [1:0]new_s;

assign c1 = (cr == 2'b00) ? 2'b00 : (s == s0) ? 2'b00 : (s == s1) ? 2'b00 : (s == s2) ? 2'b01 : 2'b10;
assign c2 = (cr != 2'b01) ? 1'b0 : ((s == s0) || (s == s1)) ? 1'b0 : 1'b1;
assign valid = ((cr == 2'b00) || (s != s1)) ? run : 1'b0;
assign x_matched[1] = (c1 == 2'b00) ? x[1] : (c1 == 2'b01) ? r1 : r2;
assign x_matched[0] = (c2 == 1'b0) ? x[0] : x[1];
assign new_s = (s == s3) ? s0 : (s == s0) ? s1 : (s == s1) ? s2 : ((s == s2) && ((cr == 2'b00)||(cr == 2'b01))) ? s3 : s0;

always @ (posedge clk, negedge rst) begin
	if(~rst) begin
		s <= 2'b00;
		r1 <= 1'b0;
		r2 <= 1'b0;
	end
	else begin
		if(run) begin
			s <= new_s;
			r1 <= x[1];
			r2 <= x[0];
		end
		else begin
			s <= s;
			r1 <= r1;
			r2 <= r2;
		end
	end
end

endmodule
