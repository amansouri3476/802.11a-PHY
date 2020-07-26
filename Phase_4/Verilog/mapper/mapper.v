`timescale 1ns/1ns
module mapper(input [5:0]x, input [1:0]mod, output reg [7:0]x_mapped);

always @ (*) begin
	if(mod == 2'd0) begin // BPSK
		x_mapped = (x[0] == 1'b1) ? 8'h10 : 8'h90;
	end
	else if(mod == 2'd1) begin // QPSK
		x_mapped[7:4] = (x[0] == 1'b1) ? 4'h1 : 4'h9;
		x_mapped[3:0] = (x[1] == 1'b1) ? 4'h1 : 4'h9;
	end
	else if(mod == 2'd2) begin // 16-QAM
		x_mapped[7:4] = (x[1:0] == 2'd0) ? 4'hb:(x[1:0] == 2'd1) ? 4'h3:(x[1:0] == 2'd2) ? 4'h9: 4'h1;
		x_mapped[3:0] = (x[3:2] == 2'd0) ? 4'hb:(x[3:2] == 2'd1) ? 4'h3:(x[3:2] == 2'd2) ? 4'h9: 4'h1;
	end
	else begin // 64-QAM
		x_mapped[7:4] = (x[2:0] == 3'd0) ? 4'hf:(x[2:0] == 3'd1) ? 4'h7:(x[2:0] == 3'd2) ? 4'h9:(x[2:0] == 3'd3) ? 4'h1:(x[2:0] == 3'd4) ? 4'hd:(x[2:0] == 3'd5) ? 4'h5:(x[2:0] == 3'd6) ? 4'hb:4'h3;
		x_mapped[3:0] = (x[5:3] == 3'd0) ? 4'hf:(x[5:3] == 3'd1) ? 4'h7:(x[5:3] == 3'd2) ? 4'h9:(x[5:3] == 3'd3) ? 4'h1:(x[5:3] == 3'd4) ? 4'hd:(x[5:3] == 3'd5) ? 4'h5:(x[5:3] == 3'd6) ? 4'hb:4'h3;
	end
end

endmodule
