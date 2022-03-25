module TLS(clk, reset, Set, Stop, Jump, Gin, Yin, Rin, Gout, Yout, Rout);
input           clk;
input           reset;
input           Set;
input           Stop;
input           Jump;
input     [3:0] Gin;
input     [3:0] Yin;
input     [3:0] Rin;
output    reg   Gout;
output    reg   Yout;
output    reg   Rout;

parameter set = 3'b000;
parameter green = 3'b001;
parameter yellow = 3'b010;
parameter red = 3'b011;

reg [2:0]state;
reg [3:0]g_tmp, y_tmp, r_tmp;
reg [3:0]counter;

    always@(Set or Jump)begin
        if(Set==1'b1)begin
            g_tmp=Gin;
            y_tmp=Yin;
            r_tmp=Rin;
            counter=0;
            state=green;
        end
        if(Jump==1'b1)begin
            state=red;
            counter=0;
        end
    end

    always@(posedge clk or posedge reset)begin
        if(reset)begin
            g_tmp<=0;
            y_tmp<=0;
            r_tmp<=0;
            counter<=0;
        end
        else begin
            if(!Stop)begin
                case(state)
                    green:begin
                        Gout<=1;
                        Yout<=0;
                        Rout<=0;
                        counter<=counter+4'd1;
                        if(counter==g_tmp-1)begin
                            state<=yellow;
                            counter<=0;
                        end
                    end
                    yellow:begin
                        Gout<=0;
                        Yout<=1;
                        Rout<=0;
                        counter<=counter+4'd1;
                        if(counter==y_tmp-1)begin
                            state<=red;
                            counter<=0;
                        end
                    end
                    red:begin
                        Gout<=0;
                        Yout<=0;
                        Rout<=1;
                        counter<=counter+4'd1;
                        if(counter==r_tmp-1)begin
                            state<=green;
                            counter<=0;
                        end
                    end
                endcase
            end
        end
    end

endmodule