module LZ77_Decoder(clk,reset,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input 		[3:0] 	code_pos;
input 		[2:0] 	code_len;
input 		[7:0] 	chardata;
output  			encode;
output  			finish;
output 	 	[7:0] 	char_nxt;

reg [7:0]search_buf[0:8];
reg [3:0]counter;

integer i;

assign encode = 0;
assign finish = (search_buf[0] == 8'h24) ? 1'd1 : 0;
assign char_nxt = search_buf[0]; 

always@(posedge clk or posedge reset)begin
    if(reset)begin
		counter <= 4'd0;
		for(i=0;i<9;i=i+1)
			search_buf[i] <= 8'h0;
    end
    else begin
		if(code_pos == 0 && code_len == 0)
			search_buf[0] <= chardata;
		else if(counter == code_len)begin
			search_buf[0] <= chardata;
			counter <= 0;
		end
		else begin
			search_buf[0] <= search_buf[code_pos]; 
			counter <= counter + 4'd1;			
		end
		
		search_buf[1] <= search_buf[0];
		search_buf[2] <= search_buf[1];
		search_buf[3] <= search_buf[2];
		search_buf[4] <= search_buf[3];
		search_buf[5] <= search_buf[4];
		search_buf[6] <= search_buf[5];
		search_buf[7] <= search_buf[6];
		search_buf[8] <= search_buf[7];
	end
end

endmodule