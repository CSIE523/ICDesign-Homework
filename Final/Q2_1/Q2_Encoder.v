module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);

input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output  reg			valid;
output  			encode;
output  reg			finish;
output  reg	[3:0] 	offset;
output  reg	[2:0] 	match_len;
output  reg	[7:0] 	char_nxt;

reg			[1:0]	current_state, next_state;
reg			[11:0]	counter;
reg			[3:0]	search_index;
reg			[2:0]	lookahead_index;
reg			[3:0]	str_buffer	[2047:0];
reg			[3:0]	search_buffer	[9:0];

wire				equal	[7:0];
wire		[11:0]	current_encode_len;
wire		[2:0]	curr_lookahead_index;
wire		[3:0]	match_char [5:0];

parameter [1:0] IN=2'b00, ENCODE=2'b01, ENCODE_OUT=2'b10, SHIFT_ENCODE=2'b11;

integer i;

assign	encode = 1'b1;

//取search buf內要配對的字(最多7 所以是0 ~ 6)，不足7個的話去Lookahead buf取
assign	match_char[0] = search_buffer[search_index];
assign	match_char[1] = (search_index >= 1) ? search_buffer[search_index-1] : str_buffer[search_index];
assign	match_char[2] = (search_index >= 2) ? search_buffer[search_index-2] : str_buffer[1-search_index];
assign	match_char[3] = (search_index >= 3) ? search_buffer[search_index-3] : str_buffer[2-search_index];
assign	match_char[4] = (search_index >= 4) ? search_buffer[search_index-4] : str_buffer[3-search_index];


//這邊的search_index <= 8 是因為如果都沒有匹配到就會0-1跑到15 (一開始search_index都是由8開始往0減)
assign	equal[0] = (search_index <= 10) ? ((match_char[0]==str_buffer[0]) ? 1'b1 : 1'b0) : 1'b0;
assign	equal[1] = (search_index <= 10) ? ((match_char[1]==str_buffer[1]) ? equal[0] : 1'b0) : 1'b0; // ? equal[0]代表如果前面都匹配錯後面也都錯了
assign	equal[2] = (search_index <= 10) ? ((match_char[2]==str_buffer[2]) ? equal[1] : 1'b0) : 1'b0;
assign	equal[3] = (search_index <= 10) ? ((match_char[3]==str_buffer[3]) ? equal[2] : 1'b0) : 1'b0;
assign	equal[4] = (search_index <= 10) ? ((match_char[4]==str_buffer[4]) ? equal[3] : 1'b0) : 1'b0;
assign	equal[5] = 1'b0;



assign	current_encode_len = counter+match_len+1; //完成編碼的長度還有正在編碼的長度(match_len)
assign	curr_lookahead_index = lookahead_index+1; //就是目前str_buf要比對的位置(=我的counter) +1是因為會把下一個也拉過去


always @(posedge clk or posedge reset)
begin
	if(reset)
	begin
		current_state <= IN;
		counter <= 12'd0;
		search_index <= 4'd0;
		lookahead_index <= 3'd0;
		valid <= 1'b0;
		finish <= 1'b0;
		offset <= 4'd0;
		match_len <= 3'd0;
		char_nxt <= 8'd0;

		search_buffer[0] <= 4'd0;
		search_buffer[1] <= 4'd0;
		search_buffer[2] <= 4'd0;
		search_buffer[3] <= 4'd0;
		search_buffer[4] <= 4'd0;
		search_buffer[5] <= 4'd0;
		search_buffer[6] <= 4'd0;
		search_buffer[7] <= 4'd0;
		search_buffer[8] <= 4'd0;
        search_buffer[9] <= 4'd0;
	end
	else
	begin
		current_state <= next_state;
		
		case(current_state)
			IN:
			begin
				str_buffer[counter] <= chardata[3:0];
				counter <= (counter==2047) ? 0 : counter+1; 
			end
			ENCODE:
			begin
				if(equal[match_len]==1 && search_index < counter && current_encode_len <= 2048) //search_index < counter的意義就是把如果目前search buf只有一個 那前面8~1就直接錯了
				begin
					char_nxt <= str_buffer[curr_lookahead_index];
					match_len <= match_len+1;
					offset <= search_index;

					lookahead_index <= curr_lookahead_index;
				end
				else
				begin
					search_index <= (search_index==15) ? 0 : search_index-1;  //一開始為0(因為search buf沒東西，後來從8開始遞減)
				end
			end
			ENCODE_OUT:
			begin
				valid <= 1;
				char_nxt <= (current_encode_len==2049) ? 8'h24 : (match_len==0) ? str_buffer[0] : char_nxt;
				counter <= current_encode_len; //counter代表已經完成編碼的數量
			end
			SHIFT_ENCODE:
			begin
				finish <= (counter==2049) ? 1 : 0;
				offset <= 0;
				valid <= 0;
				match_len <= 0;
				search_index <= 10;
				lookahead_index <= (lookahead_index==0) ? 0 : lookahead_index-1;
                search_buffer[9] <= search_buffer[8];
				search_buffer[8] <= search_buffer[7];
				search_buffer[7] <= search_buffer[6];
				search_buffer[6] <= search_buffer[5];
				search_buffer[5] <= search_buffer[4];
				search_buffer[4] <= search_buffer[3];
				search_buffer[3] <= search_buffer[2];
				search_buffer[2] <= search_buffer[1];
				search_buffer[1] <= search_buffer[0];
				search_buffer[0] <= str_buffer[0];

				for (i=0; i<2047; i=i+1) begin
					str_buffer[i] <= str_buffer[i+1];
				end
			end
		endcase
	end
end



always @(*)
begin
	case(current_state)
		IN:
		begin
			next_state = (counter==2047) ? ENCODE : IN;
		end
		ENCODE:
		begin
			next_state = (search_index==15 || match_len==5) ? ENCODE_OUT : ENCODE;  // search_index = 15代表從0-1(underflow，也就是掃完searh buf的全部了)
		end
		ENCODE_OUT:
		begin
			next_state = SHIFT_ENCODE;
		end
		SHIFT_ENCODE:
		begin
			next_state = (lookahead_index==0) ? ENCODE : SHIFT_ENCODE;
		end
		default:
		begin
			next_state = IN;
		end
	endcase
end



endmodule