`timescale 1ns/1ns

module encoderDecoder_tb();
	
	// -----------------------------------------------------------------------------------------
	reg inputSerialBit;
	reg [1:0] goldenEncoderOutputBit;
	wire [1:0] encoder_output;
	reg clk;
	reg reset;
	reg goldenOutputBit;
	wire decoder_output;
	wire valid_encoder;
	wire valid_decoder;
	reg [31:0] failuresCounter;
	reg [31:0] successCounter;
	reg [31:0] encoderfailuresCounter;
	reg [31:0] encodersuccessCounter;
	reg finished;
	
	reg run;
	encoder enc(.clk(clk), .rst(reset), .x(inputSerialBit), .run(run), .x_encoded(encoder_output), .valid(valid_encoder));
	decoder dec(.x(encoder_output), .clk(clk), .rst(reset), .run(valid_encoder), .valid(valid_decoder), .x_decoded(decoder_output));
	
	
	initial begin
		clk = 0;
		forever begin
			#5 clk = ~clk;
		end
	end
	
	integer f_encoder_out;
	integer f_encoder_golden_output;
	integer f_decoder_out;
	integer f_test_vectors;
	integer f_golden_outputs_m;
	
	initial begin
		// to test standard's example do the following, otherwise, the inputSerialBit should be read from the testbench file inputs
		// inputSerialBit = 0;
		
		reset = 1;
		failuresCounter = 32'd0;
		successCounter = 32'd0;
		encoderfailuresCounter = 32'd0;
		encodersuccessCounter = 32'd0;
		finished = 0;
		#1 reset = 0;
		#3 reset = 1;
	end
	
	initial begin
		f_encoder_out = $fopen("encoder_result.txt", "w");
		f_encoder_golden_output = $fopen("golden_encoder_outputs_m.txt", "r");
		f_decoder_out = $fopen("decoder_result.txt", "w");
		f_test_vectors = $fopen("encDec_test_vectors.txt", "r"); 
		f_golden_outputs_m = $fopen("golden_decoder_outputs_m.txt", "r");
	end
	
	integer i,j,k;
	
	integer limit = 32'd0;
	integer limitCounter = 32'd0;
	



	initial begin
		while(!$feof(f_test_vectors) || limitCounter <= limit) begin
			@(posedge clk) begin
				if(!$feof(f_test_vectors)) begin
					limit <= limitCounter + 32'd33;
					limitCounter <= limitCounter + 32'd1;
				end
				else limitCounter <= limitCounter + 32'd1;
				
				$display($time);
				
				if(!$feof(f_test_vectors)) begin
					k <= $fscanf(f_encoder_golden_output, "%b\n", goldenEncoderOutputBit);
					i <= $fscanf(f_test_vectors, "%b\n", inputSerialBit);
					run <= 1; // CRITICAL: input should arrive first, then run should be activated.
					#1 $fwrite(f_encoder_out, "%b\n", encoder_output); // Small delay is CRITICAL so that the combinational logic has prepared its encoded outputs.
					$display("encoder_output and encoder_golden_output are: %b,%b\n", encoder_output, goldenEncoderOutputBit);
					if(encoder_output != goldenEncoderOutputBit)
						encoderfailuresCounter <= encoderfailuresCounter + 1;
					else
						encodersuccessCounter <= encodersuccessCounter + 1;
				end
				else run <= 0;
				
				if (valid_decoder) begin
					j <= $fscanf(f_golden_outputs_m, "%b\n", goldenOutputBit);
					#1 $fwrite(f_decoder_out, "%b\n", decoder_output);
					$display("goldenOutputBit and decodedOutput are: %b,%b\n", goldenOutputBit, decoder_output);
					if(decoder_output != goldenOutputBit)
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
	
		#100 wait(finished == 1'b1)
		$display("Verifying encoder outputs: Failures: %d\nSuccesses: %d", encoderfailuresCounter, encodersuccessCounter);
		$display("Verifying decoder outputs: Failures: %d\nSuccesses: %d", failuresCounter, successCounter);
		$stop;
	end
	

endmodule
