`timescale 1ns / 1ps

module trivium_top_tb;
    
    reg [7:0] serial_in;
    wire [7:0] serial_out;
    reg ena;
    reg clk;
    reg rst_n;
    
    // Instantiate the trivium_top module
    trivium_top uut (
        .serial_in(serial_in),
        .serial_out(serial_out),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
    
    // Clock generation (100MHz -> 10ns period)
    always #5 clk = ~clk;
    
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        ena = 1;
        serial_in = 8'b0;
        
        // Apply reset
        #20 rst_n = 1;
        
        // Send 10 bytes of data
        repeat (10) begin
            #20 serial_in = $random; // Assign random 8-bit values
            #40; // Wait for some time to simulate data transmission
        end
        
        // Finish simulation
        #100;
        $finish;
    end
    
    // Monitor output
    initial begin
        $monitor("Time = %0t, Serial In = %h, Serial Out = %h", $time, serial_in, serial_out);
    end
    
endmodule
