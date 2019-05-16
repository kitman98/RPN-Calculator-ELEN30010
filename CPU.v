`include "CPU.vh"

// CPU Module

module CPU(
	input clk, input [2:0] btns, input [7:0] Din, input reset, sample, turbo,
	output [3:0] debug, output [7:0] Dout = 0, output Dval,output [5:0] GPO = 0,output reg[7:0] IP = 0);
	
	// 250ms clock
	localparam millisecond = 50_000;
	localparam period = 250*millisecond;
	localparam size = $clog2(period);
	
	// synchronised reset switch
	wire reset_sync;
	
	Synchroniser sync_r(clk, reset, reset_sync);
	
	// synchronised turbo switch
	wire turbo_sync;
	
	Synchroniser sync_turbo(clk, turbo, turbo_sync);
	
	// synchronised input Din
	wire [7:0] din_safe;
	
	Synchroniser din0(clk, Din[0], din_safe[0]);
	Synchroniser din1(clk, Din[1], din_safe[1]);
	Synchroniser din2(clk, Din[2], din_safe[2]);
	Synchroniser din3(clk, Din[3], din_safe[3]);
	Synchroniser din4(clk, Din[4], din_safe[4]);
	Synchroniser din5(clk, Din[5], din_safe[5]);
	Synchroniser din6(clk, Din[6], din_safe[6]);
	Synchroniser din7(clk, Din[7], din_safe[7]);
	
	// synchronised input push buttons
	wire [3:0] pb_safe;
	
	Synchroniser sync_sample(clk, sample, pb_safe[3]);
	Synchroniser sync_btns0(clk, btns[0], pb_safe[0]);
	Synchroniser sync_btns1(clk, btns[1], pb_safe[1]);
	Synchroniser sync_btns2(clk, btns[2], pb_safe[2]);
	
	// edge detector
	genvar i;
	wire[3:0] pb_activated;
	generate
		for(i = 0; i <= 3; i = i + 1) begin: pb
			DetectFallingEdge dfe(clk, pb_safe[i], pb_activated[i]);
		end
	endgenerate
	
	// 250 ms counter
	reg [size-1:0] count = 0;
	
	always@(posedge clk) begin
		count <= (count == period)? 0: count + 1'b1;
	end
	
	wire go = !reset_sync && ((count == 0)||turbo_sync);
	
	// Use these to Write to the Flags and Din Registers
	`define RFLAG Reg[31]
	`define RDINP Reg[28]
	
	// Instruction Cycle
	wire [3:0] cmd_grp = instruction[34:31];
	wire [2:0] cmd = instruction[30:28];
	wire [1:0] arg1_typ = instruction[27:26];
	wire [7:0] arg1 = instruction[25:18];
	wire [1:0] arg2_typ = instruction[17:16];
	wire [7:0] arg2 = instruction[15:8];
	wire [7:0] addr = instruction[7:0];
	
	reg [7:0] cnum, cloc, word;
	reg signed [14:0] s_word;
	reg cond;
	integer j;
	
	always @(posedge clk) begin
		if (go) begin
			IP <= IP + 8'b1;// Default action is to increment IP
			case (cmd_grp)
			
				// MOV command group
				`MOV:begin
					cnum = get_number(arg1_typ, arg1);
					case(cmd)
						`SHL: begin
							`RFLAG[`SHFT] <= cnum[7];
							cnum = {cnum[6:0], 1'b0};
						end
						
						`SHR: begin
							`RFLAG[`SHFT] <= cnum[0];
							cnum = {1'b0, cnum[7:1]};
							
						end
					endcase
					Reg[get_location(arg2_typ, arg2)]<=cnum;
				
				end
				
				// JMP command group
				`JMP:begin
					case(cmd)
						`UNC: cond = 1;
						`EQ: cond = (get_number(arg1_typ,arg1) == get_number(arg2_typ,arg2));
						`ULT: cond = (get_number(arg1_typ,arg1) < get_number(arg2_typ,arg2));
						`SLT: cond = ($signed(get_number(arg1_typ, arg1)) < $signed(get_number(arg2_typ, arg2)));
						`ULE: cond = (get_number(arg1_typ, arg1) <= get_number(arg2_typ, arg2));
						`SLE: cond = ($signed(get_number(arg1_typ, arg1)) <= $signed(get_number(arg2_typ, arg2)));
						default: cond = 0;
					endcase
					if(cond) IP <= addr;
				end
				
				// ACC command group
				`ACC: begin
					cnum = get_number(arg2_typ, arg2);
					cloc = get_location(arg1_typ, arg1);
					case(cmd)
						`UAD: word = Reg[cloc] + cnum;
						`SAD: s_word = $signed(Reg[cloc]) +$signed(cnum);
						`UMT: word = Reg[cloc] * cnum;
						`SMT: s_word = $signed(Reg[cloc])*$signed(cnum);
						`AND: cnum = Reg[cloc] & cnum;
						`OR: cnum = Reg[cloc] | cnum;
						`XOR: cnum = Reg[cloc] ^ cnum;
					endcase
					if(cmd[2] == 0)
						if(cmd[0] == 0) begin // unsigned addition or multiplication
							cnum = word[7:0];
							`RFLAG[`OFLW] <= (word > 255);
						end
						else begin // signed addition
							cnum = s_word[7:0];
							`RFLAG[`OFLW] <= (s_word > 127 || s_word < -128);
						end
					Reg[cloc] <= cnum;
				end
				
				// Atomic test and clear
				// if `RFLAG[cmd] is 1, IP is set to addr and `RFLAG[cmd] becomes 0
				`ATC: begin
					if(`RFLAG[cmd]) IP <= addr;
					`RFLAG[cmd] <= 0;
				end
				
			endcase
		end
		
		
		if(reset_sync) begin
			IP <= 8'd0;
			`RFLAG <= 0;
		end
		else begin
			for(j=0; j<=3; j=j+1)
				if(pb_activated[j]) `RFLAG[j] <= 1;
				
			if(pb_activated[3]) `RDINP <= din_safe;
		end
	end
	
	// Program Memory
	wire [34:0] instruction;
	AsyncROM Pmem(IP, instruction);
	
	// Registers
	reg [7:0] Reg [0:31];
	
	// Use these to Read the Special Registers
	wire [7:0] Rgout = Reg[29];
	wire [7:0] Rdout = Reg[30];
	wire [7:0] Rflag = Reg[31];
	

	
	// Connect certain registers to the external world
	assign Dout = Rdout;
	assign GPO = Rgout[5:0];
	
	// TO DO: Change Later
	assign Dval = Rgout[`DVAL];
	
	assign debug[3] = Rflag[`SHFT];
	assign debug[2] = Rflag[`OFLW];
	assign debug[1] = Rflag[`SMPL];
	assign debug[0] = go;
	
	//functions
	
	function [7:0] get_number;
		input [1:0] arg_type;
		input [7:0] arg;
		
		begin
			case (arg_type)
				`REG: get_number = Reg[arg[4:0]];
				`IND: get_number = Reg[ Reg[arg[4:0]][4:0] ];
				default: get_number = arg;
			endcase
		end
		
	endfunction
		
	
	function [5:0] get_location;
		input [1:0] arg_type;
		input [7:0] arg;
		begin
			case (arg_type)
				`REG: get_location = arg[4:0];
				`IND: get_location = Reg[arg[4:0]][4:0];
				default: get_location = 0;
			endcase
		end
	endfunction

	
	
endmodule

