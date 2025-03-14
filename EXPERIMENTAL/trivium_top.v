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

    reg rd_enable;
    reg [7:0] rd_data_buffer;
    reg rd_valid;
    reg wr_enable;
    reg [7:0] wr_data_buffer;
    reg fifo_empty;
    reg fifo_full;

    trivium trivium_ASIC (
        .clk(clk),
        .rst_n(rst_n),
        .enable(gen_key),
        .keystream_bit(keystream_bit),
        .init_flag()
    );

    fifo fifo_ASIC (
        .clk(clk),
        .rst_n(rst_n),
        .rd_enable(),
        .rd_data_buffer(),
        .rd_valid(),
        .wr_enable(),
        .wr_data_buffer(),
        .fifo_empty(),
        .fio_full()
    );

    uart_rx rx_ASIC (
        .clk(clk),
        .rst_n(rst_n),
        .rx_data(rx_data),
        .received_bit()
    );

    uart_tx tx_ASIC (
        .clk(clk),
        .rst_n(rst_n),
        .tx_ready(),
        .tx_serial_out(),
        .parallel_data_in(),
        .tx_valid()
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gen_key <= 1;
        end
        if (ena) begin
            if (fifo_full) begin
                gen_key <= 0;
            end
        end
    end

endmodule
