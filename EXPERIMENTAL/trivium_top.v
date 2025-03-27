module tt_um_trivium_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    reg keystream_bit;
    reg gen_key;
    reg keystream_valid;

    wire rd_enable_in, rd_enable,out;
    reg [7:0] rd_data_buffer_in, rd_data_buffer_out;
    reg rd_valid_in, rd_valid_out;
    wire wr_enable_in, wr_enable_out;
    wire [7:0] wr_data_buffer_in, wr_data_buffer_out;
    wire fifo_empty_in, fifo_empty_out;
    wire fifo_full_in, fifo_full_out;

    reg [7:0] rx_data;
    reg rx_valid;
    wire received_bit;

    wire tx_ready;
    reg rx_serial_out;
    wire [7:0] parallel_data_in;
    wire tx_valid;

    trivium trivium_ASIC (
        .clk(clk),
        .rst_n(rst_n),
        .enable(gen_key),
        .keystream_bit(keystream_bit),
        .init_flag()
    );

    fifo fifo_in_ASIC (
        .clk(clk),
        .rst_n(rst_n),
        .rd_enable(rd_enable_in),
        .rd_data_buffer(rd_data_buffer_in),
        .rd_valid(rd_valid_in),
        .wr_enable(wr_enable_in),
        .wr_data_buffer(wr_data_buff_in),
        .fifo_empty(fifo_empty_in),
        .fio_full(fifo_full_in)
    );
    
    fifo fifo_out_ASIC (
        .clk(clk),
        .rst_n(rst_n),
        .rd_enable(rd_enable_out),
        .rd_data_buffer(rd_data_buffer_out),
        .rd_valid(rd_valid_out),
        .wr_enable(wr_enable_out),
        .wr_data_buffer(wr_data_buff_out),
        .fifo_empty(fifo_empty_out),
        .fio_full(fifo_full_out)
    );

    uart_rx rx_ASIC (
        .clk(clk),
        .rst_n(rst_n),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .received_bit(received_bit)
    );

    uart_tx tx_ASIC (
        .clk(clk),
        .rst_n(rst_n),
        .tx_ready(tx_ready),
        .tx_serial_out(tx_serial_out),
        .parallel_data_in(tx_data),
        .tx_valid(tx_valid)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gen_key <= 0;
        end
        if (ena) begin
            gen_key <= 1;
            if (fifo_full_in) begin
                gen_key <= 0;
            end
        end
    end

endmodule
