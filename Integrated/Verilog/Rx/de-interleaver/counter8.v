`timescale 1ns/1ns
module counter8(input clk, input rst, input run, input [1:0]mod, output gozero);
reg [7:0]count;
wire [7:0]count_end;

assign count_end = (mod == 2'd0) ? 8'd15 : (mod == 2'd1) ? 8'd39 : (mod == 2'd2) ? 8'd87 : 8'd135;
assign gozero = (count == count_end)? 1'b1 : 1'b0;

always @(posedge clk, negedge rst) begin
	if(~rst) begin
		count <= 8'd0;
	end
	else if((run == 1'b1) && (gozero == 1'b1)) begin
		count <= 8'd0;
	end
	else if((run == 1'b1) && (gozero == 1'b0)) begin
		count <= count + 1'b1;
	end
	else begin
		count <= count;
	end
end

endmodule
