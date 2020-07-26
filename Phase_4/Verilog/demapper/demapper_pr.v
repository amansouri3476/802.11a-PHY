`timescale 1ns/1ns
module demapper_pr(input [51:0]x_in, input run, input [1:0]mod, output valid, output reg [17:0]x0_demapped, output reg [17:0]x1_demapped); // demapping an pilot removing
wire [5:0]subc0, subc1, subc2, subc3, subc4, subc5;

assign valid = run;

always @ (*) begin
	if(mod == 2'd0) begin // BPSK
		x0_demapped = {15'd0, subc2[0], subc1[0], subc0[0]};
		x1_demapped = {15'd0, subc5[0], subc4[0], subc3[0]};
	end
	else if(mod == 2'd1) begin // QPSK
		x0_demapped = {12'd0, subc2[1:0], subc1[1:0], subc0[1:0]};
		x1_demapped = {12'd0, subc5[1:0], subc4[1:0], subc3[1:0]};
	end
	else if(mod == 2'd2) begin // 16-QAM
		x0_demapped = {6'd0, subc2[3:0], subc1[3:0], subc0[3:0]};
		x1_demapped = {6'd0, subc5[3:0], subc4[3:0], subc3[3:0]};
	end
	else begin // 64-QAM
		x0_demapped = {subc2[5:0], subc1[5:0], subc0[5:0]};
		x1_demapped = {subc5[5:0], subc4[5:0], subc3[5:0]};
	end
end

demapper demap0(.x(x_in[7:0]), .mod(mod), .x_demapped(subc0));
demapper demap1(.x(x_in[15:8]), .mod(mod), .x_demapped(subc1));
demapper demap2(.x(x_in[23:16]), .mod(mod), .x_demapped(subc2));
demapper demap3(.x(x_in[31:24]), .mod(mod), .x_demapped(subc3));
demapper demap4(.x(x_in[39:32]), .mod(mod), .x_demapped(subc4));
demapper demap5(.x(x_in[47:40]), .mod(mod), .x_demapped(subc5));

endmodule
