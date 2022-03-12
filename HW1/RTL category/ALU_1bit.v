`include "FA.v"
module ALU_1bit(result, c_out, set, overflow, a, b, less, Ainvert, Binvert, c_in, op);
input        a;
input        b;
input        less;
input        Ainvert;
input        Binvert;
input        c_in;
input  [1:0] op;
output       result;
output       c_out;
output       set;                 
output       overflow;      
reg result;
reg overflow;

reg a_inv,b_inv;
reg a_out,b_out;
/*
	Write Your Design Here ~
*/
	FA FA_1(.s(set), .carry_out(c_out), .x(a_out), .y(b_out), .carry_in(c_in));
	always@(*)begin
	
		a_out=(Ainvert==1'b1)?~a:a;
		b_out=(Binvert==1'b1)?~b:b;
		
		overflow=c_in^c_out;
		
		case(op)
			2'b10:begin
				result=set;
			end
			2'b00:begin
				result=a_out&b_out;
			end
			2'b01:begin
				result=a_out|b_out;
			end
			default:begin
				if(less)begin
					result=1'b1;
				end
				else begin
					result=1'b0;
				end
			end
		endcase
	end
	
endmodule
