`timescale 1ns/1ns
module demapper(input [7:0]x, input [1:0]mod, output reg [5:0]x_demapped);

always @ (*) begin
	if(mod == 2'd0) begin // BPSK
		x_demapped = (x[7] == 1'b0) ? 6'd1 : 6'd0;
	end
	else if(mod == 2'd1) begin // QPSK
		x_demapped[5:2] = 4'd0;
		x_demapped[1] = (x[3] == 1'b0) ? 1'b1 : 1'b0;
		x_demapped[0] = (x[7] == 1'b0) ? 1'b1 : 1'b0;
	end
	else if(mod == 2'd2) begin // 16-QAM
		x_demapped[1:0] = (x[7:4] == 4'h1) ? 2'b11:(x[7:4] == 4'h9) ? 2'b10:(x[7:4] == 4'h3) ? 2'b01: 2'b00;
		x_demapped[3:2] = (x[3:0] == 4'h1) ? 2'b11:(x[3:0] == 4'h9) ? 2'b10:(x[3:0] == 4'h3) ? 2'b01: 2'b00;
		x_demapped[5:4] = 2'd0;
	end
	else begin // 64-QAM
		x_demapped[2:0] = (x[7:4] == 4'h1) ? 3'b011:(x[7:4] == 4'h3) ? 3'b111:(x[7:4] == 4'h5) ? 3'b101:(x[7:4] == 4'h7) ? 3'b001:(x[7:4] == 4'h9) ? 3'b010:(x[7:4] == 4'hb) ? 3'b110:(x[7:4] == 4'hd) ? 3'b100: 3'b000;
		x_demapped[5:3] = (x[3:0] == 4'h1) ? 3'b011:(x[3:0] == 4'h3) ? 3'b111:(x[3:0] == 4'h5) ? 3'b101:(x[3:0] == 4'h7) ? 3'b001:(x[3:0] == 4'h9) ? 3'b010:(x[3:0] == 4'hb) ? 3'b110:(x[3:0] == 4'hd) ? 3'b100: 3'b000;
	end
end

endmodule
