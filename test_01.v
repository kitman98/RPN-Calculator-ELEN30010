`timescale 1ns/1ps

module test_01;

	//MyComputer(input [9:0] SW, input [3:0] KEY,input CLOCK_50,
	//					output [9:0] LEDR, output [6:0] HEX0,output [6:0] HEX1,output [6:0] HEX2, output[6:0] HEX3,output[6:0] HEX4,output[6:0] HEX5);

	
	reg [9:0] sw;
	reg [3:0] key;
	reg clk;
	
	wire [9:0] ledr;
	wire [6:0] hex0,hex1, hex2, hex3, hex4, hex5;
	
	MyComputer test_CPU(sw, key, clk, ledr, hex0, hex1, hex2, hex3, hex4, hex5);
						
	
	initial clk = 0;
	
	initial forever #10 clk = !clk;
	
	initial begin
		sw[9] = 0;
		#10 sw[9] = 1;
		#30000000 sw[9] = 0;
		#30000000 sw[9] = 1;
		#30000000 $stop;
	end
endmodule