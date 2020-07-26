`timescale 1ns/1ns

module scrambler_tb();
	
	// -----------------------------------------------------------------------------------------
	reg inputSerialBit;
	// reg goldenOutputBitNext;
	reg goldenOutputBit;
	reg goldenScramblerOutputBit;
	reg [6:0] initState;
	reg clk;
	reg reset;
	wire scrambler_output;
	wire descrambler_output;
	// wire [6:0] scrambled_seq;
	// wire [6:0] descrambled_seq;
	wire valid_scrambler;
	wire valid_descrambler;
	reg [31:0] failuresCounter;
	reg [31:0] successCounter;
	reg [31:0] scramblerfailuresCounter;
	reg [31:0] scramblersuccessCounter;
	reg finished;
	
	scrambler SCRAMBLER(.x(inputSerialBit),
	.initialState(initState), .clk(clk), .reset(reset), .x_scrambled(scrambler_output), .MODE(1'b1)
	// , .scrambled_seq(scrambled_seq)
	, .valid(valid_scrambler));
	
	scrambler DESCRAMBLER(.x(scrambler_output),
	.initialState(initState), .clk(clk), .reset(reset), .x_scrambled(descrambler_output), .MODE(1'b0)
	// , .scrambled_seq(descrambled_seq)
	, .valid(valid_descrambler));
	
	initial begin
		clk = 0;
		forever begin
			#5 clk = ~clk;
		end
	end
	
	integer f_scrambler_out;
	integer f_scrambler_golden_output;
	integer f_descrambler_out;
	integer f_test_vectors;
	integer f_golden_outputs_m;
	
	initial begin
		// to test standard's example do the following, otherwise, the inputSerialBit should be read from the testbench file inputs
		// inputSerialBit = 0;
		
		// VERY IMPORTANT: If you want to verify the output of scrambler, you need to read the scramInit from Matlab Workspace and replace the seed below with that because in each
		// run, a random seed is used and if you replace text files here, without replacing the scramInit, you won't see bit matching for scrambler outputs. But it is clear that
		// bit matching is nevertheless not affected for the descrambler output since whatever seed is used here, will be the same for both scrambler and descrambler.
		initState = 7'b1000011; //7'd127; // In case you want to use standard's example message change this to 7'b1011101
		
		
		reset = 1;
		failuresCounter = 32'd0;
		successCounter = 32'd0;
		scramblerfailuresCounter = 32'd0;
		scramblersuccessCounter = 32'd0;
		finished = 0;
		#1 reset = 0;
		#3 reset = 1;
	end
	initial begin
		f_scrambler_out = $fopen("scrambler_result.txt", "w");
		f_scrambler_golden_output = $fopen("golden_scrambler_outputs_m.txt", "r"); // in case you want to use standard's example message change this to "sm_golden_scrambler_outputs_m.txt"
		f_descrambler_out = $fopen("descrambler_result.txt", "w");
		f_test_vectors = $fopen("test_vectors.txt", "r"); // in case you want to use standard's example message change this to "sampleMessage.txt"
		f_golden_outputs_m = $fopen("golden_outputs_m.txt", "r"); // in case you want to use standard's example message change this to "sm_golden_outputs_m.txt"
	end
	
	integer i,j,k;
	
	initial begin
		while(!$feof(f_test_vectors)) begin
			@(posedge clk) begin	
				$display($time);
				i <= $fscanf(f_test_vectors, "%b\n", inputSerialBit);
				
				if (valid_scrambler) begin
					k <= $fscanf(f_scrambler_golden_output, "%b\n", goldenScramblerOutputBit);
					$fwrite(f_scrambler_out, "%b\n", scrambler_output);
					$display("scrambler_output and scrambler_golden_output are: %b,%b\n", scrambler_output, goldenScramblerOutputBit);
					if(scrambler_output != goldenScramblerOutputBit)
						scramblerfailuresCounter <= scramblerfailuresCounter + 1;
					else
						scramblersuccessCounter <= scramblersuccessCounter + 1;
				end
				if (valid_descrambler) begin
					j <= $fscanf(f_golden_outputs_m, "%b\n", goldenOutputBit);
					// goldenOutputBit <= goldenOutputBitNext;
					$fwrite(f_descrambler_out, "%b\n", descrambler_output);
					$display("goldenOutputBit and descrambledOutput are: %b,%b\n", goldenOutputBit, descrambler_output);
					if(descrambler_output != goldenOutputBit)
						failuresCounter <= failuresCounter + 1;
					else
						successCounter <= successCounter + 1;
				end
			end
		end
		// if end of file has arrived, then the finished bit should be asserted.
		finished <= 1'b1;
	end
	
	initial begin
		// $monitor("The scrambler_result is %b, scrambled seq is %b", scrambler_output
		// , scrambled_seq
		// , $time);
		#100 wait(finished == 1'b1)
		$display("Verifying scrambler outputs: Failures: %d\nSuccesses: %d", scramblerfailuresCounter, scramblersuccessCounter);
		$display("Verifying descrambler outputs: Failures: %d\nSuccesses: %d", failuresCounter, successCounter);
		$stop;
	end
	

endmodule