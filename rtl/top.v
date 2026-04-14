module uart_top (
    input clk, rst,
    // Receiver Ports
    input rx,
    input read_tick,   // User pulses this to read from RX FIFO
    output rx_empty,    // Tells user if RX FIFO has data
    output [7:0] data_out,    // Data from RX FIFO
    // Transmitter Ports
    input  [7:0] data_in,
    input wr_en,       // User pulses this to write to TX FIFO
    output tx,
    output tx_full,   // Tells user if TX FIFO is full
    output busy        
); 

    wire tx_en_sig, rx_en_sig;
    wire [7:0] tx_data_fifo;  // Data going from FIFO to Transmitter
    wire [7:0] rx_data_raw;   // Data going from Receiver to FIFO
    wire tx_fifo_empty;
    wire rx_rdy_signal;       // Connects rx.rdy to rx_fifo.wr_en
    wire tx_start_pulse;      // Internal trigger to start UART tx

    // 1. Baud Generator
    // RX_EN pulses every 27 cycles (for 16x oversampling)
    // TX_EN pulses every 434 cycles (for 1x bit period)
    baud_gen baud_unit (
        .clk(clk),
        .tx_en(tx_en_sig),
        .rx_en(rx_en_sig)
    );

    // 2. TX FIFO 
    assign tx_start_pulse = !busy && !tx_fifo_empty;

    uart_fifo #(.DEPTH(16)) tx_buffer (
        .clk(clk), .rst(rst),
        .wr_en(wr_en),             
        .rd_en(tx_start_pulse),    // Auto-pull when UART is free
        .din(data_in),
        .dout(tx_data_fifo),
        .full(tx_full),
        .empty(tx_fifo_empty)
    );

    // 3. Transmitter 
    transmitter tx_inst (
        .clk(clk), .rst(rst),
        .en(tx_en_sig),
        .wr_en(tx_start_pulse),    // Triggered by FIFO logic
        .data_in(tx_data_fifo),
        .tx(tx),
        .busy(busy)
    );

    // 4. Receiver 
    receiver rx_inst (
        .clk(clk), .rst(rst),
        .rx(rx),
        .en(rx_en_sig),
        .clr_rdy(rx_rdy_signal),   // FIFO clears this automatically
        .rdy(rx_rdy_signal),
        .data_out(rx_data_raw)
    );

    // 5. RX FIFO 
    uart_fifo #(.DEPTH(16)) rx_buffer (
        .clk(clk), .rst(rst),
        .wr_en(rx_rdy_signal),     // Push whenever receiver is ready
        .rd_en(read_tick),         // User input
        .din(rx_data_raw),
        .dout(data_out),
        .full(),                   // Overflow ignored for now
        .empty(rx_empty)
    );

endmodule