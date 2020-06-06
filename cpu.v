module cpu
	(
		clock,
		reset_n,
		//调试输出(可以不要)?
		opc,
		oqd,
		oqs,
		oir,
		omar,
		omdr,
		obeat,
		oqw,
		ozf,
		oradd1,
		oradd2,
		ois,
		or0,
		or1,
		or2,
		or3,
		or4,
		or5,
		or6,
		or7
	);

	input	clock;//时钟信号
	input	reset_n;//复位信号
	output [15:0]	or0,or1,or2,or3,or4,or5,or6,or7;
	
	output [15:0]	oqd,oqw,oqs;
	output [15:0]	oir,opc,omar,omdr;
	output [2:0]	oradd1,oradd2;//
	output [4:0]	ois;
	output [3:0]	obeat;
	output			ozf;
	
	reg 		dwren,swren,zf;
	wire [15:0]  q_w,q_data,q_s;
    reg  [15:0]  ir,mar,mdr;
	reg	 [15:0]	r0,r1,r2,r3,r4,r5,r6,r7,acc,madd;//通用寄存器
	reg  [15:0]	pc,sp,sdata,ddata;
	reg  [3:0]	beat;	//节拍
	reg  [2:0]	radd1,radd2;//地址
	reg  [4:0]	instruction;//指令
/*
//指令:
	reg 		lda,	//取数:source -> dest
				add,	//加:dest += source
				sub,	//减:dest -= source
				ands,	//按位且:dest &= source
				ors,	//按位或：dest |= source
				nots,	//按位非：dest = !dest
				jmp,	//跳转：pc += source
				hlt;	//停机
*/

//仿真信号输出:
	assign ozf  = zf;
	assign opc  = pc;
	assign oqw = q_w;
	assign oqs  = q_s;
	assign oir	= ir;
	assign omar = mar;
	assign omdr = mdr;
	assign obeat= beat;
	assign oqd	= q_data;
	assign oradd1 = radd1;
	assign oradd2 = radd2;
	assign ois = instruction;
	assign or0  = r0;
	assign or1  = r1;
	assign or2	= r2;
	assign or3  = r3;
	assign or4  = r4;
	assign or5  = r5;
	assign or6  = r6;
	assign or7  = r7;


//指令存储器:	 
	lpm_rom iram(.address(pc),.inclock(clock),.q(q_w));  //程序存储器
	defparam iram.lpm_width = 16;
	defparam iram.lpm_widthad = 16;
	defparam iram.lpm_outdata = "UNREGISTERED";
	defparam iram.lpm_indata = "REGISTERED";
	defparam iram.lpm_address_control = "REGISTERED";
	defparam iram.lpm_file = "imem16_2013.mif";  //初始化文件,放置程序
//主存:	
	lpm_ram_dq mem(.data(ddata),.address(mar),.we(dwren),.inclock(clock),.q(q_data)); //数据存储器
	defparam mem.lpm_width = 16;
	defparam mem.lpm_widthad = 16;
	defparam mem.lpm_outdata = "UNREGISTERED";
	defparam mem.lpm_indata = "REGISTERED";
	defparam mem.lpm_address_control = "REGISTERED";
//堆栈
	lpm_ram_dq sram(.data(sdata),.address(sp),.we(swren),.inclock(clock),.q(q_s)); //堆栈
	defparam sram.lpm_width = 16;
	defparam sram.lpm_widthad = 16;
	defparam sram.lpm_outdata = "UNREGISTERED";
	defparam sram.lpm_indata = "REGISTERED";
	defparam sram.lpm_address_control = "REGISTERED";
	
		always @(posedge clock or negedge reset_n)
begin
	if (!reset_n)
	begin
		sp		<= 0;
		zf		<= 0;
		pc 	 	<= 0;
		beat	<= 0;
		r0		<= 0;
		r1		<= 0;
		r2		<= 0;
		r3		<= 0;
		r4		<= 0;
		r5		<= 0;
		r6		<= 0;
		r7		<= 0;
		ir		<= 0;
		mdr		<= 0;
		mar		<= 0;
	instruction <= 0;
	end
	else
	begin
//	节拍beat指出的状态： 
		case (beat)
		0:	begin
			beat <= 1;
			end
		1:	begin
				mdr = q_w;
				ir = mdr;
				case (ir[15:13])
				3'b000:	begin//mov
						case(ir[12:11])
						2'b00:	begin//mov reg-reg
								instruction <= 5'b00000;
								radd1 <= ir[10:8];
								radd2 <= ir[7:5];
								beat <= 2;
								end
						2'b01:	begin//mov reg-mem;
								instruction <= 5'b00001;
								radd1 <= ir[10:8];
								mar <= ir[7:0];
								beat <= 2;
								end
						2'b10:	begin//mov mem-reg;
								instruction <= 5'b00010;
								radd2 <= ir[10:8];
								mar <= ir[7:0];
								beat <= 2;
								end
						2'b11:	begin//mov reg-立即数;
								instruction <= 5'b00011;
								radd1 <= ir[10:8];
								acc <= ir[7:0];
								beat <= 2;
								end
						endcase
						end
				3'b001:	begin//add
						case(ir[12:11])
						2'b00:	begin//add reg-reg;
								instruction <= 5'b00100;
								radd1 <= ir[10:8];
								radd2 <= ir[7:5];
								beat <= 2;
								end
						2'b01:	begin//add reg-mem;
								instruction <= 5'b00101;
								radd1 <= ir[10:8];
								mar <= ir[7:0];
								beat <= 2;
								end 
						2'b10:	begin//add reg-立即数;
								instruction <= 5'b00110;
								radd1 <= ir[10:8];
								acc <= ir[7:0];
								beat <= 2;
								end
						endcase
						end
				3'b010: begin//sub
						case(ir[12:11])
						2'b00:	begin//sub reg-reg;
								instruction <= 5'b01000;
								radd1 <= ir[10:8];
								radd2 <= ir[7:5];
								beat <= 2;
								end
						2'b01:	begin//sub reg-mem;
								instruction <= 5'b01001;
								radd1 <= ir[10:8];
								mar <= ir[7:0];
								beat <= 2;
								end
						2'b10:	begin//sub reg-立即数;
								instruction <= 5'b01010;
								radd1 <= ir[10:8];
								acc <= ir[7:0];
								beat <= 2;
								end
						endcase
						end
				3'b011: begin//and
						case(mdr[12:11])
						2'b00:	begin//and reg-reg;
								instruction <= 5'b01100;
								radd1 <= ir[10:8];
								radd2 <= ir[7:5];
								beat <= 2;
								end
						2'b01:	begin//and reg-mem;
								instruction <= 5'b01101;
								radd1 <= ir[10:8];
								mar <= ir[7:0];
								beat <= 2;
								end
						2'b10:	begin//and reg-立即数;
								instruction <= 5'b01110;
								radd1 <= ir[10:8];
								acc <= ir[7:0];
								beat <= 2;
								end
						endcase
						end
				3'b100: begin//or
						case(ir[12:11])
						2'b00:	begin//or reg-reg;
								instruction <= 5'b10000;
								radd1 <= ir[10:8];
								radd2 <= ir[7:5];
								beat <= 2;
								end
						2'b01:	begin//or reg-mem;
								instruction <= 5'b10001;
								radd1 <= ir[10:8];
								mar <= ir[7:0];
								beat <= 2;
								end
						2'b10:	begin//or reg-立即数;
								instruction <= 5'b10010;
								radd1 <= ir[10:8];
								acc <= ir[7:0];
								beat <= 2;
								end
						endcase
						end
				3'b101:	begin//not
						instruction <= 5'b10100;
						radd1 <= ir[10:8];
						beat <= 2;
						end
				3'b110: begin//jmp
						case(ir[12:11])
						2'b00:	begin//jmp A;
								instruction <= 5'b11000;
								madd <= ir[7:0];
								beat <= 2;
								end
						2'b01:	begin//jz;
								instruction <= 5'b11001;
								madd <= ir[7:0];
								beat <= 2;
								end
						2'b10:	begin//push;
								instruction <= 5'b11010;
								radd1 <= ir[2:0];
								case(radd1)
								3'b000: sdata <= r0;
								3'b001: sdata <= r1;
								3'b010: sdata <= r2;
								3'b011: sdata <= r3;
								3'b100: sdata <= r4;
								3'b101: sdata <= r5;
								3'b110: sdata <= r6;
								3'b111: sdata <= r7;
								endcase
								beat <= 2;
								end
						2'b11:	begin//pop;
								instruction <= 5'b11011;
								radd1 <= ir[2:0];
								beat <= 2;
								end
						endcase
						end
				3'b111: begin
						case(ir[12:11])
						2'b00:	begin
									instruction <= 5'b11100;//hlt
									beat <= 2;
								end
						2'b01:	begin
								instruction <= 5'b11101;//call
									madd <= ir[7:0];
									sdata <= pc+1;
									beat <= 2;
								end
						2'b10:	begin
									instruction <= 5'b11110;//ret
									beat <= 2;
								end
						endcase
						end
				default:beat<= 2;
				endcase
			end
		2:	begin
				case (instruction)
				5'b11100:	begin  //hlt;
							beat <= 0;
							end
				default:	beat <= 3;
				endcase
			end
		3:	begin
				case (instruction)
				5'b11010:   begin  //push;
								swren <= 1;
								beat <= 4;
							end
				5'b11011:   begin  //pop;
								sp <= sp-1;
								beat <= 4;
							end
				5'b11100:	begin  //hlt;	
								beat <= 0;
							end
				5'b11101:	begin  //call
								swren <= 1;
								beat <= 4;
							end
				5'b11110:	begin  //ret
								sp <= sp-1;
								beat <= 4;
							end
				default:    beat <= 4;
				endcase
			end 
		4:	begin
				case (instruction)
				5'b11100:	begin  //hlt;	
							beat <= 0;
							end
				default:	beat <= 5;
				endcase
			end
		5:	begin
				mdr = q_data;
				case (instruction)
				5'b00000:	begin	//mov reg-reg
								beat <= 6;
							end
				5'b00001:	begin  //mov reg-mem;	
								acc <= q_data;
								beat <= 6;
							end
				5'b00010:   begin  //mov mem-reg;
								beat <= 6;
							end
					
				5'b00011:   begin  //mov reg-立即数;	
								beat <= 6;
							end
				5'b00100:   begin  //add reg-reg;
								beat <= 6;
							end
					
				5'b00101:   begin  //add reg-mem;
								acc <=q_data;
								beat <= 6;
							end 
					
				5'b01000:   begin  //sub reg-reg;
								beat <= 6;
							end
				5'b01001:   begin  //sub reg-mem;	
								acc <= q_data;
								beat <= 6;
							end
				
				5'b01100:   begin  //and reg-reg;
								beat <= 6;
							end
				5'b01101:   begin  //and reg-mem;
								acc <= q_data;
								beat <= 6;
							end
				
				5'b10000:   begin  //or reg-reg;
								beat <= 6;
							end
				5'b10001:   begin  //or reg-mem;
								acc <= q_data;
								beat <= 6;
							end
				5'b10100:   begin  //not;
								beat <= 6;
							end

				5'b11000:   begin  //jmp;
								beat <= 6;
							end
				5'b11001:   begin  //jz;
								beat <= 6;
							end
				5'b11010:   begin  //push;
								beat <= 6;
							end
				5'b11011:   begin  //pop;
								beat <= 6;
							end
				5'b11100:	begin  //hlt;	
							beat <= 0;
							end
				default:    beat <= 6;
				endcase
			end
		6:	begin
				case (instruction)
				5'b11100:	begin  //hlt;	
							beat <= 0;
							end
				default:	beat <= 7;
				endcase
			end
		7:	begin
			case (instruction)
			5'b00000:	begin	//mov reg-reg
							case(radd2)
							3'b000: acc <= r0;
							3'b001: acc <= r1;
							3'b010: acc <= r2;
							3'b011: acc <= r3;
							3'b100: acc <= r4;
							3'b101: acc <= r5;
							3'b110: acc <= r6;
							3'b111: acc <= r7;
							endcase
							beat <= 8;
						end
			5'b00001:	begin  //mov reg-mem;	
							case(radd1)
							3'b000: r0 <= acc;
							3'b001: r1 <= acc;
							3'b010: r2 <= acc;
							3'b011: r3 <= acc;
							3'b100: r4 <= acc;
							3'b101: r5 <= acc;
							3'b110: r6 <= acc;
							3'b111: r7 <= acc;
							endcase
							beat <= 8;
						end
			5'b00010:   begin  //mov mem-reg;	
							case(radd1)
							3'b000: ddata <= r0;
							3'b001: ddata <= r1;
							3'b010: ddata <= r2;
							3'b011: ddata <= r3;
							3'b100: ddata <= r4;
							3'b101: ddata <= r5;
							3'b110: ddata <= r6;
							3'b111: ddata <= r7;
							endcase
							beat <= 8;
						end
			5'b00011:	begin  //mov-立即数;
							case(radd1)
							3'b000: r0 <= acc;
							3'b001: r1 <= acc;
							3'b010: r2 <= acc;
							3'b011: r3 <= acc;
							3'b100: r4 <= acc;
							3'b101: r5 <= acc;
							3'b110: r6 <= acc;
							3'b111: r7 <= acc;
							endcase
							beat <= 8;
						end
			5'b00100:   begin  //add reg-reg;
							case(radd2)
							3'b000: acc <= r0;
							3'b001: acc <= r1;
							3'b010: acc <= r2;
							3'b011: acc <= r3;
							3'b100: acc <= r4;
							3'b101: acc <= r5;
							3'b110: acc <= r6;
							3'b111: acc <= r7;
							endcase
							beat <= 8;
						end
				
			5'b00101:   begin  //add reg-mem;
							case(radd1)
							3'b000: r0 <= acc+r0;
							3'b001: r1 <= acc+r1;
							3'b010: r2 <= acc+r2;
							3'b011: r3 <= acc+r3;
							3'b100: r4 <= acc+r4;
							3'b101: r5 <= acc+r5;
							3'b110: r6 <= acc+r6;
							3'b111: r7 <= acc+r7;
							endcase
							beat <= 8;
						end 
			5'b00110:	begin  //add reg-立即数；
							case(radd1)
							3'b000: r0 <= acc+r0;
							3'b001: r1 <= acc+r1;
							3'b010: r2 <= acc+r2;
							3'b011: r3 <= acc+r3;
							3'b100: r4 <= acc+r4;
							3'b101: r5 <= acc+r5;
							3'b110: r6 <= acc+r6;
							3'b111: r7 <= acc+r7;
							endcase
							beat <= 8;
						end
			5'b01000:   begin  //sub reg-reg;
							case(radd2)
							3'b000: acc <= r0;
							3'b001: acc <= r1;
							3'b010: acc <= r2;
							3'b011: acc <= r3;
							3'b100: acc <= r4;
							3'b101: acc <= r5;
							3'b110: acc <= r6;
							3'b111: acc <= r7;
							endcase
							beat <= 8;
						end
			5'b01001:   begin  //sub reg-mem;	
							case(radd1)
							3'b000: r0 <= r0-acc;
							3'b001: r1 <= r1-acc;
							3'b010: r2 <= r2-acc;
							3'b011: r3 <= r3-acc;
							3'b100: r4 <= r4-acc;
							3'b101: r5 <= r5-acc;
							3'b110: r6 <= r6-acc;
							3'b111: r7 <= r7-acc;
							endcase
							beat <= 8;
						end
			5'b01010:	begin  //sub reg-立即数；
							case(radd1)
							3'b000: r0 <= r0-acc;
							3'b001: r1 <= r1-acc;
							3'b010: r2 <= r2-acc;
							3'b011: r3 <= r3-acc;
							3'b100: r4 <= r4-acc;
							3'b101: r5 <= r5-acc;
							3'b110: r6 <= r6-acc;
							3'b111: r7 <= r7-acc;
							endcase
							beat <= 8;
						end
			5'b01100:   begin  //and reg-reg;
							case(radd2)
							3'b000: acc <= r0;
							3'b001: acc <= r1;
							3'b010: acc <= r2;
							3'b011: acc <= r3;
							3'b100: acc <= r4;
							3'b101: acc <= r5;
							3'b110: acc <= r6;
							3'b111: acc <= r7;
							endcase
							beat <= 8;
						end
			5'b01101:   begin  //and reg-mem;
							case(radd1)
							3'b000: r0 <= r0&acc;
							3'b001: r1 <= r1&acc;
							3'b010: r2 <= r2&acc;
							3'b011: r3 <= r3&acc;
							3'b100: r4 <= r4&acc;
							3'b101: r5 <= r5&acc;
							3'b110: r6 <= r6&acc;
							3'b111: r7 <= r7&acc;
							endcase
							beat <= 8;
						end
			5'b01110:	begin  //and reg-立即数；
							case(radd1)
							3'b000: r0 <= r0&acc;
							3'b001: r1 <= r1&acc;
							3'b010: r2 <= r2&acc;
							3'b011: r3 <= r3&acc;
							3'b100: r4 <= r4&acc;
							3'b101: r5 <= r5&acc;
							3'b110: r6 <= r6&acc;
							3'b111: r7 <= r7&acc;
							endcase
							beat <= 8;
						end
			5'b10000:   begin  //or reg-reg;
							case(radd2)
							3'b000: acc <= r0;
							3'b001: acc <= r1;
							3'b010: acc <= r2;
							3'b011: acc <= r3;
							3'b100: acc <= r4;
							3'b101: acc <= r5;
							3'b110: acc <= r6;
							3'b111: acc <= r7;
							endcase
							beat <= 8;
						end
			5'b10001:   begin  //or reg-mem;
							case(radd1)
							3'b000: r0 <= r0|acc;
							3'b001: r1 <= r1|acc;
							3'b010: r2 <= r2|acc;
							3'b011: r3 <= r3|acc;
							3'b100: r4 <= r4|acc;
							3'b101: r5 <= r5|acc;
							3'b110: r6 <= r6|acc;
							3'b111: r7 <= r7|acc;
							endcase
							beat <= 8;
						end
			5'b10010:	begin  //or reg-立即数；
							case(radd1)
							3'b000: r0 <= r0|acc;
							3'b001: r1 <= r1|acc;
							3'b010: r2 <= r2|acc;
							3'b011: r3 <= r3|acc;
							3'b100: r4 <= r4|acc;
							3'b101: r5 <= r5|acc;
							3'b110: r6 <= r6|acc;
							3'b111: r7 <= r7|acc;
							endcase
							beat <= 8;
						end
			5'b10100:   begin  //not;
							case(radd2)
							3'b000: r0 <= ~r0;
							3'b001: r1 <= ~r1;
							3'b010: r2 <= ~r2;
							3'b011: r3 <= ~r3;
							3'b100: r4 <= ~r4;
							3'b101: r5 <= ~r5;
							3'b110: r6 <= ~r6;
							3'b111: r7 <= ~r7;
							endcase
							beat <= 8;
						end
			5'b11000:   begin  //jmp A;
							beat <= 8;
						end
			5'b11001:   begin  //jz;
							beat <= 8;
						end
			5'b11010:   begin  //push;
							beat <= 8;
						end
			5'b11011:   begin  //pop;
							case(radd1)
							3'b000: r0 <= q_s;
							3'b001: r1 <= q_s;
							3'b010: r2 <= q_s;
							3'b011: r3 <= q_s;
							3'b100: r4 <= q_s;
							3'b101: r5 <= q_s;
							3'b110: r6 <= q_s;
							3'b111: r7 <= q_s;
							endcase
							beat <= 8;
						end
			5'b11100:	begin  //hlt;	
						beat <= 0;
						end
			5'b11110:	begin  //ret
						madd <= q_s;
						beat <= 8;
						end
			default:    beat <= 8;
			endcase
			end
		8:	begin
			case (instruction)
			5'b00000:	begin	//mov reg-reg
							case(radd1)
							3'b000: r0 <= acc;
							3'b001: r1 <= acc;
							3'b010: r2 <= acc;
							3'b011: r3 <= acc;
							3'b100: r4 <= acc;
							3'b101: r5 <= acc;
							3'b110: r6 <= acc;
							3'b111: r7 <= acc;
							endcase
							beat <= 9;
						end
			5'b00001:	begin  //mov reg-mem;
							beat <= 9;
						end
			5'b00010:   begin  //mov mem-reg;
							dwren <= 1;
							beat <= 9;
						end
			5'b00011:   begin  //mov reg-立即数;
							beat <= 9;
						end
			5'b00100:   begin  //add reg-reg;
							case(radd1)
							3'b000: r0 <= r0+acc;
							3'b001: r1 <= r1+acc;
							3'b010: r2 <= r2+acc;
							3'b011: r3 <= r3+acc;
							3'b100: r4 <= r4+acc;
							3'b101: r5 <= r5+acc;
							3'b110: r6 <= r6+acc;
							3'b111: r7 <= r7+acc;
							endcase
							beat <= 9;
						end
				
			5'b00101:   begin  //add reg-mem;
							beat <= 9;
						end 
			5'b00110:   begin  //add reg-立即数;
							beat <= 9;
						end 
			5'b01000:   begin  //sub reg-reg;
							case(radd1)
							3'b000: r0 <= r0-acc;
							3'b001: r1 <= r1-acc;
							3'b010: r2 <= r2-acc;
							3'b011: r3 <= r3-acc;
							3'b100: r4 <= r4-acc;
							3'b101: r5 <= r5-acc;
							3'b110: r6 <= r6-acc;
							3'b111: r7 <= r7-acc;
							endcase
							beat <= 9;
						end
			5'b01001:   begin  //sub reg-mem;	
							beat <= 9;
						end
			5'b01010:   begin  //sub reg-立即数;
							beat <= 9;
						end 
			5'b01100:   begin  //and reg-reg;
							case(radd1)
							3'b000: r0 <= r0&acc;
							3'b001: r1 <= r1&acc;
							3'b010: r2 <= r2&acc;
							3'b011: r3 <= r3&acc;
							3'b100: r4 <= r4&acc;
							3'b101: r5 <= r5&acc;
							3'b110: r6 <= r6&acc;
							3'b111: r7 <= r7&acc;
							endcase
							beat <= 9;
						end
			5'b01101:   begin  //and reg-mem;
							beat <= 9;
						end
			5'b01110:   begin  //and reg-立即数;
							beat <= 9;
						end
			5'b10000:   begin  //or reg-reg;
							case(radd1)
							3'b000: r0 <= r0|acc;
							3'b001: r1 <= r1|acc;
							3'b010: r2 <= r2|acc;
							3'b011: r3 <= r3|acc;
							3'b100: r4 <= r4|acc;
							3'b101: r5 <= r5|acc;
							3'b110: r6 <= r6|acc;
							3'b111: r7 <= r7|acc;
							endcase
							beat <= 9;
						end
			5'b10001:   begin  //or reg-mem;
							beat <= 9;
						end
			5'b10010:   begin  //or reg-立即数;
							beat <= 9;
						end
			5'b10100:   begin  //not;
							beat <= 9;
						end

			5'b11000:   begin  //jmp A;
							beat <= 9;
						end
			5'b11001:   begin  //jz;
							beat <= 9;
						end
			5'b11010:   begin  //push;
							beat <= 9;
						end
			5'b11011:   begin  //pop;
							beat <= 9;
						end
			5'b11100:	begin  //hlt;
						beat <= 0;
						end
			5'b11110:	begin  //ret
						beat <= 9;
						end
			default:    beat <= 9;
			endcase
			end
		9:	begin
			case (instruction)
			5'b00000:	begin	//mov reg-reg
							pc <= pc + 1;
							beat <= 0;
						end
			5'b00001:	begin  //mov reg-mem;
							pc <= pc + 1;
							beat <= 0;
						end
			5'b00010:   begin  //mov mem-reg;
							dwren <= 0;
							pc <= pc +1;
							beat <= 0;
						end
			5'b00011:   begin  //mov reg-立即数;
							pc <= pc +1;
							beat <= 0;
						end
			5'b00100:   begin  //add reg-reg;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end
				
			5'b00101:   begin  //add reg-mem;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end 
			5'b00110:   begin  //add reg-立即数;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end 
				
			5'b01000:   begin  //sub reg-reg;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end
			5'b01001:   begin  //sub reg-mem;	
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end
			5'b01010:   begin  //sub reg-立即数;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end
			5'b01100:   begin  //and reg-reg;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end
			5'b01101:   begin  //and reg-mem;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end
			5'b01110:   begin  //and reg-立即数;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end
			5'b10000:   begin  //or reg-reg;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end
			5'b10001:   begin  //or reg-mem;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end
			5'b10010:   begin  //or reg-立即数;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc +1;
							beat <= 0;
						end
			5'b10100:   begin  //not;
							case(radd1)
							3'b000: begin
									if(r0 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b001: begin
									if(r1 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b010: begin
									if(r2 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b011: begin
									if(r3 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b100: begin
									if(r4 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b101: begin
									if(r5 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b110: begin
									if(r6 == 0) zf <= 1;
									else zf <= 0;
									end
							3'b111: begin
									if(r7 == 0) zf <= 1;
									else zf <= 0;
									end
							endcase
							pc <= pc + 1;
							beat <= 0;
						end

			5'b11000:   begin  //jmp A;
							pc <= madd;
							beat <= 0;
						end
			5'b11001:   begin  //jz;
							if (zf != 1)
							pc <= madd;
							else
							pc <= pc+1;
							beat <= 0;
						end
			5'b11010:   begin  //push;
							dwren <= 0;
							pc <= pc + 1;
							sp <= sp + 1;
							beat <= 0;
						end
			5'b11011:   begin  //pop;
							pc <= pc + 1;
							beat <= 0;
						end
			5'b11100:	begin  //hlt;	
						beat <= 0;
						end
			5'b11101:	begin  //call
						dwren <= 0;
						pc <= madd;
						sp <= sp+1;
						beat <= 0;
						end
			5'b11110:	begin //ret
						pc <= madd;
						beat <= 0;
						end
			default:    beat <= 0;
			endcase
			end
		endcase
	end 
end
endmodule
 



