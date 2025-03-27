`default_nettype none
`timescale 1ns/1ps 

//design adapted from Dennis Du and modified for Trivium

module trivium_top(
    input wire serial_in, //input for rx data 
    output wire serial_out, //output for tx data
    input  wire       ena,      // Always 1 when the design is powered
    input  wire       clk,      // System clock (should be 100MHz on Basys 3)
    input  wire       rst_n     // Active low reset
);

    //necessary parameters
    parameter CLK_FREQ = 100000000; //100MHz clock of Basys 3 FPGA
    parameter BAUD_RATE = 9600; //9600 BAUD rate 
    
    //signals for uart pins on FPGA
    wire rx = serial_in[0]; //rx input connection 
    wire tx; 
    assign serial_out[0] = tx; //tx output connection 
    assign serial_out[7:1] = 7'b0; //set the upper bits to 0 for now


    //internal wires for UART modules
    wire [7:0] urx_data; 
    wire [7:0] utx_data; 

    wire urx_valid; 
    wire utx_valid;
    wire utx_ready; 

    //FIFO signals
    wire fifo_empty, fifo_full; 
    reg fifo_rd_en; 
    reg fifo_wr_en; 
    wire [7:0] fifo_data_out; //data read from fifo 

    //encryption logic buffer
    reg [7:0] encrypted_data;

    //Trivium signals
    reg keystream_read;
    wire [7:0] keystream_byte;
    wire keystream_valid;
    
    //instantiate UART Receiver
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    )
    uart_rx_inst(
        .rx_data(urx_data),
        .rx_valid(urx_valid),
        .received_bit(rx),
        .rst_n(rst_n),
        .clk(clk),
        .encryption_done(keystream_valid)
    ); 


    //instantiate UART Transmitter 
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    )
    uart_tx_inst(
        .tx_ready(utx_ready),
        .tx_serial_out(tx), 
        .parallel_data_in(utx_data),
        .tx_valid(utx_valid),
        .rst_n(rst_n),
        .clk(clk)
    );
    
    
    //instantiate the FIFO for uart
    fifo #(
        .WIDTH(8),
        .DEPTH(10)
    ) uart_fifo_inst (
        .rd_enable(fifo_rd_en),
        .rd_data_buffer(fifo_data_out),
        .rd_valid(utx_valid), //the tx module reads from the fifo 
        .wr_enable(fifo_wr_en),
        .wr_data_buffer(encrypted_data), //the encrypted data gets written to the uart fifo
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full),
        .clk(clk),
        .rst_n(rst_n)
    );


    //instantiate the Trivium module
    trivium trivium_inst (
        .clk(clk),
        .rst_n(rst_n),
        .keystream_read(keystream_read),
        .keystream_byte(keystream_byte),
        .keystream_valid(keystream_valid)
    );

    //character encryption and FIFO control
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_wr_en <= 0;
            fifo_rd_en <= 0;
        end else begin
            fifo_wr_en <= 0;
            fifo_rd_en <= 0;
            if (urx_valid && !fifo_full && keystream_valid) begin
                encrypted_data <= urx_data ^ keystream_byte;
                fifo_wr_en <= 1;
            end
            if (utx_ready && !fifo_empty) begin
                fifo_rd_en <= 1;  // Read from FIFO
            end
        end
    end
        
    assign utx_data = fifo_data_out;

endmodule
