`timescale 1ns/1ns

// Sample test bench for Calculator
//
// Lots of room for improvement!
//
// Only looks at CPU pins
// Does not test debounce, Disp2cNum etc
//
// Does not check the answers produced by the calculator are correct.

module TestCalc;

	reg clk = 0;
	initial forever
		#10 clk = !clk;		// 50 MHz

	reg [3:0] pb = 0;
	reg reset = 1;
	reg turbo = 1;
	reg [7:0] Din;

	wire [7:0] IP;
	wire signed [7:0] Dout;
	wire Dval;
	wire [9:0] leds;

	CPU DUT(
		.Din(Din),
		.Sample(pb[3]),
		.Btns(pb[2:0]),
		.Clock(clk),
		.Reset(reset),
		.Turbo(turbo),
		.Dout(Dout),
		.Dval(Dval),
		.GPO(leds[5:0]),
		.Debug(leds[9:6]),
		.IP(IP));


	// A "task" is like a function
	// The following tasks are used to simplify
	// the writing of the test signals

	task Delay;
		input integer duration;	// Measured in clock cycles
		repeat (duration) @(posedge clk) ;
	endtask

	task PressReleaseButton;
		input integer i;
		begin
			pb[i] = 1;
			#25
			pb[i] = 0;
		end
	endtask

	// The delay in the tasks below are set to 50.
	// This number should be longer than the total number of
	// instructions in any operation of your calculator.
	//
	// fork ... join
	// This is used to run things in parallel.
	// It means the delay will be exactly 50, independent
	// of how long PressReleaseButton takes.

	task Push;
		input [7:0] num;
		begin
			$display("\n\nPush %d", num);
			Din = num;
			fork
				PressReleaseButton(3);
				Delay(50);
			join
		end
	endtask

	task Pop;
		begin
			$display("\n\nPop");
			fork
				PressReleaseButton(2);
				Delay(50);
			join
		end
	endtask

	task Add;
		begin
			$display("\n\nAdd");
			fork
				PressReleaseButton(1);
				Delay(50);
			join
		end
	endtask

	task Mult;
		begin
			$display("\n\nMult");
			fork
				PressReleaseButton(0);
				Delay(50);
			join
		end
	endtask

	task Reset;
		begin
			$display("\n\nResetting...");
			begin
				reset = 1;
				Delay(1);
				reset = 0;
				Delay(1);
			end
			$display("... Reset Complete");
		end
	endtask


	// TEST SIGNALS

	initial begin
		// You can choose instead to print out IP in hexadecimal if
		// that is how you wrote the addresses in your ROM

		$monitor("IP=%d\tLEDS=%b_%b_%b\tDval=%b\tDout=%d\tTime=%d ns",
			IP, leds[9:6], leds[5:4], leds[3:0], Dval, Dout, $time);
		Reset;

		$display("\n\nWait for calculator to run its initialisation code");
		Delay(50);

		Push(2);
		Push(5);
		Add;

		Push(-3);
		Mult;

		Pop;
		Pop;

		Push(1);
		Push(2);
		Push(3);
		Push(4);
		Push(5);
		Push(6);
		Mult;
		Mult;
		Mult;
		Mult;
		Mult;
		$stop;
	end
endmodule
