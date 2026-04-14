module uart_fifo #(parameter DEPTH=16, DATA_WIDTH=8) (
    input clk, rst,
    input wr_en, rd_en,
    input [DATA_WIDTH-1:0] din,
    output [DATA_WIDTH-1:0] dout,
    output full, empty
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [$clog2(DEPTH)-1:0] wr_ptr = 0;
    reg [$clog2(DEPTH)-1:0] rd_ptr = 0;
    reg [$clog2(DEPTH):0] count = 0;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);
    assign dout  = mem[rd_ptr];

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0; rd_ptr <= 0; count <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1'b1;
            end
            if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1'b1;
            end
            // Update count
            if (wr_en && !full && !(rd_en && !empty)) count <= count + 1'b1;
            else if (rd_en && !empty && !(wr_en && !full)) count <= count - 1'b1;
        end
    end
endmodule