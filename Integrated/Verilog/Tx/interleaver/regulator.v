`timescale 1ns/1ns
module regulator(input [17:0]x, input [1:0]mod, output [17:0]x_regulated);

assign x_regulated = (mod == 2'd0) ? {x[17:3],x[0],x[1],x[2]} : (mod == 2'd1) ? {x[17:6],x[0],x[1],x[2],x[3],x[4],x[5]} : (mod == 2'd2)? {x[17:12],x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9],x[10],x[11]} : {x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9],x[10],x[11],x[12],x[13],x[14],x[15],x[16],x[17]};

endmodule
