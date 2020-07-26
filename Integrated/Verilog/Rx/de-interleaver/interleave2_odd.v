`timescale 1ns/1ns
module interleave2_odd(input [1:0]inter_mod, input [17:0]in, output reg [17:0]out);

always @ (*) begin
	if(inter_mod == 2'd3) begin // last to first at N_cbps = 288
		out[5:0] = {in[3], in[5], in[4], in[0], in[2], in[1]};
		out[11:6] = {in[9], in[11], in[10], in[6], in[8], in[7]};
		out[17:12] = {in[15], in[17], in[16], in[12], in[14], in[13]};
	end
	else if(inter_mod == 2'd2) begin // first to last at N_cbps = 288
		out[5:0] = {in[4], in[3], in[5], in[1], in[0], in[2]};
		out[11:6] = {in[10], in[9], in[11], in[7], in[6], in[8]};
		out[17:12] = {in[16], in[15], in[17], in[13], in[12], in[14]};
	end
	else if(inter_mod == 2'd1) begin // displacement two number at N_cbps = 192
		out[5:0] = {in[4], in[5], in[2], in[3], in[0], in[1]};
		out[11:6] = {in[10], in[11], in[8], in[9], in[6], in[7]};
		out[17:12] = {in[17], in[16], in[15], in[14], in[13], in[12]}; // save hardware 
	end
	else begin // without displacement at N_cbps = 48, 96
		out[5:0] = {in[5], in[4], in[3], in[2], in[1], in[0]};
		out[11:6] = {in[11], in[10], in[9], in[8], in[7], in[6]};
		out[17:12] = {in[17], in[16], in[15], in[14], in[13], in[12]};
	end
end

endmodule
