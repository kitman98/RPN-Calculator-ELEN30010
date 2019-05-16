`include "CPU.vh"

// Asynchronous ROM (Program Memory)

module AsyncROM(input [7:0] addr, output reg [34:0] data);
	always @(addr)
		case (addr)
		/*
			0: data = {`MOV, `PUR, `NUM, 8'd 1, `REG, `DOUT, `N8};
			1: data = {`MOV, `PUR, `NUM, 8'd 3, `REG, `DOUT, `N8};
			2: data = {`MOV, `PUR, `NUM, 8'd 5, `REG, `DOUT, `N8};
			3: data = {`MOV, `PUR, `NUM, 8'd 7, `REG, `DOUT, `N8};
			4: data = {`MOV, `PUR, `NUM, 8'd 9, `REG, `DOUT, `N8};
			5: data = {`MOV, `PUR, `NUM, 8'd 11, `REG, `DOUT, `N8};
			6: data = {`MOV, `PUR, `NUM, 8'd 13, `REG, `DOUT, `N8};
			7: data = {`MOV, `PUR, `NUM, 8'd 15, `REG, `DOUT, `N8};
			8: data = {`MOV, `PUR, `NUM, 8'd 17, `REG, `DOUT, `N8};
			9: data = {`MOV, `PUR, `NUM, 8'd 19, `REG, `DOUT, `N8};
			14: data = {`MOV, `PUR, `NUM, 8'b11110101, `REG, `DOUT, `N8};
			
			// lights LEDs up
			10: data = {`MOV, `PUR, `NUM, 8'b00111111, `REG, `GOUT, `N8};
			11: data = {`MOV, `PUR, `NUM, 8'b00101010, `REG, `GOUT, `N8};
			12: data = {`MOV, `PUR, `NUM, 8'b00010101, `REG, `GOUT, `N8};
			
			// IP jump to 0
			15: data = {`JMP, `UNC, `N10, `N10, 8'd0};
			*/
			
			// other stuff
			
			/*
			0: data = {`MOV, `PUR, `NUM, 8'd 0, `REG, `DOUT, `N8};
			4: data = {`ACC, `SAD, `REG, `DOUT, `NUM, 8'd 15, `N8};
			8: data = {`JMP, `UNC, `N10, `N10, 8'd 4};
			default: data = 35'b0; // NOP
			*/
			/*
			0: data = {`MOV, `PUR, `NUM, 8'd1, `REG, `DOUT, `N8};
			4: data = {`ACC, `SMT, `REG, `DOUT, `NUM, -8'd2, `N8};
			7: data = {`JMP, `SLT, `REG, `DOUT, `NUM, 8'd64, 8'd4};
			10: data = {`MOV, `PUR, `NUM, 8'd100, `REG, `DOUT, `N8};
			13: data = {`ACC, `SAD, `REG, `DOUT, `NUM, -8'd7, `N8};
			16: data = {`JMP, `SLE, `NUM, 8'd0, `REG, `DOUT, 8'd13};
			20: data = {`JMP, `UNC, `N10, `N10, `N8};
			*/
			/*
			0: data = set(`DOUT, 1);
			4: data = acc(`SMT, `DOUT, -2);
			8: data = atc(`OFLW, 16);
			12: data = jmp(4);
			16: data = set(`DOUT, 250);
			20: data = acc(`UAD, `DOUT, 1);
			24: data = atc(`OFLW, 8);
			28: data = jmp(20);
			default: data = 35'b0; // NOP
			1, 5, 9, 13, 17, 21, 25: data = mov(`FLAG, `GOUT);
			*/
			/*
			0:data = set(`FLAG,128);
			1:data = mov(`FLAG, `GOUT);
			2: data = mov(`DINP, `DOUT);
			3: data = jmp(1);
			default: data = 35'b0;
			
			*/
			
						// reset and initialisation
			0	:	data = set(`DOUT, 0);		
			1	:	data = set(`FLAG, 0);		
			2	:	data = set(`STACK0, 0);		
			3	:	data = set(`STACK1, 0);		
			4	:	data = set(`STACK2, 0);		
			5	:	data = set(`STACK3, 0);		
			6	:	data = set(`STACKSIZE, 0);		
			7	:	data = set(`BUFFER, 8'b1000_0000);		
			8	:	data = set(`GOUT, 8'b1000_0000);		
			9	:	data = jmp(	10	);
					// WAIT		
			10	:	data = atc(`SMPL,	15	);
			11	:	data = atc(`POP,	38	);
			12	:	data = atc(`SUM, 	61	);
			13	:	data = atc(`MULT,	65	);
			14	:	data = jmp(	10	);
					// PUSH		
			15	:	data = bit_and(`BUFFER, 8'b1100_0000);		
			16	:	data = bit_and(`STACKSIZE, 8'b0000_1111);		
			17	:	data = jmp_eq(`STACKSIZE, 8'b0000_0000,	23	);
			18	:	data = jmp_eq(`STACKSIZE, 8'b0000_0001,	25	);
			19	:	data = jmp_eq(`STACKSIZE, 8'b0000_0011,	27	);
			20	:	data = jmp_eq(`STACKSIZE, 8'b0000_0111,	29	);
			21	:	data = jmp_eq(`STACKSIZE, 8'b0000_1111,	31	);
			22	:	data = jmp(	33	);
							
			23	:	data = set(`STACKSIZE, 8'b0000_0001);		
			24	:	data = jmp(	33	);
			25	:	data = set(`STACKSIZE, 8'b0000_0011);		
			26	:	data = jmp(	33	);
			27	:	data = set(`STACKSIZE, 8'b0000_0111);		
			28	:	data = jmp(	33	);
			29	:	data= set(`STACKSIZE, 8'b0000_1111);		
			30	:	data = jmp(	33	);
			31	:	data = set(`STACKSIZE, 8'b0001_1111);		
			32	:	data = jmp(	33	);
			33	:	data = mov(`STACK2, `STACK3);		
			34	:	data = mov(`STACK1, `STACK2);		
			35	:	data = mov(`STACK0, `STACK1);		
			36	:	data = mov(`DINP, `STACK0);		
			37	:	data = jmp(	69	);
					// POP		
			38	:	data = bit_and(`BUFFER, 8'b1100_0000);		
			39	:	data = bit_and(`STACKSIZE, 8'b0000_1111);		
			40	:	data = mov(`STACK1, `STACK0);		
			41	:	data = mov(`STACK2, `STACK1);		
			42	:	data = mov(`STACK3, `STACK2);		
							
			43	:	data = jmp_eq(`STACKSIZE, 8'b0000_1111,	48	);
			44	:	data = jmp_eq(`STACKSIZE, 8'b0000_0111,	51	);
			45	:	data = jmp_eq(`STACKSIZE, 8'b0000_0011,	54	);
			46	:	data = jmp_eq(`STACKSIZE, 8'b0000_0001,	57	);
			47	:	data = jmp_eq(`STACKSIZE, 8'b0000_0000,	59	);
							
			48	:	data = set(`STACK3, 8'd0);		
			49	:	data = set(`STACKSIZE, 8'b0000_0111);		
			50	:	data = jmp(	60	);
			51	:	data = set(`STACK2, 8'd0);		
			52	:	data = set(`STACKSIZE, 8'b0000_0011);		
			53	:	data = jmp(	60	);
			54	:	data = set(`STACK1, 8'd0);		
			55	:	data = set(`STACKSIZE, 8'b0000_0001);		
			56	:	data = jmp(	60	);
			57	:	data = set(`STACK0, 8'd0);		
			58	:	data = set(`STACKSIZE, 8'b0000_0000);		
			59	:	data = jmp(	60	);
							
			60	:	data = jmp(	69	);
					// SIGNED ADDITION		
			61	:	data = bit_and(`BUFFER, 8'b1100_0000);		
			62	:	data =  bit_and(`STACKSIZE, 8'b0000_1111);		
			63	:	data = add_signed(`STACK1, `STACK0);		
			64	:	data = jmp(	40	);
					// SIGNED MULTIPLICATIOn		
			65	:	data = bit_and(`BUFFER, 8'b1100_0000);		
			66	:	data = bit_and(`STACKSIZE, 8'b0000_1111);		
			67	:	data = mlt_signed(`STACK1, `STACK0);		
			68	:	data = jmp(	40	);
					// SET LEDR AND GPO		
			69	:	data = mov(`STACK0, `DOUT);		
			70	:	data = atc(`OFLW,	75	);
			71	:	data = bit_or(`BUFFER, 8'b1000_0000);		
			72	:	data = add_unsigned_reg(`BUFFER, `STACKSIZE);		
			73	:	data = mov(`BUFFER, `GOUT);		
			74	:	data = jmp(	10	);
							
			75	:	data = add_unsigned(`BUFFER, 8'b0010_0000);		
			76	:	data = jmp(	71	);

			
			default: data = 35'b0;
			
			/*
			0: data = set(`DOUT, 8'd1);
			4: data = {`MOV, `SHL, `REG, `DOUT, `REG, `DOUT, `N8};
			8: data = jmp(4);
			default : data = 35'b0;
			*/
			
		endcase
		
		function [34:0] set;
			input [7:0] reg_num;
			input [7:0] value;
			set = {`MOV, `PUR, `NUM, value, `REG, reg_num, `N8};
		endfunction
		
		function [34:0] mov;
			input [7:0] src_reg;
			input [7:0] dst_reg;
			mov = {`MOV, `PUR, `REG, src_reg, `REG, dst_reg, `N8};
		endfunction
		
		function [34:0] jmp;
			input [7:0] addr;
			jmp = {`JMP, `UNC, `N10, `N10, addr};
		endfunction

		function [34:0] jmp_eq;
			input [7:0] dst_reg;
			input [7:0] bin;
			input [7:0] ip;
			jmp_eq = {`JMP, `EQ, `REG, dst_reg, `NUM, bin, ip};
		endfunction
		
		function [34:0] atc;
			input [2:0] bit;
			input [7:0] addr;
			atc = {`ATC, bit, `N10, `N10, addr};
		endfunction
		
		function [34:0] acc;
			input [2:0] op;
			input [7:0] reg_num;
			input [7:0] value;
			acc = {`ACC, op, `REG, reg_num, `NUM, value, `N8};
		endfunction
		
		// add the numbers in dst_reg and reg_2 and place the sum in dst_reg
		function [34:0] add_signed;
			input [7:0] dst_reg;
			input [7:0] reg_2;
			add_signed = {`ACC, `SAD, `REG, dst_reg, `REG, reg_2, `N8};
		endfunction

		// add a number to a register
		function [34:0] add_unsigned;
			input [7:0] dst_reg;
			input [7:0] num;
			add_unsigned = {`ACC, `UAD, `REG, dst_reg, `NUM, num, `N8};
		endfunction	
		
		// add contents of a register to another register
		function [34:0] add_unsigned_reg;
			input [7:0] dst_reg;
			input [7:0] src_reg;
			add_unsigned_reg = {`ACC, `UAD, `REG, dst_reg, `REG, src_reg, `N8};
		endfunction
		
		function [34:0] mlt_signed;
			input [7:0] dst_reg;
			input [7:0] reg_2;
			mlt_signed = {`ACC, `SMT, `REG, dst_reg, `REG, reg_2, `N8};
		endfunction
		
		function [34:0] bit_and;
			input [7:0] dst_reg;
			input [7:0] bin;
			bit_and = {`ACC, `AND, `REG, dst_reg, `NUM, bin, `N8};
		endfunction
		
		function [34:0] bit_or;
			input [7:0] dst_reg;
			input [7:0] bin;
			bit_or = {`ACC, `OR, `REG, dst_reg, `NUM, bin, `N8};
		endfunction
		
		function [34:0] set_bit;
			input [7:0] reg_num;
			input [2:0] bit;
			set_bit = {`ACC, `OR, `REG, reg_num, `NUM, 8'b1 << bit, `N8};
		endfunction
		
		function[34:0] clr_bit;
			input[7:0] reg_num;
			input[2:0] bit;
			clr_bit = {`ACC, `AND, `REG, reg_num, `NUM, ~(8'b1 << bit), `N8};
		endfunction
		
endmodule

