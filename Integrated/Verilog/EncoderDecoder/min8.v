`timescale 1ns/1ns
module min8 #(parameter m = 6)(input [m:0]in0, input [m:0]in1, input [m:0]in2, input [m:0]in3, input [m:0]in4, input [m:0]in5, input [m:0]in6, input [m:0]in7, output reg [2:0]min_index, output reg [m:0]in_min);

always @(*) begin
	if((in0 <= in1) && (in0 <= in2) && (in0 <= in3) && (in0 <= in4) && (in0 <= in5) && (in0 <= in6) && (in0 <= in7)) begin
		min_index = 3'd0;
		in_min = in0;
	end
	else if((in1 <= in0) && (in1 <= in2) && (in1 <= in3) && (in1 <= in4) && (in1 <= in5) && (in1 <= in6) && (in1 <= in7)) begin
		min_index = 3'd1;
		in_min = in1;
	end
	else if((in2 <= in0) && (in2 <= in1) && (in2 <= in3) && (in2 <= in4) && (in2 <= in5) && (in2 <= in6) && (in2 <= in7)) begin
		min_index = 3'd2;
		in_min = in2;
	end
	else if((in3 <= in0) && (in3 <= in1) && (in3 <= in2) && (in3 <= in4) && (in3 <= in5) && (in3 <= in6) && (in3 <= in7)) begin
		min_index = 3'd3;
		in_min = in3;
	end
	else if((in4 <= in0) && (in4 <= in1) && (in4 <= in2) && (in4 <= in3) && (in4 <= in5) && (in4 <= in6) && (in4 <= in7)) begin
		min_index = 3'd4;
		in_min = in4;
	end
	else if((in5 <= in0) && (in5 <= in1) && (in5 <= in2) && (in5 <= in3) && (in5 <= in4) && (in5 <= in6) && (in5 <= in7)) begin
		min_index = 3'd5;
		in_min = in5;
	end
	else if((in6 <= in0) && (in6 <= in1) && (in6 <= in2) && (in6 <= in3) && (in6 <= in4) && (in6 <= in5) && (in6 <= in7)) begin
		min_index = 3'd6;
		in_min = in6;
	end
	else begin
		min_index = 3'd7;
		in_min = in7;
	end
end

endmodule
