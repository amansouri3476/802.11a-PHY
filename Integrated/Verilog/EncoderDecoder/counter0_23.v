`timescale 1ns/1ns
module counter0_23(input clk, input rst, input run, output reg [4:0]count, output zero, output gozero);

assign gozero = (count == 5'd23)? 1'b1 : 1'b0;
assign zero = (count == 5'd0)? 1'b1 : 1'b0;

always @(posedge clk, negedge rst) begin
	if(~rst) begin
		count <= 5'd0;
	end
	else if((run == 1'b1) && (gozero == 1'b1)) begin
		count <= 5'd0;
	end
	else if((run == 1'b1) && (gozero == 1'b0)) begin
		count <= count + 1'b1;
	end
	else begin
		count <= count;
	end
end

endmodule
