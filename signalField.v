module signalField(input [7:0] RATE, input [11:0] LENGTH, output [23:0] SIGNAL);
	
	reg [3:0] RATE_BITS;
	wire RESERVED, Parity;
	always@(*) begin
		case (RATE)
			8'd6: RATE_BITS = {1'b1, 1'b1, 1'b0, 1'b1};
			8'd9: RATE_BITS = {1'b1, 1'b1, 1'b1, 1'b1};
			8'd12: RATE_BITS = {1'b0, 1'b1, 1'b0, 1'b1};
			8'd18: RATE_BITS = {1'b0, 1'b1, 1'b1, 1'b1};
			8'd24: RATE_BITS = {1'b1, 1'b0, 1'b0, 1'b1};
			8'd36: RATE_BITS = {1'b1, 1'b0, 1'b1, 1'b1};
			8'd48: RATE_BITS = {1'b0, 1'b0, 1'b0, 1'b1};
			8'd54: RATE_BITS = {1'b0, 1'b0, 1'b1, 1'b1};
			default: RATE_BITS = {1'b1, 1'b0, 1'b1, 1'b1}; // 36 MB/s
		endcase
	end
	
	assign RESERVED = 1'b0;
	assign Parity = ^{{RATE_BITS},{RESERVED},{LENGTH}};
	assign SIGNAL = {{RATE_BITS},{RESERVED},{LENGTH[0],LENGTH[1],LENGTH[2],
		LENGTH[3],LENGTH[4],LENGTH[5],LENGTH[6],LENGTH[7],LENGTH[8],LENGTH[9],
		LENGTH[10],LENGTH[11]},{Parity},{6'd0}};
	
endmodule
