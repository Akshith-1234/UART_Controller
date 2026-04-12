module uart_top (
    input        clk, rst,
    // Receiver Ports 
    input        rx, clr_rdy,
    output       rdy,
    output [7:0] data_out,
    // Transmitter Ports 
    input  [7:0] data_in,
    input        wr_en,    
    output       tx,
    output       busy      

    wire tx_en_sig;
    wire rx_en_sig;

   // RX_EN pulses every 27 cycles (for 16x oversampling)
   // TX_EN pulses every 434 cycles (for 1x bit period)
    baud_gen baud_unit (
        .clk(clk),
        .tx_en(tx_en_sig),
        .rx_en(rx_en_sig)
    );

    
    receiver rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .en(rx_en_sig),
        .clr_rdy(clr_rdy),
        .rdy(rdy),
        .data_out(data_out)
    );

    
    transmitter tx_inst (
        .clk(clk),
        .rst(rst),
        .en(tx_en_sig),
        .wr_en(wr_en),     
        .data_in(data_in),
        .tx(tx),
        .busy(busy)         
    );

endmodule