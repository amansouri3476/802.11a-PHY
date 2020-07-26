`timescale 1ns/1ns
module RX(input clk, input rst, input [51:0]in, input run, input [1:0]cr, input [1:0]mod, output out, output valid);
wire run1, run2, run3;
wire [17:0]x0_demapped, x1_demapped;
wire [1:0]x_deinterleaved;
wire x_decoded, ready;

demapper_pr rx_demapper(.x_in(in), .run(run), .mod(mod), .valid(run1), .x0_demapped(x0_demapped), .x1_demapped(x1_demapped));
deinterleaver rx_deinterleaver(.clk(clk), .rst(rst), .mod(mod), .x0(x0_demapped), .x1(x1_demapped), .run(run1), .x_deinterleaved(x_deinterleaved), .valid(run2));
decoder rx_decoder(.x(x_deinterleaved), .clk(clk), .rst(rst), .run(run2), .valid(run3), .x_decoded(x_decoded));
scrambler rx_descrambler(.x(x_decoded), .initialState(7'd127), .run(run3), .clk(clk), .reset(rst), .x_scrambled(out), .valid(valid), .rdy(ready));

endmodule
