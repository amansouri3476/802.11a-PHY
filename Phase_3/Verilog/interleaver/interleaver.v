`timescale 1ns/1ns
module interleaver(input clk, input rst, input run, input [1:0]x, input [1:0]mod, output valid, output [17:0]x0_interleaved, output [17:0]x1_interleaved);
parameter s0 = 4'd0,s1 = 4'd1,s2 = 4'd2,s3 = 4'd3,s4 = 4'd4,s5 = 4'd5,s6 = 4'd6,s7 = 4'd7,s8 = 4'd8;
reg [135:0]evens, odds;
reg [3:0]s;
wire [17:0]inter1_evens, inter1_odds, pre_x_even, pre_x_odd;
wire gozero, count_run;
reg [1:0]inter_mod_even, inter_mod_odd;
reg [3:0]new_s;

assign inter1_evens[17:0] = {evens[0], evens[8], evens[16], evens[24], evens[32], evens[40], evens[48], evens[56], evens[64], evens[72], evens[80], evens[88], evens[96], evens[104], evens[112], evens[120], evens[128], x[1]};
assign inter1_odds[17:0] = {odds[0], odds[8], odds[16], odds[24], odds[32], odds[40], odds[48], odds[56], odds[64], odds[72], odds[80], odds[88], odds[96], odds[104], odds[112], odds[120], odds[128], x[0]};
assign count_run = (s == s0) ? run : 1'b0;
assign valid = (s != s0) ? run : 1'b0;

always @ (*) begin
	if(s == s0) begin
		new_s = ((run == 1'b1) && (gozero == 1'b1)) ? s1 : s;
	end
	else if(s == s1) begin
		new_s = (run == 1'b1) ? s2 : s;
	end
	else if(s == s2) begin
		new_s = (run == 1'b1) ? s3 : s;
	end
	else if(s == s3) begin
		new_s = (run == 1'b1) ? s4 : s;
	end
	else if(s == s4) begin
		new_s = (run == 1'b1) ? s5 : s;
	end
	else if(s == s5) begin
		new_s = (run == 1'b1) ? s6 : s;
	end
	else if(s == s6) begin
		new_s = (run == 1'b1) ? s7 : s;
	end
	else if(s == s7) begin
		new_s = (run == 1'b1) ? s8 : s;
	end
	else begin
		new_s = (run == 1'b1) ? s0 : s;
	end
end

always @ (*) begin
	if((mod == 2'd0) || (mod == 2'd1)) begin
		inter_mod_even = 2'd0;
		inter_mod_odd = 2'd0;
	end
	else if(mod == 2'd2) begin
		inter_mod_even = 2'd0;
		inter_mod_odd = 2'd1;
	end
	else begin
		if((s == s0) || (s == s1)) begin
			inter_mod_even = 2'd0;
			inter_mod_odd = 2'd2;
		end
		else if(s == s2) begin
			inter_mod_even = 2'd3;
			inter_mod_odd = 2'd0;
		end
		else if(s == s3) begin
			inter_mod_even = 2'd2;
			inter_mod_odd = 2'd3;
		end
		else if(s == s4) begin
			inter_mod_even = 2'd0;
			inter_mod_odd = 2'd2;
		end
		else if(s == s5) begin
			inter_mod_even = 2'd3;
			inter_mod_odd = 2'd0;
		end
		else if(s == s6) begin
			inter_mod_even = 2'd2;
			inter_mod_odd = 2'd3;
		end
		else if(s == s7) begin
			inter_mod_even = 2'd0;
			inter_mod_odd = 2'd2;
		end
		else begin
			inter_mod_even = 2'd3;
			inter_mod_odd = 2'd0;
		end
	end
end

interleave2_even inter2_even(.inter_mod(inter_mod_even), .in(inter1_evens), .out(pre_x_even));
interleave2_odd inter2_odd(.inter_mod(inter_mod_odd), .in(inter1_odds), .out(pre_x_odd));
counter8 counter(.clk(clk), .rst(rst), .run(count_run), .mod(mod), .gozero(gozero));
regulator regulator_even(.x(pre_x_even), .mod(mod), .x_regulated(x0_interleaved));
regulator regulator_odd(.x(pre_x_odd), .mod(mod), .x_regulated(x1_interleaved));

always @ (posedge clk, negedge rst) begin
	if(~rst) begin
		s <= 4'd0;
		evens <= 136'd0;
		odds <= 136'd0;
	end
	else begin
		s <= new_s;
		if(run == 1'b1) begin
			evens <= {x[1], evens[135:1]};
			odds <= {x[0], odds[135:1]};
		end
		else begin
			evens <= evens;
			odds <= odds;
		end
	end
end


endmodule
