`timescale 1ns/1ns
module mapper_pi(input clk, input rst, input [1:0]mod, input [17:0]x0, input [17:0]x1, input run, output reg valid_tx, output[51:0]x_out_tx); // mapping and pilot insertion
reg [47:0]out_flop;
reg [2:0]s;
wire [47:0]x_out;
wire scram_run, pilot_type;
wire [1:0]useless;
reg [5:0]subc0, subc1, subc2, subc3, subc4, subc5;

assign scram_run = (s == 3'd0) ? run : 1'b0;
assign x_out_tx[51:48] = (s == 3'd0)?{pilot_type, 3'b001}:(s == 3'd1)? 4'd0:(s == 3'd2)?{pilot_type, 3'b001}:(s == 3'd3)? 4'd0:(s == 3'd4)?{pilot_type, 3'b001}:(s == 3'd5)? 4'd0:(s == 3'd6)?{(~pilot_type), 3'b001} : 4'd0;
assign x_out_tx[47:0] = out_flop;

always @ (*) begin
	if(mod == 2'd0) begin // BPSK
		subc0 = {5'd0, x0[0]};
		subc1 = {5'd0, x0[1]};
		subc2 = {5'd0, x0[2]};
		subc3 = {5'd0, x1[0]};
		subc4 = {5'd0, x1[1]};
		subc5 = {5'd0, x1[2]};
	end
	else if(mod == 2'd1) begin // QPSK
		subc0 = {4'd0, x0[1:0]};
		subc1 = {4'd0, x0[3:2]};
		subc2 = {4'd0, x0[5:4]};
		subc3 = {4'd0, x1[1:0]};
		subc4 = {4'd0, x1[3:2]};
		subc5 = {4'd0, x1[5:4]};
	end
	else if(mod == 2'd2) begin // 16-QAM
		subc0 = {2'd0, x0[3:0]};
		subc1 = {2'd0, x0[7:4]};
		subc2 = {2'd0, x0[11:8]};
		subc3 = {2'd0, x1[3:0]};
		subc4 = {2'd0, x1[7:4]};
		subc5 = {2'd0, x1[11:8]};
	end
	else begin // 64-QAM
		subc0 = x0[5:0];
		subc1 = x0[11:6];
		subc2 = x0[17:12];
		subc3 = x1[5:0];
		subc4 = x1[11:6];
		subc5 = x1[17:12];
	end
end

mapper map0(.x(subc0), .mod(mod), .x_mapped(x_out[7:0]));
mapper map1(.x(subc1), .mod(mod), .x_mapped(x_out[15:8]));
mapper map2(.x(subc2), .mod(mod), .x_mapped(x_out[23:16]));
mapper map3(.x(subc3), .mod(mod), .x_mapped(x_out[31:24]));
mapper map4(.x(subc4), .mod(mod), .x_mapped(x_out[39:32]));
mapper map5(.x(subc5), .mod(mod), .x_mapped(x_out[47:40]));
scrambler scram_pilot(.x(1'b0), .initialState(7'd127), .run(scram_run), .clk(clk), .reset(rst), .x_scrambled(pilot_type), .valid(useless[1]), .rdy(useless[0]));

always @ (posedge clk, negedge rst) begin
	if(~rst) begin
		s <= 3'd0;
		out_flop <= 48'd0;
		valid_tx <= 1'b0;
	end
	else begin
		valid_tx <= run;
		if(run) begin
			s <= s + 1'b1;
			out_flop <= x_out;
		end
		else begin
			s <= s;
			out_flop <= out_flop;
		end
	end
end

endmodule
