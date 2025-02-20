module trivium_tb;
    reg clk, rst, init, enable;
    reg [79:0] key;
    reg [79:0] iv;
    wire keystream_bit;
    integer i;

    reg[79:0] keystream;

    trivium uut (
        .clk(clk),
        .rst(rst),
        .init(init),
        .enable(enable),
        .key(key),
        .iv(iv),
        .keystream_bit(keystream_bit)
    );

    always #5 clk = ~clk; // Clock toggle every 5 time units

    initial begin
        clk = 0;
        rst = 1;
        init = 0;
        enable = 0;
        key = 80'h9719CFC92A9FF688F9AA; // Example key
        iv = 80'hECBB76B09AFF71D0D151; // Example IV
        
        #10 rst = 0;   // Release reset
        #10 init = 1;  // Load key and IV
        #10 init = 0;  
        #10 enable = 1; // Start generating keystream
        #10;

        // Print keystream on console
        for (i = 0; i < 80; i = i + 1)
            #10 keystream[79-i] = keystream_bit;

        #5 $display("Time: %0t | Keystream: %h", $time, keystream);
        $stop; // Stop simulation after a few cycles
    end

endmodule
