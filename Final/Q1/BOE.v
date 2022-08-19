module BOE(clk, rst, data_num, data_in, result);
input 			clk;
input 			rst;
input 	[2:0] 	data_num;
input 	[7:0] 	data_in;
output  [10:0] 	result;

reg [1:0] curt_state;
reg [1:0] next_state;
reg [7:0] value_array [0:5];
reg [2:0] data_num_reg;
reg [2:0] array_pointer;
reg [7:0] min;
reg [10:0] sum;
reg [10:0] result;
parameter [1:0] read_data = 0, output_min = 1, output_sum = 2, output_sort = 3; 

always@(posedge clk or posedge rst) begin
    if(rst) begin
	    curt_state <= read_data;
	end
	else begin
	    curt_state <= next_state;
	end
end

always@(*) begin
    case(curt_state)
	    read_data: 
		    next_state = (array_pointer == data_num_reg)? output_sum : read_data;
		output_sum: 
		    next_state = output_min;
		output_min:
		    next_state = output_sort;
		output_sort:
		    next_state = (array_pointer == data_num_reg)? read_data : output_sort;
	endcase
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
	    value_array[0] <= 0;
		value_array[1] <= 0;
		value_array[2] <= 0;
		value_array[3] <= 0;
		value_array[4] <= 0;
		value_array[5] <= 0;
		data_num_reg <= 7;
		array_pointer <= 0;
		sum <= 0;
		min <= 255;
		result <= 0;
	end
	else begin
	    case(curt_state)
		    read_data: begin
			    data_num_reg <= (data_num != 0)? data_num - 1 : data_num_reg;
				array_pointer <= (array_pointer == data_num_reg)? 0 : array_pointer + 1 ;
				// calculate sum
				sum <= sum + data_in;   
				// calculate min
				if(data_in < min) begin
				    min <= data_in;
				end   		
                // sorting				
				if(data_in >= value_array[0]) begin
				    value_array[0] <= data_in;
					value_array[1] <= value_array[0];
					value_array[2] <= value_array[1];
					value_array[3] <= value_array[2];
					value_array[4] <= value_array[3];
					value_array[5] <= value_array[4];
				end
				else if(data_in >= value_array[1]) begin
					value_array[1] <= data_in;
					value_array[2] <= value_array[1];
					value_array[3] <= value_array[2];
					value_array[4] <= value_array[3];
					value_array[5] <= value_array[4];
				end
				else if(data_in >= value_array[2]) begin
					value_array[2] <= data_in;
					value_array[3] <= value_array[2];
					value_array[4] <= value_array[3];
					value_array[5] <= value_array[4];
				end
				else if(data_in >= value_array[3]) begin
					value_array[3] <= data_in;
					value_array[4] <= value_array[3];
					value_array[5] <= value_array[4];
				end
				else if(data_in >= value_array[4]) begin
					value_array[4] <= data_in;
					value_array[5] <= value_array[4];
				end
				else begin
				
				    value_array[5] <= data_in;
				end
				
			end
			output_sum: begin
			    result <= sum;
			end
            output_min: begin
			    result <= min;
			end
			output_sort: begin
			    result <= value_array[array_pointer];
				array_pointer <= (array_pointer == data_num_reg)? 0 : array_pointer + 1;
				value_array[0] <= (array_pointer == data_num_reg)? 0 : value_array[0];
				value_array[1] <= (array_pointer == data_num_reg)? 0 : value_array[1];
				value_array[2] <= (array_pointer == data_num_reg)? 0 : value_array[2];
				value_array[3] <= (array_pointer == data_num_reg)? 0 : value_array[3];
				value_array[4] <= (array_pointer == data_num_reg)? 0 : value_array[4];
				value_array[5] <= (array_pointer == data_num_reg)? 0 : value_array[5];
				sum <= 0;
				min <= 255;
			end
		endcase
	end
end
endmodule