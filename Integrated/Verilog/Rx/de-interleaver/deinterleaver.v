`timescale 1ns/1ns
module deinterleaver(input clk, input rst, input [1:0]mod, input [17:0]x0, input [17:0]x1, input run, output [1:0]x_deinterleaved, output valid);
parameter s9 = 4'd8,s1 = 4'd0,s2 = 4'd1,s3 = 4'd2,s4 = 4'd3,s5 = 4'd4,s6 = 4'd5,s7 = 4'd6,s8 = 4'd7;
reg [135:0]evens, odds;
reg [3:0]s;
wire [17:0]inter2_evens, inter2_odds;
wire count_run, gozero;
reg [135:0]new_evens, new_odds;
reg [1:0]inter_mod_even, inter_mod_odd;
reg [3:0]new_s;

assign count_run = (s == s9) ? 1'b1 : 1'b0;
assign valid = run || count_run;
assign x_deinterleaved[1] = (run == 1'b1) ? inter2_evens[0] : evens[135];
assign x_deinterleaved[0] = (run == 1'b1) ? inter2_odds[0] : odds[135];

always @ (*) begin
	if(s == s9) begin
		new_s = (gozero == 1'b1) ? s1 : s;
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
		new_s = (run == 1'b1) ? s9 : s;
	end
end

always @ (*) begin
	if((run == 1'b1) && (count_run == 1'b0)) begin
		new_evens = {evens[134:128],inter2_evens[1],evens[126:120],inter2_evens[2],evens[118:112],inter2_evens[3],evens[110:104],inter2_evens[4],evens[102:96],inter2_evens[5],evens[94:88],inter2_evens[6],evens[86:80],inter2_evens[7],evens[78:72],inter2_evens[8],evens[70:64],inter2_evens[9],evens[62:56],inter2_evens[10],evens[54:48],inter2_evens[11],evens[46:40],inter2_evens[12],evens[38:32],inter2_evens[13],evens[30:24],inter2_evens[14],evens[22:16],inter2_evens[15],evens[14:8],inter2_evens[16],evens[6:0],inter2_evens[17]};
		new_odds = {odds[134:128],inter2_odds[1],odds[126:120],inter2_odds[2],odds[118:112],inter2_odds[3],odds[110:104],inter2_odds[4],odds[102:96],inter2_odds[5],odds[94:88],inter2_odds[6],odds[86:80],inter2_odds[7],odds[78:72],inter2_odds[8],odds[70:64],inter2_odds[9],odds[62:56],inter2_odds[10],odds[54:48],inter2_odds[11],odds[46:40],inter2_odds[12],odds[38:32],inter2_odds[13],odds[30:24],inter2_odds[14],odds[22:16],inter2_odds[15],odds[14:8],inter2_odds[16],odds[6:0],inter2_odds[17]};
	end
	else if((run == 1'b0) && (count_run == 1'b1)) begin
		new_evens = {evens[134:0],inter2_evens[17]};
		new_odds = {odds[134:0],inter2_odds[17]};
	end
	else begin
		new_evens = evens[135:0];
		new_odds = odds[135:0];
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
		if((s == s9) || (s == s1)) begin
			inter_mod_even = 2'd0;
			inter_mod_odd = 2'd3;
		end
		else if(s == s2) begin
			inter_mod_even = 2'd2;
			inter_mod_odd = 2'd0;
		end
		else if(s == s3) begin
			inter_mod_even = 2'd3;
			inter_mod_odd = 2'd2;
		end
		else if(s == s4) begin
			inter_mod_even = 2'd0;
			inter_mod_odd = 2'd3;
		end
		else if(s == s5) begin
			inter_mod_even = 2'd2;
			inter_mod_odd = 2'd0;
		end
		else if(s == s6) begin
			inter_mod_even = 2'd3;
			inter_mod_odd = 2'd2;
		end
		else if(s == s7) begin
			inter_mod_even = 2'd0;
			inter_mod_odd = 2'd3;
		end
		else begin
			inter_mod_even = 2'd2;
			inter_mod_odd = 2'd0;
		end
	end
end

interleave2_even inter2_even(.inter_mod(inter_mod_even), .in(x0), .out(inter2_evens));
interleave2_odd inter2_odd(.inter_mod(inter_mod_odd), .in(x1), .out(inter2_odds));
counter8 counter(.clk(clk), .rst(rst), .run(count_run), .mod(mod), .gozero(gozero));

always @ (posedge clk, negedge rst) begin
	if(~rst) begin
		s <= 2'd0;
		evens <= 136'd0;
		odds <= 136'd0;
	end
	else begin
		s <= new_s;
		evens <= new_evens;
		odds <= new_odds;
	end
end

endmodule
