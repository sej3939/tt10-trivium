`timescale 1ns / 1ps

module trivium_top_tb;
    
    reg serial_in;
    wire serial_out;
    reg ena;
    reg clk;
    reg rst_n;
    reg [7:0] data [0:9]; // Store 10 bytes of test data
    integer i, j, k;
    wire [7:0] rx_data;
    wire rx_valid;
    wire enc_done_dummy;
    assign enc_done_dummy = 1;
    
    // Instantiate the trivium_top module
    trivium_top uut (
        .serial_in(serial_in),
        .serial_out(serial_out),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Instantiate the UART receiver module
    uart_rx uart_rx_inst (
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .received_bit(serial_out),
        .clk(clk),
        .rst_n(rst_n),
        .encryption_done(enc_done_dummy)
    );

    wire [79:0] keystream = 80'h83681F7BDC06AD483BF3;
    wire [79:0] test_data = 80'hA53C7FC19942E7B85DF0;

    wire [79:0] encrypted = keystream ^ test_data;

    reg [6:0] data_counter;
    reg [79:0] output_data;
    
    // Clock generation (100MHz -> 10ns period)
    always #5 clk = ~clk;
    
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        ena = 1;
        serial_in = 1; // Idle state for UART (assuming active low start bit)
        data_counter = 79;
        
        // Load test data
        data[0] = 8'hA5;
        data[1] = 8'h3C;
        data[2] = 8'h7F;
        data[3] = 8'hC1;
        data[4] = 8'h99;
        data[5] = 8'h42;
        data[6] = 8'hE7;
        data[7] = 8'hB8;
        data[8] = 8'h5D;
        data[9] = 8'hF0;
        
        // Apply reset
        #20 rst_n = 1;
        
        // Send 10 bytes bit by bit (assuming 9600 baud rate -> ~104us per bit)
        for (i = 0; i < 10; i = i + 1) begin
            // Start bit (active low)
            serial_in = 0;
            #104160; // Wait one bit period
            
            // Transmit 8 data bits (LSB first)
            for (j = 0; j < 8; j = j + 1) begin
                serial_in = data[i][j];
                #104160; // Wait one bit period
            end
            
            // Stop bit (active high)
            serial_in = 1;
            #104160; // Wait one bit period
        end
        
        // Finish simulation
        #1000000;
        $display("correct output: %h, output_data: %h", encrypted, output_data);
        $finish;
    end

    always @(posedge rx_valid) begin
        for (k = 0; k < 8; k = k + 1) begin
            output_data[data_counter] <= rx_data[7 - k];
            data_counter = data_counter - 1;
        end
        //$display("rx_data: %h", rx_data);
    end
        
endmodule
