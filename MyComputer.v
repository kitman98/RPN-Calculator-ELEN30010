module MyComputer(input [9:0] SW, input [3:0] KEY,input CLOCK_50,
						output [9:0] LEDR, output [6:0] HEX0,output [6:0] HEX1,output [6:0] HEX2, output[6:0] HEX3,output[6:0] HEX4,output[6:0] HEX5);

		wire Dval;
		wire [7:0] IP;
		wire [7:0] Dout;
		wire reset_db;
		
		CPU cpu(CLOCK_50, ~KEY[2:0], SW[7:0], reset_db, ~KEY[3], SW[8],
					LEDR[9:6], Dout, Dval, LEDR[5:0], IP);		
					
		Debounce db(CLOCK_50, SW[9], reset_db);
		
		Disp2cNum dnum(Dout,Dval, HEX0, HEX1, HEX2, HEX3);
		
		DispHex dh(IP, HEX4, HEX5);
	
endmodule
