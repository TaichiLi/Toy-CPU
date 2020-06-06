begin
	case (q_w[7:5])
	3'b000:	begin//mov
			case(q_w[4:3])
			2'b00:	begin//mov reg-reg
					instruction <= 5'b00000;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			2'b01:	begin//mov reg-mem;
					instruction <= 5'b00001;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			2'b10:	begin//mov mem-reg;
					instruction <= 5'b00010;
					radd2 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			2'b11:	begin//mov reg-立即数;
					instruction <= 5'b00011;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			endcase
			end
	3'b001:	begin//add
			case(q_w[4:3])
			2'b00:	begin//add reg-reg;
					instruction <= 5'b00100;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			2'b01:	begin//add reg-mem;
					instruction <= 5'b00101;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end 
			2'b10:	begin//add reg-立即数;
					instruction <= 5'b00110;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			endcase
			end
	3'b010: begin//sub
			case(q_w[4:3])
			2'b00:	begin//sub reg-reg;
					instruction <= 5'b01000;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			2'b01:	begin//sub reg-mem;
					instruction <= 5'b01001;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			2'b10:	begin//sub reg-立即数;
					instruction <= 5'b01010;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			endcase
			end
	3'b011: begin//and
			case(q_w[4:3])
			2'b00:	begin//and reg-reg;
					instruction <= 5'b01100;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			2'b01:	begin//and reg-mem;
					instruction <= 5'b01101;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			2'b10:	begin//and reg-立即数;
					instruction <= 5'b01110;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			endcase
			end
	3'b100: begin//or
			case(q_w[4:3])
			2'b00:	begin//or reg-reg;
					instruction <= 5'b10000;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			2'b01:	begin//or reg-mem;
					instruction <= 5'b10001;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			2'b10:	begin//or reg-立即数;
					instruction <= 5'b10010;
					radd1 <= q_w[2:0];
					pc <= pc+1;
					jp <= 2;
					end
			endcase
			end
	3'b101:	begin//not
			instruction <= 5'b10100;
			radd1 <= q_w[2:0];
					jp <= 2;
			end
	3'b110: begin//jmp
				instruction <= 5'b11000;
				pc <= pc + 1;
				jp <= 2;
				end
	3'b111: instruction <= 5'b11100;//hlt
	default:jp<= 2;
	endcase
end