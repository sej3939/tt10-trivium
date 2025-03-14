module trivium_tb;
    reg clk, rst, enable;
    wire keystream_bit;
    integer i;

    reg[79:0] keystream;

    trivium uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .keystream_bit(keystream_bit)
    );

    always #5 clk = ~clk; // Clock toggle every 5 time units

    initial begin
        clk = 0;
        rst = 0;
        enable = 1; // Enable module
        
        #10 rst = 1;   // Release reset
        #11520;

        // Print keystream on console
        for (i = 0; i < 80; i = i + 1) begin
            #10 keystream[79-i] = keystream_bit;
        end

        #5 $display("Time: %0t | Keystream: %h", $time, keystream);
        $stop; // Stop simulation after a few cycles
    end

endmodule
