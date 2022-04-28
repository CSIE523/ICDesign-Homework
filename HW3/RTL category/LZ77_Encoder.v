module  LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);
input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output  	reg   	valid;
output  			encode;
output  			finish;
output 		reg[3:0] 	offset;
output 		reg[2:0] 	match_len;
output 	 	reg[7:0] 	char_nxt;


reg [2:0]state, next_state;
parameter IDLE = 3'b000;
parameter READ = 3'b001;
parameter CAL = 3'b010;
parameter OUT = 3'b011;
parameter ADJUST = 3'b100;
parameter FINISH = 3'b101;


reg [7:0]str_buf[0:2048];
reg [7:0]search_buf[0:8];
reg [7:0]lookahead_buf[0:7];
reg [11:0]counter;
reg match;
reg [2:0]matchlen;
reg [3:0]shift_counter;
reg [3:0]search_pos;
reg [3:0]search_counter;
reg [2:0]max;
reg [2:0]looka_counter;
reg flag1;
reg flag2;
reg [3:0]searchpos_ans;

integer i=0;

assign encode = 1'b1;
assign finish = (next_state == FINISH) ? 1'b1 : 0;

//STATE MACHINE
always@(posedge clk or posedge reset)begin
    if(reset)
        state <= IDLE;
    else 
        state <= next_state;
end

always@(*)begin
    if(reset)
        next_state <= IDLE;
    else begin
        case(state)
            IDLE:
                next_state = READ;
            READ:begin
                if(counter == 12'd2048) next_state = CAL;
                else next_state = READ;   
            end
            CAL:begin
                if(flag2 == 1 || flag1 == 0) next_state = OUT;
                else next_state = CAL;
            end 
            OUT:begin
                // if(lookahead_buf[7] == 8'h24) next_state = FINISH;
                // else next_state = ADJUST;
                next_state = ADJUST;
            end
            ADJUST:begin
                if(search_buf[0] == 8'h24) next_state = FINISH;
                else if(shift_counter == (max+3'd1)) next_state = CAL;
                else next_state = ADJUST;
            end 
            FINISH:begin
                next_state = FINISH;
            end
            default:    next_state = IDLE;
        endcase
    end 
end


//DATA INPUT
always@(posedge clk or posedge reset)begin
    if(reset)begin
        counter <= 0;
        for(i=0;i<2049;i=i+1)
            str_buf[i] <= 8'h24;
    end
    else begin 
        if(next_state == READ)begin
            str_buf[counter] <= chardata;
            counter <= counter + 12'd1;
        end
        else if(next_state == CAL && counter == 12'd2048 && state != CAL)  //SPECIAL CASE
            counter <= 12'd8;   //INPUT_STRING START POS
        else if(next_state == CAL && state == ADJUST)begin
            counter <= counter + (max + 3'd1);
        end
        else 
            counter <= counter;
    end
end

//SEARCH_BUF IN LOOKAHEAD_BUF
always@(*)begin 
    if(reset)
        flag1 = 0;
    else begin
        flag1 = ((search_buf[0] == lookahead_buf[7]) || (search_buf[1] == lookahead_buf[7]) || (search_buf[2] == lookahead_buf[7]) 
                || (search_buf[3] == lookahead_buf[7]) || (search_buf[4] == lookahead_buf[7]) || (search_buf[5] == lookahead_buf[7]) || 
                (search_buf[6] == lookahead_buf[7]) || (search_buf[7] == lookahead_buf[7]) || (search_buf[8] == lookahead_buf[7])) ? 1'b1 : 0;
    end
end

//BUFFER CONTROL
always@(posedge clk or posedge reset)begin
    if(reset)begin
        for(i=0;i<8;i=i+1)begin
            search_buf[i] <= 8'h25;
            lookahead_buf[i] <= 8'h25;
        end
        search_buf[8] <= 8'h25;
        match <= 1'b1;
        matchlen <= 0;
        shift_counter <= 0;
        search_pos <= 4'd8;
        max <= 0;
        looka_counter <= 3'd7;
        search_counter <= 4'd8;
        flag2 <= 0;
        searchpos_ans <= 4'd8;
    end
    else begin
        if(next_state == READ && counter < 12'd8)  //INIT LOOK_AHEAD BUFFER
            lookahead_buf[7-counter] <= chardata;
        else if(state == CAL)begin
            if(flag1 == 1'b1)begin
                if(search_buf[search_pos] == lookahead_buf[7])begin
                    if(search_counter == 4'd15)begin
                        if(lookahead_buf[looka_counter] == lookahead_buf[3'd7 - matchlen])begin
                            looka_counter <= looka_counter - 3'd1;
                            matchlen <= matchlen + 3'd1;
                        end
                        else 
                            flag2 <= 1'b1;
                    end
                    else begin
                        if(search_buf[search_counter] == lookahead_buf[3'd7 - matchlen])begin
                            matchlen <= matchlen + 3'd1;
                            search_counter <= search_counter - 4'd1;
                        end
                        else if(search_pos > 0)begin
                            search_pos <= search_pos - 4'd1;
                            search_counter <= search_pos - 4'd1;
                            matchlen <= 0;
                        end
                        else begin
                            search_pos <= search_pos;
                        end
                    end
                    
                    if(matchlen > max)begin
                        max <= matchlen;
                        searchpos_ans <= search_pos;
                        if(matchlen == 3'd7)
                            flag2 <= 1'b1;
                    end
                end
                else if(search_pos > 0)begin
                    search_pos <= search_pos - 4'd1;
                    search_counter <= search_pos - 4'd1;
                    matchlen <= 0;
                end
                else 
                    flag2 <= 1'b1;

                match <= 1'b1; 
            end

            else 
                match <= 0;
        end
        else if(state == OUT)begin
            if(match == 0)begin
                offset <= 0;
                match_len <= 0;
                char_nxt <= lookahead_buf[7];
            end  
            else begin
                offset <= searchpos_ans;
                match_len <= max;
                char_nxt <= lookahead_buf[7-max]; 
            end
        end
        else if(state == ADJUST)begin
            if(shift_counter != (max + 3'd1))begin
                lookahead_buf[0] <= str_buf[counter+shift_counter];
                lookahead_buf[1] <= lookahead_buf[0];
                lookahead_buf[2] <= lookahead_buf[1];
                lookahead_buf[3] <= lookahead_buf[2];
                lookahead_buf[4] <= lookahead_buf[3];
                lookahead_buf[5] <= lookahead_buf[4];
                lookahead_buf[6] <= lookahead_buf[5];
                lookahead_buf[7] <= lookahead_buf[6];
                search_buf[0] <= lookahead_buf[7];
                search_buf[1] <= search_buf[0];
                search_buf[2] <= search_buf[1];
                search_buf[3] <= search_buf[2];
                search_buf[4] <= search_buf[3];
                search_buf[5] <= search_buf[4];
                search_buf[6] <= search_buf[5];
                search_buf[7] <= search_buf[6];
                search_buf[8] <= search_buf[7];
                shift_counter <= shift_counter + 4'd1;
            end
            else begin
                shift_counter <= 0;
                matchlen <= 0;
                looka_counter <= 3'd7;
                search_counter <= 4'd8;
                search_pos <= 4'd8;
                searchpos_ans <= 4'd8;
                max <= 0;
                flag2 <= 0;
                match <= 0;
            end
        end
    end
end

always@(posedge clk or posedge reset) begin
    if(reset)
        valid <= 0;
    else begin
        if(state == OUT)
            valid <= 1'b1;
        else 
            valid <= 0;
    end
end
endmodule