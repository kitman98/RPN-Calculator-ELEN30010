`timescale 1ns/1ps

module test_03;

	reg [7:0] neg;

	wire [7:0] converted, w0,w1,w2;
	
	convertSigned convert(neg, converted[7], converted[6:0]);
	
	wire [6:0] h0, h1, h2;
	
	DispDec hex0(converted[6:0], converted[7],1, h0, w0[6:0], w0[7]);
	DispDec hex1(w0[6:0], w0[7],0, h1, w1[6:0], w1[7]);
	DispDec hex2(w1[6:0], w1[7],0, h1, w2[6:0], w2[7]);
	
	initial begin
	neg = 8'b1111_0101;
	#10 $stop;
	end

endmodule