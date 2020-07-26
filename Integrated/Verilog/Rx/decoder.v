`timescale 1ns/1ns
module decoder (input [1:0]x, input clk, input rst, input run, output reg valid, output x_decoded);
parameter err_len = 4; 
reg [err_len*64-1:0]errors;
reg [63:0]path_mem[11:0][1:0];
reg [5:0]mpn0; // min_path_num
reg [21:0]mpn;
reg [23:0]out_reg;
reg go_back, cb_go_back, cb_start, run1;
wire [err_len*64-1:0]err_add_in;
wire [err_len*64-1:0]err_0_in;
wire [err_len*64-1:0]err_1_in;
wire [err_len*64-1:0]new_errors;
wire [err_len*64-1:0]min_out;
wire [err_len*64-1:0]min8_in;
wire [63:0]mem_out[1:0];
wire [3*8-1:0]min_idx;
wire [err_len*8-1:0]inner_min;
wire [2:0]min_idx_left;
wire [63:0]start_state;
wire [63:0]discarded_bits;
wire [5:0]start_state_num;
wire [4:0]memptr;
wire [4:0]cb_memptr;
wire start, zero, gozero, gozero1, min_en, bit1, bit2, to_out, new_go_back, new_cb_go_back, new_valid, gozero2, new_cb_start, new_run1;
wire [4:0]count;
wire [3:0]count1;
wire [21:0]new_mpn;
wire [21:0]state_select;
wire [23:0]out_pack;
wire [23:0]new_out_reg;
wire [5:0]new_mpn0;
reg [2:0]min_idx_right;


assign min8_in = (min_en == 1'b1) ? min_out: {(err_len*64){1'b1}}; // power saving
assign start_state_num = {min_idx_left , min_idx_right};
assign start = zero;
assign memptr = (go_back == 1'b0) ? count : (5'd23 - count);
assign cb_memptr = (cb_go_back == 1'b1) ? count1 : (5'd11 - count1);
assign state_select = (cb_start == 1'b1) ? {16'd0, mpn0[5:0]} : mpn[21:0];
assign new_mpn = {state_select[19:0], bit1, bit2};
assign out_pack = {mpn, bit1, bit2};
assign new_out_reg = ({to_out,valid} == 2'b00) ? out_reg : ({to_out,valid} == 2'b10) ? out_pack : {1'b0,out_reg[23:1]};
assign new_errors = (run) ? min_out : errors;
assign new_mpn0 = (min_en == 1'b1) ? start_state_num :  mpn0;
assign min_en = gozero & run;
assign mem_out[0] = path_mem[cb_memptr][0];
assign mem_out[1] = path_mem[cb_memptr][1];
assign bit1 = (cb_go_back == 1'b1) ? mem_out[0][state_select[5:0]] : mem_out[1][state_select[5:0]];
assign bit2 = (cb_go_back == 1'b1) ? mem_out[1][{state_select[4:0],bit1}] : mem_out[0][{state_select[4:0],bit1}];
assign new_go_back = (min_en == 1'b1) ? ~go_back : go_back;
assign new_cb_go_back = (gozero1 == 1'b1) ? ~cb_go_back : cb_go_back;
assign new_valid = ({to_out,gozero2} == 2'b10) ? 1'b1 : ({to_out,gozero2} == 2'b11) ? 1'b1 : ({to_out,gozero2} == 2'b01) ? 1'b0 : valid;
assign new_cb_start = min_en;
assign new_run1 = ({min_en,gozero1} == 2'b10) ? 1'b1 : ({min_en,gozero1} == 2'b01) ? 1'b0 : run1;
assign to_out = count1_8;
assign run2 = valid;
assign x_decoded = out_reg[0];


always @(*) begin
	if(min_idx_left == 3'd0) begin
		min_idx_right = min_idx[2:0];
	end
	else if(min_idx_left == 3'd1) begin
		min_idx_right = min_idx[5:3];
	end
	else if(min_idx_left == 3'd2) begin
		min_idx_right = min_idx[8:6];
	end
	else if(min_idx_left == 3'd3) begin
		min_idx_right = min_idx[11:9];
	end
	else if(min_idx_left == 3'd4) begin
		min_idx_right = min_idx[14:12];
	end
	else if(min_idx_left == 3'd5) begin
		min_idx_right = min_idx[17:15];
	end
	else if(min_idx_left == 3'd6) begin
		min_idx_right = min_idx[20:18];
	end
	else begin
		min_idx_right = min_idx[23:21];
	end
end


generate
	genvar i;
	for(i=0;i<64;i=i+1) begin : err_add_instantiate
		assign err_add_in[(i+1)*err_len-1:i*err_len] = ({start,start_state[i]} == 2'b11) ? {err_len{1'b0}} : ({start,start_state[i]} == 2'b10) ? {err_len{1'b1}} : errors[(i+1)*err_len-1:i*err_len];
		assign start_state[i] = (mpn0[5:0] == i) ? 1'b1 : 1'b0;
	end
	for(i=0;i<32;i=i+1) begin : min_first_half_instantiate
		min_error #(.m(err_len-1)) min_err0(.error_0_out(err_0_in[(2*i+1)*err_len-1:2*i*err_len]), .error_1_out(err_0_in[(2*i+2)*err_len-1:(2*i+1)*err_len]), .error_min(min_out[(i+1)*err_len-1:i*err_len]), .out_bit(discarded_bits[i]));
	end
	for(i=32;i<64;i=i+1) begin : min_second_half_instantiate
		min_error #(.m(err_len-1)) min_err1(.error_0_out(err_1_in[(2*(i-32)+1)*err_len-1:2*(i-32)*err_len]), .error_1_out(err_1_in[(2*(i-32)+2)*err_len-1:(2*(i-32)+1)*err_len]), .error_min(min_out[(i+1)*err_len-1:i*err_len]), .out_bit(discarded_bits[i]));
	end
	for(i=0;i<8;i=i+1) begin : min8_instantiate
		min8 #(.m(err_len-1)) min8_err(.in0(min8_in[(8*i+1)*err_len-1:8*i*err_len]), .in1(min8_in[(8*i+2)*err_len-1:(8*i+1)*err_len]), .in2(min8_in[(8*i+3)*err_len-1:(8*i+2)*err_len]), .in3(min8_in[(8*i+4)*err_len-1:(8*i+3)*err_len]), .in4(min8_in[(8*i+5)*err_len-1:(8*i+4)*err_len]), .in5(min8_in[(8*i+6)*err_len-1:(8*i+5)*err_len]), .in6(min8_in[(8*i+7)*err_len-1:(8*i+6)*err_len]), .in7(min8_in[(8*i+8)*err_len-1:(8*i+7)*err_len]), .min_index(min_idx[3*(i+1)-1:3*i]), .in_min(inner_min[(i+1)*err_len-1:i*err_len]));
	end
	
endgenerate

min8_index #(.m(err_len-1)) last_min8(.in0(inner_min[err_len-1:0]), .in1(inner_min[2*err_len-1:err_len]), .in2(inner_min[3*err_len-1:2*err_len]), .in3(inner_min[4*err_len-1:3*err_len]), .in4(inner_min[5*err_len-1:4*err_len]), .in5(inner_min[6*err_len-1:5*err_len]), .in6(inner_min[7*err_len-1:6*err_len]), .in7(inner_min[8*err_len-1:7*err_len]), .min_index(min_idx_left));
counter0_23 counter(.clk(clk), .rst(rst), .run(run), .count(count), .zero(zero), .gozero(gozero));
counter1_12 counter1(.clk(clk), .rst(rst), .run(run1), .count(count1), .count_8(count1_8), .gozero(gozero1));
counter2_23 counter2(.clk(clk), .rst(rst), .run(run2), .gozero(gozero2));

always @(posedge clk, negedge rst) begin
	if(~rst) begin
		errors <= 'd0;
		mpn0 <= 6'd0;
		go_back <= 1'b0;
		cb_go_back <= 1'b0;
		cb_start <= 1'b0;
		run1 <= 1'b0;
		valid <= 1'b0;
		out_reg <= 24'd0;
	end
	else begin
		valid <= new_valid;
		errors <= new_errors;
		path_mem[memptr[4:1]][memptr[0]] <= (run == 1'b1) ? discarded_bits : path_mem[memptr[4:1]][memptr[0]];
		mpn0 <= new_mpn0;
		mpn <= new_mpn;
		out_reg <= new_out_reg;
		go_back <= new_go_back;
		cb_go_back <= new_cb_go_back;
		cb_start <= new_cb_start;
		run1 <= new_run1;
	end
end


// this piece of code was written using matlab script:
error_adder #(.m(err_len-1)) err_add0(.error(err_add_in[1*err_len-1:0*err_len]), .a(x), .error_0_in(err_0_in[1*err_len-1:0*err_len]), .error_1_in(err_1_in[1*err_len-1:0*err_len]));
error_adder3 #(.m(err_len-1)) err_add1(.error(err_add_in[2*err_len-1:1*err_len]), .a(x), .error_0_in(err_0_in[2*err_len-1:1*err_len]), .error_1_in(err_1_in[2*err_len-1:1*err_len]));
error_adder2 #(.m(err_len-1)) err_add2(.error(err_add_in[3*err_len-1:2*err_len]), .a(x), .error_0_in(err_0_in[3*err_len-1:2*err_len]), .error_1_in(err_1_in[3*err_len-1:2*err_len]));
error_adder1 #(.m(err_len-1)) err_add3(.error(err_add_in[4*err_len-1:3*err_len]), .a(x), .error_0_in(err_0_in[4*err_len-1:3*err_len]), .error_1_in(err_1_in[4*err_len-1:3*err_len]));
error_adder #(.m(err_len-1)) err_add4(.error(err_add_in[5*err_len-1:4*err_len]), .a(x), .error_0_in(err_0_in[5*err_len-1:4*err_len]), .error_1_in(err_1_in[5*err_len-1:4*err_len]));
error_adder3 #(.m(err_len-1)) err_add5(.error(err_add_in[6*err_len-1:5*err_len]), .a(x), .error_0_in(err_0_in[6*err_len-1:5*err_len]), .error_1_in(err_1_in[6*err_len-1:5*err_len]));
error_adder2 #(.m(err_len-1)) err_add6(.error(err_add_in[7*err_len-1:6*err_len]), .a(x), .error_0_in(err_0_in[7*err_len-1:6*err_len]), .error_1_in(err_1_in[7*err_len-1:6*err_len]));
error_adder1 #(.m(err_len-1)) err_add7(.error(err_add_in[8*err_len-1:7*err_len]), .a(x), .error_0_in(err_0_in[8*err_len-1:7*err_len]), .error_1_in(err_1_in[8*err_len-1:7*err_len]));
error_adder3 #(.m(err_len-1)) err_add8(.error(err_add_in[9*err_len-1:8*err_len]), .a(x), .error_0_in(err_0_in[9*err_len-1:8*err_len]), .error_1_in(err_1_in[9*err_len-1:8*err_len]));
error_adder #(.m(err_len-1)) err_add9(.error(err_add_in[10*err_len-1:9*err_len]), .a(x), .error_0_in(err_0_in[10*err_len-1:9*err_len]), .error_1_in(err_1_in[10*err_len-1:9*err_len]));
error_adder1 #(.m(err_len-1)) err_add10(.error(err_add_in[11*err_len-1:10*err_len]), .a(x), .error_0_in(err_0_in[11*err_len-1:10*err_len]), .error_1_in(err_1_in[11*err_len-1:10*err_len]));
error_adder2 #(.m(err_len-1)) err_add11(.error(err_add_in[12*err_len-1:11*err_len]), .a(x), .error_0_in(err_0_in[12*err_len-1:11*err_len]), .error_1_in(err_1_in[12*err_len-1:11*err_len]));
error_adder3 #(.m(err_len-1)) err_add12(.error(err_add_in[13*err_len-1:12*err_len]), .a(x), .error_0_in(err_0_in[13*err_len-1:12*err_len]), .error_1_in(err_1_in[13*err_len-1:12*err_len]));
error_adder #(.m(err_len-1)) err_add13(.error(err_add_in[14*err_len-1:13*err_len]), .a(x), .error_0_in(err_0_in[14*err_len-1:13*err_len]), .error_1_in(err_1_in[14*err_len-1:13*err_len]));
error_adder1 #(.m(err_len-1)) err_add14(.error(err_add_in[15*err_len-1:14*err_len]), .a(x), .error_0_in(err_0_in[15*err_len-1:14*err_len]), .error_1_in(err_1_in[15*err_len-1:14*err_len]));
error_adder2 #(.m(err_len-1)) err_add15(.error(err_add_in[16*err_len-1:15*err_len]), .a(x), .error_0_in(err_0_in[16*err_len-1:15*err_len]), .error_1_in(err_1_in[16*err_len-1:15*err_len]));
error_adder3 #(.m(err_len-1)) err_add16(.error(err_add_in[17*err_len-1:16*err_len]), .a(x), .error_0_in(err_0_in[17*err_len-1:16*err_len]), .error_1_in(err_1_in[17*err_len-1:16*err_len]));
error_adder #(.m(err_len-1)) err_add17(.error(err_add_in[18*err_len-1:17*err_len]), .a(x), .error_0_in(err_0_in[18*err_len-1:17*err_len]), .error_1_in(err_1_in[18*err_len-1:17*err_len]));
error_adder1 #(.m(err_len-1)) err_add18(.error(err_add_in[19*err_len-1:18*err_len]), .a(x), .error_0_in(err_0_in[19*err_len-1:18*err_len]), .error_1_in(err_1_in[19*err_len-1:18*err_len]));
error_adder2 #(.m(err_len-1)) err_add19(.error(err_add_in[20*err_len-1:19*err_len]), .a(x), .error_0_in(err_0_in[20*err_len-1:19*err_len]), .error_1_in(err_1_in[20*err_len-1:19*err_len]));
error_adder3 #(.m(err_len-1)) err_add20(.error(err_add_in[21*err_len-1:20*err_len]), .a(x), .error_0_in(err_0_in[21*err_len-1:20*err_len]), .error_1_in(err_1_in[21*err_len-1:20*err_len]));
error_adder #(.m(err_len-1)) err_add21(.error(err_add_in[22*err_len-1:21*err_len]), .a(x), .error_0_in(err_0_in[22*err_len-1:21*err_len]), .error_1_in(err_1_in[22*err_len-1:21*err_len]));
error_adder1 #(.m(err_len-1)) err_add22(.error(err_add_in[23*err_len-1:22*err_len]), .a(x), .error_0_in(err_0_in[23*err_len-1:22*err_len]), .error_1_in(err_1_in[23*err_len-1:22*err_len]));
error_adder2 #(.m(err_len-1)) err_add23(.error(err_add_in[24*err_len-1:23*err_len]), .a(x), .error_0_in(err_0_in[24*err_len-1:23*err_len]), .error_1_in(err_1_in[24*err_len-1:23*err_len]));
error_adder #(.m(err_len-1)) err_add24(.error(err_add_in[25*err_len-1:24*err_len]), .a(x), .error_0_in(err_0_in[25*err_len-1:24*err_len]), .error_1_in(err_1_in[25*err_len-1:24*err_len]));
error_adder3 #(.m(err_len-1)) err_add25(.error(err_add_in[26*err_len-1:25*err_len]), .a(x), .error_0_in(err_0_in[26*err_len-1:25*err_len]), .error_1_in(err_1_in[26*err_len-1:25*err_len]));
error_adder2 #(.m(err_len-1)) err_add26(.error(err_add_in[27*err_len-1:26*err_len]), .a(x), .error_0_in(err_0_in[27*err_len-1:26*err_len]), .error_1_in(err_1_in[27*err_len-1:26*err_len]));
error_adder1 #(.m(err_len-1)) err_add27(.error(err_add_in[28*err_len-1:27*err_len]), .a(x), .error_0_in(err_0_in[28*err_len-1:27*err_len]), .error_1_in(err_1_in[28*err_len-1:27*err_len]));
error_adder #(.m(err_len-1)) err_add28(.error(err_add_in[29*err_len-1:28*err_len]), .a(x), .error_0_in(err_0_in[29*err_len-1:28*err_len]), .error_1_in(err_1_in[29*err_len-1:28*err_len]));
error_adder3 #(.m(err_len-1)) err_add29(.error(err_add_in[30*err_len-1:29*err_len]), .a(x), .error_0_in(err_0_in[30*err_len-1:29*err_len]), .error_1_in(err_1_in[30*err_len-1:29*err_len]));
error_adder2 #(.m(err_len-1)) err_add30(.error(err_add_in[31*err_len-1:30*err_len]), .a(x), .error_0_in(err_0_in[31*err_len-1:30*err_len]), .error_1_in(err_1_in[31*err_len-1:30*err_len]));
error_adder1 #(.m(err_len-1)) err_add31(.error(err_add_in[32*err_len-1:31*err_len]), .a(x), .error_0_in(err_0_in[32*err_len-1:31*err_len]), .error_1_in(err_1_in[32*err_len-1:31*err_len]));
error_adder1 #(.m(err_len-1)) err_add32(.error(err_add_in[33*err_len-1:32*err_len]), .a(x), .error_0_in(err_0_in[33*err_len-1:32*err_len]), .error_1_in(err_1_in[33*err_len-1:32*err_len]));
error_adder2 #(.m(err_len-1)) err_add33(.error(err_add_in[34*err_len-1:33*err_len]), .a(x), .error_0_in(err_0_in[34*err_len-1:33*err_len]), .error_1_in(err_1_in[34*err_len-1:33*err_len]));
error_adder3 #(.m(err_len-1)) err_add34(.error(err_add_in[35*err_len-1:34*err_len]), .a(x), .error_0_in(err_0_in[35*err_len-1:34*err_len]), .error_1_in(err_1_in[35*err_len-1:34*err_len]));
error_adder #(.m(err_len-1)) err_add35(.error(err_add_in[36*err_len-1:35*err_len]), .a(x), .error_0_in(err_0_in[36*err_len-1:35*err_len]), .error_1_in(err_1_in[36*err_len-1:35*err_len]));
error_adder1 #(.m(err_len-1)) err_add36(.error(err_add_in[37*err_len-1:36*err_len]), .a(x), .error_0_in(err_0_in[37*err_len-1:36*err_len]), .error_1_in(err_1_in[37*err_len-1:36*err_len]));
error_adder2 #(.m(err_len-1)) err_add37(.error(err_add_in[38*err_len-1:37*err_len]), .a(x), .error_0_in(err_0_in[38*err_len-1:37*err_len]), .error_1_in(err_1_in[38*err_len-1:37*err_len]));
error_adder3 #(.m(err_len-1)) err_add38(.error(err_add_in[39*err_len-1:38*err_len]), .a(x), .error_0_in(err_0_in[39*err_len-1:38*err_len]), .error_1_in(err_1_in[39*err_len-1:38*err_len]));
error_adder #(.m(err_len-1)) err_add39(.error(err_add_in[40*err_len-1:39*err_len]), .a(x), .error_0_in(err_0_in[40*err_len-1:39*err_len]), .error_1_in(err_1_in[40*err_len-1:39*err_len]));
error_adder2 #(.m(err_len-1)) err_add40(.error(err_add_in[41*err_len-1:40*err_len]), .a(x), .error_0_in(err_0_in[41*err_len-1:40*err_len]), .error_1_in(err_1_in[41*err_len-1:40*err_len]));
error_adder1 #(.m(err_len-1)) err_add41(.error(err_add_in[42*err_len-1:41*err_len]), .a(x), .error_0_in(err_0_in[42*err_len-1:41*err_len]), .error_1_in(err_1_in[42*err_len-1:41*err_len]));
error_adder #(.m(err_len-1)) err_add42(.error(err_add_in[43*err_len-1:42*err_len]), .a(x), .error_0_in(err_0_in[43*err_len-1:42*err_len]), .error_1_in(err_1_in[43*err_len-1:42*err_len]));
error_adder3 #(.m(err_len-1)) err_add43(.error(err_add_in[44*err_len-1:43*err_len]), .a(x), .error_0_in(err_0_in[44*err_len-1:43*err_len]), .error_1_in(err_1_in[44*err_len-1:43*err_len]));
error_adder2 #(.m(err_len-1)) err_add44(.error(err_add_in[45*err_len-1:44*err_len]), .a(x), .error_0_in(err_0_in[45*err_len-1:44*err_len]), .error_1_in(err_1_in[45*err_len-1:44*err_len]));
error_adder1 #(.m(err_len-1)) err_add45(.error(err_add_in[46*err_len-1:45*err_len]), .a(x), .error_0_in(err_0_in[46*err_len-1:45*err_len]), .error_1_in(err_1_in[46*err_len-1:45*err_len]));
error_adder #(.m(err_len-1)) err_add46(.error(err_add_in[47*err_len-1:46*err_len]), .a(x), .error_0_in(err_0_in[47*err_len-1:46*err_len]), .error_1_in(err_1_in[47*err_len-1:46*err_len]));
error_adder3 #(.m(err_len-1)) err_add47(.error(err_add_in[48*err_len-1:47*err_len]), .a(x), .error_0_in(err_0_in[48*err_len-1:47*err_len]), .error_1_in(err_1_in[48*err_len-1:47*err_len]));
error_adder2 #(.m(err_len-1)) err_add48(.error(err_add_in[49*err_len-1:48*err_len]), .a(x), .error_0_in(err_0_in[49*err_len-1:48*err_len]), .error_1_in(err_1_in[49*err_len-1:48*err_len]));
error_adder1 #(.m(err_len-1)) err_add49(.error(err_add_in[50*err_len-1:49*err_len]), .a(x), .error_0_in(err_0_in[50*err_len-1:49*err_len]), .error_1_in(err_1_in[50*err_len-1:49*err_len]));
error_adder #(.m(err_len-1)) err_add50(.error(err_add_in[51*err_len-1:50*err_len]), .a(x), .error_0_in(err_0_in[51*err_len-1:50*err_len]), .error_1_in(err_1_in[51*err_len-1:50*err_len]));
error_adder3 #(.m(err_len-1)) err_add51(.error(err_add_in[52*err_len-1:51*err_len]), .a(x), .error_0_in(err_0_in[52*err_len-1:51*err_len]), .error_1_in(err_1_in[52*err_len-1:51*err_len]));
error_adder2 #(.m(err_len-1)) err_add52(.error(err_add_in[53*err_len-1:52*err_len]), .a(x), .error_0_in(err_0_in[53*err_len-1:52*err_len]), .error_1_in(err_1_in[53*err_len-1:52*err_len]));
error_adder1 #(.m(err_len-1)) err_add53(.error(err_add_in[54*err_len-1:53*err_len]), .a(x), .error_0_in(err_0_in[54*err_len-1:53*err_len]), .error_1_in(err_1_in[54*err_len-1:53*err_len]));
error_adder #(.m(err_len-1)) err_add54(.error(err_add_in[55*err_len-1:54*err_len]), .a(x), .error_0_in(err_0_in[55*err_len-1:54*err_len]), .error_1_in(err_1_in[55*err_len-1:54*err_len]));
error_adder3 #(.m(err_len-1)) err_add55(.error(err_add_in[56*err_len-1:55*err_len]), .a(x), .error_0_in(err_0_in[56*err_len-1:55*err_len]), .error_1_in(err_1_in[56*err_len-1:55*err_len]));
error_adder1 #(.m(err_len-1)) err_add56(.error(err_add_in[57*err_len-1:56*err_len]), .a(x), .error_0_in(err_0_in[57*err_len-1:56*err_len]), .error_1_in(err_1_in[57*err_len-1:56*err_len]));
error_adder2 #(.m(err_len-1)) err_add57(.error(err_add_in[58*err_len-1:57*err_len]), .a(x), .error_0_in(err_0_in[58*err_len-1:57*err_len]), .error_1_in(err_1_in[58*err_len-1:57*err_len]));
error_adder3 #(.m(err_len-1)) err_add58(.error(err_add_in[59*err_len-1:58*err_len]), .a(x), .error_0_in(err_0_in[59*err_len-1:58*err_len]), .error_1_in(err_1_in[59*err_len-1:58*err_len]));
error_adder #(.m(err_len-1)) err_add59(.error(err_add_in[60*err_len-1:59*err_len]), .a(x), .error_0_in(err_0_in[60*err_len-1:59*err_len]), .error_1_in(err_1_in[60*err_len-1:59*err_len]));
error_adder1 #(.m(err_len-1)) err_add60(.error(err_add_in[61*err_len-1:60*err_len]), .a(x), .error_0_in(err_0_in[61*err_len-1:60*err_len]), .error_1_in(err_1_in[61*err_len-1:60*err_len]));
error_adder2 #(.m(err_len-1)) err_add61(.error(err_add_in[62*err_len-1:61*err_len]), .a(x), .error_0_in(err_0_in[62*err_len-1:61*err_len]), .error_1_in(err_1_in[62*err_len-1:61*err_len]));
error_adder3 #(.m(err_len-1)) err_add62(.error(err_add_in[63*err_len-1:62*err_len]), .a(x), .error_0_in(err_0_in[63*err_len-1:62*err_len]), .error_1_in(err_1_in[63*err_len-1:62*err_len]));
error_adder #(.m(err_len-1)) err_add63(.error(err_add_in[64*err_len-1:63*err_len]), .a(x), .error_0_in(err_0_in[64*err_len-1:63*err_len]), .error_1_in(err_1_in[64*err_len-1:63*err_len]));

endmodule
