module transmitter(input clk, wr_en, en, rst,
                    [7:0]data_in,
                    output reg tx,
                    output busy);

parameter idle_state =2'b00, start_state = 2'b01, data_state = 2'b10, stop_state = 2'b11;
reg [7:0] data;
reg [2:0] index;
reg [1:0] state = idle_state;

always@(posedge clk)
begin
    if(rst) begin
        state <= idle_state;
        tx <= 1'b1;
        index <= 3'b0;
    end
    else begin
    case(state)
        idle_state: begin
            tx <= 1'b1;
            if(wr_en)
            begin
                state <= start_state;
                index <= 3'b0;
                data <= data_in;
            end
        end
        start_state: begin
            tx <= 1'b0;
            if(en)
                state <= data_state;
        end
        data_state: begin
            tx <= data[index];
            if(en) begin
                if(index == 3'h7)
                    state <= stop_state;
                else
                    index <= index + 1'b1; 
            end
        end
        stop_state: begin
            tx <= 1'b1;
            if(en)
                state <= idle_state;
        end
        default : state <= idle_state;
    endcase
    end
end
assign busy = (state != idle_state);
endmodule