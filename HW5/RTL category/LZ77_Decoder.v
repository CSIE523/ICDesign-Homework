module LZ77_Decoder(clk,reset,ready,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input				ready;
input 		[4:0] 	code_pos;
input 		[4:0] 	code_len;
input 		[7:0] 	chardata;
output  			encode;
output  			finish;
output 	  [7:0] 	char_nxt;

reg [7:0]search_buf[0:29];
reg [4:0]counter;

integer i;

assign encode = 0;
assign finish = (search_buf[0]==8'h24) ? 1'd1 : 0;
assign char_nxt = search_buf[0]; 

always@(posedge clk or posedge reset)begin
    if(reset)begin
		counter <= 5'd0;
		for(i=0;i<30;i=i+1)
			search_buf[i] <= 8'h0;
    end
    else begin
		if(ready==1)begin
			if(code_pos == 0 && code_len == 0)
				search_buf[0] <= chardata;
			else if(counter == code_len)begin
				search_buf[0] <= chardata;
				counter <= 0;
			end
			else begin
				search_buf[0] <= search_buf[code_pos]; 
				counter <= counter + 5'd1;			
			end
			for(i=0;i<29;i=i+1)
				search_buf[i+1] <= search_buf[i];
		end
	end
end


endmodule
