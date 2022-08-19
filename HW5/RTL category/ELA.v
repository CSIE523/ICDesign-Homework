`timescale 1ns/10ps

module ELA(clk, rst, ready, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input				ready;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output 				req;
	output 		reg		wen;
	output 		reg[12:0]	addr;
	output 		reg[7:0]	data_wr;
	output 				done;

	reg [1:0]state, next_state;
	parameter IDLE = 2'b00;
	parameter READ = 2'b01;
	parameter CAL = 2'b10;
	parameter FINISH = 2'b11;

	reg [7:0]i;
	reg [6:0]j;
	reg [2:0]process;
    reg [7:0]min;
	reg ok;
	reg [7:0]data_tmp[0:5];
    reg [8:0]ans_tmp;

	wire [12:0]pos;
    wire [7:0]min1;
    wire [7:0]min2;
    wire [7:0]min3;

    assign min1 = (data_tmp[5] > data_tmp[0]) ? (data_tmp[5] - data_tmp[0]) : (data_tmp[0] - data_tmp[5]); //D1
    assign min2 = (data_tmp[3] > data_tmp[2]) ? (data_tmp[3] - data_tmp[2]) : (data_tmp[2] - data_tmp[3]); //D2
    assign min3 = (data_tmp[4] > data_tmp[1]) ? (data_tmp[4] - data_tmp[1]) : (data_tmp[1] - data_tmp[4]); //D3 

	assign pos = (j << 7) + i;
	assign req = (ready == 1) ? 1'd1 : 1'd0;
	assign done = (state == FINISH) ? 1'd1 : 1'd0;

	always@(posedge clk or posedge rst)begin
		if(rst)
			state <= IDLE;
		else 
			state <= next_state;
	end

	always@(*)begin
		if(rst)
			next_state = IDLE;
		else begin
			case(state)
				IDLE:
					next_state = READ;
				READ:begin
					if( pos == 8063 ) next_state = CAL;
					else next_state = READ;  
				end
				CAL:begin
					if( j == 63 ) next_state = FINISH;
					else next_state = CAL;
				end 
				FINISH:
					next_state = FINISH;
				default:    next_state = IDLE;
			endcase
		end 
	end

	//DATA INPUT
	always@(posedge clk or posedge rst)begin	
		if(rst)begin
			i <= 0;
			j <= 0;
			ok <= 0;
			process <= 0;
            min <= 255;
            data_tmp[5] <= 0;
            data_tmp[4] <= 0;
            data_tmp[3] <= 0;
            data_tmp[2] <= 0;
            data_tmp[1] <= 0;
            data_tmp[0] <= 0;
		end
		else begin
			if(ready==1)begin
			if(state == READ)begin
				wen <= 1;
				addr <= pos;
				data_wr <= in_data;
				if(i == 127 && j == 62) begin
					j <= 1;
					i <= 0;
				end 
				else if(i == 127)begin
					j <= j + 2;
					i <= 0;
				end
				else
					i <= i + 1;
			end
			else if(state == CAL)begin
				if(ok == 1)begin
					wen <= 1;
					if(i == 127)begin
						j <= j + 2;
						i <= 0;
						data_tmp[5] <= 0;
						data_tmp[4] <= 0;
						data_tmp[3] <= 0;
						data_tmp[2] <= 0;
						data_tmp[1] <= 0;
						data_tmp[0] <= 0;
					end
					else 
						i <= i + 1;
					addr <= pos;
                    data_wr <= { 1'b0, ans_tmp[8:1] };
					ok <= 0;
				end
				else begin
					wen <= 0;
					case(process)
						0:begin
                            addr <= pos - 128;
                            process <= process + 3'd1;
                        end
                        1:begin
                            addr <= pos + 128;
                            data_tmp[3] <= data_rd;
                            process <= process + 3'd1;
                        end
                        2:begin
                            if(i == 0)begin
                                data_tmp[4] <= data_rd;
                                data_tmp[5] <= data_tmp[3];
                                ans_tmp <= data_tmp[3] + data_rd;
                                ok <= 1;
                                process <= 0;
                            end
                            else if (i == 127)begin
                                ans_tmp <= data_tmp[3] + data_tmp[2];
                                process <= 0;
                                ok <= 1;
                            end
                            else begin
                                addr <= pos - 127;
                                data_tmp[2] <= data_rd;
                                process <= process + 3'd1;
                            end
                        end
                        3:begin
                            addr <= pos + 129;
                            data_tmp[1] <= data_rd;
                            process <= process + 3'd1;
                        end
                        4:begin
                            data_tmp[0] <= data_rd;
                            min <= (min2 <= min3) ? min2 : min3;
                            ans_tmp <= (min2 <= min3) ? data_tmp[3] + data_tmp[2] : data_tmp[4] + data_tmp[1];
                            process <= process + 3'd1;
                        end
                        5:begin   
                            ans_tmp <= (min == min2 && min <= min1) ? ans_tmp : ((min >= min1) ? data_tmp[5] + data_tmp[0] : ans_tmp);
                            ok <= 1;
                            process <= 3'd6;
                        end
                        default:begin
                            data_tmp[5] <= data_tmp[3];
                            data_tmp[4] <= data_tmp[2];
                            data_tmp[3] <= data_tmp[1];
                            data_tmp[2] <= data_tmp[0];
                            addr <= pos - 127;
                            process <= (i == 127) ? 3'd2 : 3'd3;
                        end
					endcase
				end
			end
			end
		end
	end
	

endmodule