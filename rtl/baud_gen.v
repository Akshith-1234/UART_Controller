module baud_gen(input clk,
        output tx_en,rx_en
        );
reg [8:0] tx_count = 9'b0;
reg [4:0] rx_count = 5'b0;
always@(posedge clk)
begin
    if(tx_count == 433)
        tx_count <= 9'b0;
    else
        tx_count <= tx_count + 1'b1;

    if(rx_count == 26)
        rx_count <= 5'b0;
    else
        rx_count <= rx_count + 1'b1;
end
assign tx_en = (tx_count == 433);
assign rx_en = (rx_count == 26);
endmodule