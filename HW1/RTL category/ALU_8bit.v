`include "ALU_1bit.v"
module ALU_8bit(result, zero, overflow, ALU_src1, ALU_src2, Ainvert, Binvert, op);
input  [7:0] ALU_src1;
input  [7:0] ALU_src2;
input        Ainvert;
input        Binvert;
input  [1:0] op;
output [7:0] result;
output       zero;
output       overflow;

localparam less_con=1'b0;

wire [6:0]c_tmp;
wire set_tmp;

wire set;
/*
	Write Your Design Here ~
*/
	ALU_1bit ALU_1bit1(.result(result[0]), .c_out(c_tmp[0]), .set(), .overflow(), .a(ALU_src1[0]), .b(ALU_src2[0]), 
						.less(set), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(Binvert), .op(op));
	ALU_1bit ALU_1bit2(.result(result[1]), .c_out(c_tmp[1]), .set(), .overflow(), .a(ALU_src1[1]), .b(ALU_src2[1]), 
						.less(less_con), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_tmp[0]), .op(op));
	ALU_1bit ALU_1bit3(.result(result[2]), .c_out(c_tmp[2]), .set(), .overflow(), .a(ALU_src1[2]), .b(ALU_src2[2]), 
						.less(less_con), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_tmp[1]), .op(op));
	ALU_1bit ALU_1bit4(.result(result[3]), .c_out(c_tmp[3]), .set(), .overflow(), .a(ALU_src1[3]), .b(ALU_src2[3]), 
						.less(less_con), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_tmp[2]), .op(op));
	ALU_1bit ALU_1bit5(.result(result[4]), .c_out(c_tmp[4]), .set(), .overflow(), .a(ALU_src1[4]), .b(ALU_src2[4]), 
						.less(less_con), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_tmp[3]), .op(op));
	ALU_1bit ALU_1bit6(.result(result[5]), .c_out(c_tmp[5]), .set(), .overflow(), .a(ALU_src1[5]), .b(ALU_src2[5]), 
						.less(less_con), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_tmp[4]), .op(op));
	ALU_1bit ALU_1bit7(.result(result[6]), .c_out(c_tmp[6]), .set(), .overflow(), .a(ALU_src1[6]), .b(ALU_src2[6]), 
						.less(less_con), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_tmp[5]), .op(op));
	ALU_1bit ALU_1bit8(.result(result[7]), .c_out(), .set(set_tmp), .overflow(overflow), .a(ALU_src1[7]), .b(ALU_src2[7]), 
						.less(less_con), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(c_tmp[6]), .op(op));

	assign	zero=~(result[0]|result[1]|result[2]|result[3]|result[4]|result[5]|result[6]|result[7]);
	assign	set=set_tmp^overflow;
	
endmodule	