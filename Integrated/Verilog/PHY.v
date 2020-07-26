`timescale 1ns/1ns
module PHY(input clk, input rst, input [3:0]rate, input tx_request, input in, input run, output out, output valid, output ready);
wire [51:0]channel;
wire [1:0]cr, mod;
wire sync;

TX my_tx(.clk(clk), .rst(rst), .in(in), .run(run), .rate(rate), .tx_request(tx_request), .out(channel), .valid(sync), .ready(ready), .cr(cr), .mod(mod));
RX my_rx(.clk(clk), .rst(rst), .in(channel), .run(sync), .cr(cr), .mod(mod), .out(out), .valid(valid));

endmodule
