`timescale 1ns/1ns
module counter1_12(input clk, input rst, input run, output reg [3:0]count, output count_8, output gozero);

assign gozero = (count == 4'd11)? 1'b1 : 1'b0;
assign count_8 = (count == 4'd8)? 1'b1 : 1'b0;

always @(posedge clk, negedge rst) begin
	if(~rst) begin
		count <= 4'd0;
	end
	else if((run == 1'b1) && (gozero == 1'b1)) begin
		count <= 4'd0;
	end
	else if((run == 1'b1) && (gozero == 1'b0)) begin
		count <= count + 1'b1;
	end
	else begin
		count <= count;
	end
end

endmodule
