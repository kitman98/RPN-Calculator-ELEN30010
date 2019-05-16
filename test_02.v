`timescale 1ns/1ps

module test_02;

	reg clk, in;
	wire out;

	initial clk = 0;
	initial forever #10 clk = !clk;
	
	Debounce db(clk, in, out);
	
	initial begin
		#0 in = 0;
		#10 in = 1;
		#10 in = 0;
		#10 in = 1;
		#25000000 in = 0;
		
		#10 $stop;
		
	end
endmodule