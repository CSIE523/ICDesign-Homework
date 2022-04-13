module BOE(clk, rst, data_num, data_in, result);
input clk;
input rst;
input [2:0] data_num;
input [7:0] data_in;
output reg[10:0] result;

reg [2:0]state, next_state;
parameter IDLE = 3'd0;
parameter READ = 3'd1;
parameter OUT = 3'd2;

reg [2:0]data_counter;
reg [3:0]state_counter;
reg [2:0]num_tmp;
reg [7:0]data_tmp[0:5];
reg [10:0]sum;
reg [7:0]max;
reg [3:0]counter;
reg [7:0]data_sort[0:5];
reg [7:0]tmp;
reg [2:0]sort_count;

integer i, j;

always@(posedge clk or posedge rst)begin
    if(rst)
        state <= IDLE;
    else 
        state <= next_state;
end



always@(*)begin
    if(rst)
        next_state <= IDLE;
    else begin
        case(state)
            IDLE:
                next_state = READ;
            READ:begin
                if(data_counter == num_tmp) next_state = OUT;
                else next_state = READ;  
            end 
            OUT:
                if(sort_count == 3'd7)next_state = READ; 
                else next_state = OUT;
            default:    next_state = IDLE;
        endcase
    end 
end

always@(*)begin
    if(data_num > 3'd0)
        num_tmp = data_num;
end


//DATA INPUT
always@(posedge clk or posedge rst)begin
    if(rst)begin
        data_counter <= 0;
        for(i=0;i<6;i=i+1)
            data_tmp[i] <= 0;
    end
    else begin
        if(next_state == READ )begin
            data_tmp[data_counter] <= data_in;
            data_counter <= data_counter + 3'd1;
        end
        else if(counter == 4'd2)begin
            
            for(i=0;i<6;i=i+1)
                data_tmp[i] <= 0;
        end
        else if(next_state == OUT)begin
            data_counter <= 0;
        end
    end
end

//DATA SUM
always@(posedge clk or posedge rst)begin
    if(rst)begin
        sum <= 0;
    end
    else begin
        if(next_state == READ)
            sum <= sum + data_in;
        if(counter == 4'd2)
            sum <= 0;
    end
end

//DATA MAX
always@(posedge clk or posedge rst)begin
    if(rst)begin
        max <= 0;
    end
    else begin
        if(next_state == READ)begin
            if(data_in > max)
                max <= data_in;
        end
        if(counter == 4'd2)
            max <= 0;
    end
end

//SORT
always@(*)begin
    if(state == READ && data_counter == num_tmp)begin
        for(i=0;i<6;i=i+1)begin
            data_sort[i] = data_tmp[i];
        end
    end
    else begin
        for (i=6;i>0;i=i-1) begin
            for (j=0;j<i;j=j+1) begin
                if (data_sort[j] < data_sort[j + 1]) begin
                    tmp = data_sort[j];
                    data_sort[j] = data_sort[j + 1];
                    data_sort[j + 1] = tmp;
                end 
            end
        end
    end
end

//DATA OUTPUT
always@(posedge clk or posedge rst)begin
    if(rst)begin
       state_counter <= 0;
       counter <= 0;
       sort_count <= 0;
    end
    else begin
        if(next_state == READ)begin
            state_counter <= (num_tmp + 4'd2);
            counter <= (num_tmp + 4'd2);
            sort_count <= num_tmp -3'd1;
        end
        else if(next_state == OUT && data_in==0)begin
            if(counter == state_counter )
                result <= max;
            else if(counter == state_counter - 4'd1)
                result <= sum;
            else begin
                result <= data_sort[sort_count];
                sort_count <= sort_count - 3'd1;
            end
            counter <= counter - 4'd1;
        end 
    end
end
endmodule