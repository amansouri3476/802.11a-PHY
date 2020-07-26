`timescale 1ns/1ns
module TX(input clk, input rst, input in, input run, input [3:0]rate, input tx_request, output [51:0]out, output valid, output ready, output reg [1:0]cr, output reg [1:0]mod);
reg [3:0]rate_reg;
wire run1, run2, run3, run4;
wire x_scrambled;
wire [1:0]x_encoded, x_matched;
wire [17:0]x0_interleaved, x1_interleaved;
wire [3:0]new_rate_reg;

assign new_rate_reg = (tx_request == 1'b1) ? rate : rate_reg;

scrambler tx_scrambler(.x(in), .initialState(7'd127), .run(run), .clk(clk), .reset(rst), .x_scrambled(x_scrambled), .valid(run1), .rdy(ready));
encoder tx_encoder(.clk(clk), .rst(rst), .x(x_scrambled), .run(run1), .x_encoded(x_encoded), .valid(run2));
cr_matcher tx_cr_matcher(.rst(rst), .clk(clk), .cr(cr), .x(x_encoded), .run(run2), .valid(run3), .x_matched(x_matched));
interleaver tx_interleaver(.clk(clk), .rst(rst), .run(run3), .x(x_matched), .mod(mod), .valid(run4), .x0_interleaved(x0_interleaved), .x1_interleaved(x1_interleaved));
mapper_pi tx_mapper_pi(.clk(clk), .rst(rst), .mod(mod), .x0(x0_interleaved), .x1(x1_interleaved), .run(run4), .valid_tx(valid), .x_out_tx(out));

always @ (*) begin
	if(rate_reg == 4'b1101) begin // 6 Mbits/s
		cr = 2'b00 ;
		mod = 2'b00 ;
	end
	else if(rate_reg == 4'b1111) begin // 9 Mbits/s
		cr = 2'b10 ;
		mod = 2'b00 ;
	end
	else if(rate_reg == 4'b0101) begin // 12 Mbits/s
		cr = 2'b00 ;
		mod = 2'b01 ;
	end
	else if(rate_reg == 4'b0111) begin // 18 Mbits/s
		cr = 2'b10 ;
		mod = 2'b01 ;
	end
	else if(rate_reg == 4'b1001) begin // 24 Mbits/s
		cr = 2'b00 ;
		mod = 2'b10 ;
	end
	else if(rate_reg == 4'b1011) begin // 36 Mbits/s
		cr = 2'b10 ;
		mod = 2'b10 ;
	end
	else if(rate_reg == 4'b0001) begin // 48 Mbits/s
		cr = 2'b01 ;
		mod = 2'b11 ;
	end
	else begin // 54 Mbits/s (4'b0011)
		cr = 2'b10 ;
		mod = 2'b11 ;
	end
end

always @ (posedge clk, negedge rst) begin
	if(~rst) begin
		rate_reg <= 4'd0;
	end
	else begin
		rate_reg <= new_rate_reg;
	end
end

endmodule
