module receiver(
    input clk, rx, rst, en, clr_rdy,
    output reg rdy,
    output reg [7:0] data_out
);

parameter start_state = 2'b00, data_state = 2'b01, stop_state = 2'b10;

reg [3:0] index;        
reg [3:0] sample_count; 
reg [1:0] state = start_state;
reg [7:0] data = 8'b0;

always@(posedge clk) begin
    if(rst) begin
        state <= start_state;
        rdy <= 1'b0;
        index <= 4'b0;
        sample_count <= 4'b0;
        data <= 8'b0;
        data_out <= 8'b0;
    end else begin
        if(clr_rdy) rdy <= 1'b0;

        if(en) begin
            case(state) 
                start_state: begin
                    if (rx == 1'b0 || sample_count != 0) begin
                        if (sample_count == 4'd15) begin
                            state <= data_state;
                            sample_count <= 4'b0;
                            index <= 4'b0;
                        end else begin
                            sample_count <= sample_count + 1'b1;
                        end
                    end
                end

                data_state: begin
                    sample_count <= sample_count + 1'b1; 
                    if(sample_count == 4'd8) begin
                        data[index] <= rx;
                        index <= index + 1'b1;
                    end
                    
                    if(sample_count == 4'd15) begin
                        sample_count <= 4'b0;
                        if(index == 4'd8) begin
                            state <= stop_state;
                        end
                    end
                end

                stop_state: begin
                    sample_count <= sample_count + 1'b1; 
                    if(sample_count == 4'd8) begin
                        if(rx == 1'b1) begin
                            rdy <= 1'b1;
                            data_out <= data;
                        end
                        state <= start_state;
                        sample_count <= 4'b0;
                    end
                end

                default: state <= start_state;
            endcase
        end
    end
end
endmodule