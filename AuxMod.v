// debounces switch
module Debounce(input clk, in, output reg out = 0);
	
	wire in_sync;
	
	Synchroniser sync(clk, in, in_sync);
	
	// 50 000 clock cycles per millisecond
	localparam millisecond = 50_000;
	localparam period = millisecond*30;
	// number of bits required to represent period
	localparam size = $clog2(period);
	
	reg [size-1:0] count = 0, nextcount;
	
	reg nextout;
	
	always@(posedge clk) begin
		{count, out} = {nextcount, nextout};
	end
	
	always@(*) begin
		nextcount = (in_sync == out)?1'b0:count + 1'b1;
		nextout = out;
		
		if (nextcount >= period) begin
			nextcount = 0;
			nextout = in_sync;
		end
	end
	
endmodule

// displays 8 bit 2's complement numbers on four 7 segment displays
module Disp2cNum(input [7:0] bin, input enable, output [6:0] H0,output [6:0] H1,output [6:0] H2,output [6:0] H3);

	wire[7:0] w0,w1,w2,w3, converted;
	
	convertSigned convert(bin, converted[7], converted[6:0]);
	
	
	DispDec hex0(converted[6:0], converted[7],enable, H0, w0[6:0], w0[7]);
	DispDec hex1(w0[6:0], w0[7],0, H1, w1[6:0], w1[7]);
	DispDec hex2(w1[6:0], w1[7],0, H2, w2[6:0], w2[7]);
	DispDec hex3(w2[6:0], w2[7],0, H3, w3[6:0], w3[7]);

endmodule

// returns sseg display in decimals and returns next digit to be displayed

module DispDec(input [6:0] bin, input neg, enable, output [6:0] disp, output [6:0] next_bin, output next_neg);
		
		SSeg hex(bin%10, neg&&!bin,enable||bin||neg, disp);
		assign next_bin = bin/10;
		assign next_neg = neg&(|bin);
	
endmodule

// converts the number part of a signed binary number to an unsigned binary number
module convertSigned(input [7:0] signedBin, output neg, output [6:0] unsignedBin);

	assign neg = signedBin[7];
	assign unsignedBin = (signedBin[7] == 1)? ((~signedBin[6:0]) + 1):signedBin[6:0];
	
endmodule

// displays an 8 bit number in hexadecimal on two 7 segment displays
module DispHex(input [7:0] bin, output [6:0] H0,output [6:0] H1);
	
	SSeg ss0(bin[3:0], 0, 1, H0);
	SSeg ss1(bin[7:4], 0, 1, H1);
	
endmodule

// double flip flop synchroniser
module Synchroniser(input clk, in, output reg in_sync = 0);
	reg ff1 = 0;
	
	always@(posedge clk) begin
		ff1 <= in;
		in_sync <= ff1;
	end
	
endmodule

// Display a Hexadecimal Digit, a Negative Sign, or a Blank, on a 7-segment Display
module SSeg(input [3:0] bin, input neg, input enable, output reg [6:0] segs);
	always @(*)
		if (enable) begin
			if (neg) segs = 7'b011_1111;
			else begin
				case (bin)
					0: segs = 7'b100_0000;
					1: segs = 7'b111_1001;
					2: segs = 7'b010_0100;
					3: segs = 7'b011_0000;
					4: segs = 7'b001_1001;
					5: segs = 7'b001_0010;
					6: segs = 7'b000_0010;
					7: segs = 7'b111_1000;
					8: segs = 7'b000_0000;
					9: segs = 7'b001_1000;
					10: segs = 7'b000_1000;
					11: segs = 7'b000_0011;
					12: segs = 7'b100_0110;
					13: segs = 7'b010_0001;
					14: segs = 7'b000_0110;
					15: segs = 7'b000_1110;
				endcase
			end
		end
		else segs = 7'b111_1111;
endmodule

// Falling edge detector
module DetectFallingEdge(input clk, btn_sync, output out);
	
	reg prev = 0;
	
	always@(posedge clk) begin
		prev <= btn_sync;
	end
	
	assign out = !btn_sync&prev;

endmodule
