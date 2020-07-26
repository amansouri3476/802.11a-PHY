`timescale 1ns/1ns
module min_error #(parameter m = 6)(input [m:0]error_0_out, input [m:0]error_1_out, output reg [m:0]error_min, output reg out_bit);

always @(*) begin
	if(error_1_out < error_0_out) begin
		out_bit = 1'b1;
		error_min = error_1_out;
	end
	else begin
		out_bit = 1'b0;
		error_min = error_0_out;
	end
end

endmodule
