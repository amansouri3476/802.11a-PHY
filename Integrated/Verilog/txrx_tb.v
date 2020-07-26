`timescale 1ns/1ns

module txrx_tb();
	
	// -----------------------------------------------------------------------------------------
	reg inputSerialBit;
	reg clk;
	reg reset;
	reg [3:0] Rate;
	reg request;
	reg run;
	reg goldenOutputBit;
	wire phy_output;
	wire valid_phy;
	wire ready_phy;
	reg [31:0] failuresCounter;
	reg [31:0] successCounter;
	reg finished;
	
	
	
	PHY Phy(.clk(clk), .rst(reset), .rate(Rate), .tx_request(request), .in(inputSerialBit), .run(run), .out(phy_output), .valid(valid_phy), .ready(ready_phy));
	
	
	initial begin
		clk = 0;
		forever begin
			#5 clk = ~clk;
		end
	end
	
	initial begin
		
		reset = 1'b1;
		request = 1'b0;
		failuresCounter = 32'd0;
		successCounter = 32'd0;
		finished = 1'b0;
		#1 reset = 1'b0;
		#6 reset = 1'b1;
		#1 Rate = 4'b1001; // VERY IMPORTANT: CHANGE THIS ACCORDING TO THE RATE YOU SELECT IN MATLAB. If you selected 6, set Rate = 4'b1101, if you selected 12, set Rate = 4'b0101,
								 // if you selected 12, set Rate = 4'b1001
		#1 request = 1'b1;
		#10 request = 1'b0;
	end
	

	integer f_phy_out;
	integer f_phy_in;
	integer f_phy_golden_outputs_m;
	
	
	
	initial begin
		f_phy_out = $fopen("phy_out.txt", "w");
		f_phy_in = $fopen("phy_in.txt", "r");
		f_phy_golden_outputs_m = $fopen("phy_golden_outputs_m.txt", "r");
	end
	
	integer i,j;
	
	integer limit = 32'd0;
	integer limitCounter = 32'd0;
	

	reg temp;
	
	initial begin
		while(!$feof(f_phy_in) || limitCounter <= limit) begin
			@(posedge clk) begin
				if(!$feof(f_phy_in)) begin
					limit <= limitCounter + 32'd200;
					limitCounter <= limitCounter + 32'd1;
				end
				else limitCounter <= limitCounter + 32'd1;
				
				$display($time);
				
				if(!$feof(f_phy_in)) begin
					i <= $fscanf(f_phy_in, "%b\n", inputSerialBit);
					run <= 1; // CRITICAL: input should arrive first, then run should be activated.
				end
				else run <= 0;
				
				if (valid_phy) begin
					j <= $fscanf(f_phy_golden_outputs_m, "%b\n", goldenOutputBit);
					$fwrite(f_phy_out, "%b\n", phy_output);
					$display("goldenOutputBit and phyOutput are: %b,%b\n", goldenOutputBit, temp);
					if(goldenOutputBit != temp)
						failuresCounter <= failuresCounter + 1;
					else
						successCounter <= successCounter + 1;
						
					temp <= phy_output;
				end
			end
		end
		// if end of file has arrived, then the finished bit should be asserted.
		finished <= 1'b1;
	end
	
	initial begin
	
		#100 wait(finished == 1'b1)
		$display("Verifying decoder outputs: Failures: %d\nSuccesses: %d", failuresCounter, successCounter);
		$stop;
	end
	

endmodule
