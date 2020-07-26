`timescale 1ns/1ns
module error_adder1 #(parameter m = 6)(input [m:0]error, input [1:0]a, output [m:0]error_0_in, output [m:0]error_1_in);
wire [m:0]error_plus;
wire [1:0] delta;

assign delta = ((a[1:0] == 2'd1) || (a[1:0] == 2'd2)) ? 2'd2 : 2'd1;
assign error_plus = (error[m:1] == {m{1'b1}}) ? {(m+1){1'b1}} : (error[m:0] + delta[1:0]);

assign error_0_in = (a[1:0] == 2'd1)? error : error_plus[m:0];
assign error_1_in = (a[1:0] == 2'd2)? error : error_plus[m:0];

endmodule
