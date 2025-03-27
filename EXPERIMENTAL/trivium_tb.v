module trivium_tb;
    reg clk, rst_n, enable;
    wire keystream_valid;
    integer i;

    wire [7:0] keystream_byte;
    reg keystream_read;

    trivium uut (
        .clk(clk),
        .rst_n(rst_n),
        .keystream_read(keystream_read),
        .keystream_byte(keystream_byte),
        .keystream_valid(keystream_valid)
    );

    always #5 clk = ~clk; // Clock toggle every 5 time units

    initial begin
        clk = 0;
        rst_n = 0;
        keystream_read = 0;
        
        #10 rst_n = 1;   // Release reset
        #11520;

        // Print keystream on console
        for (i = 0; i < 80; i = i + 1) begin
            #10 if (keystream_valid) begin
                $display("Time: %0t | Keystream: %h", $time, keystream_byte);
                keystream_read = 1;
            end else
                keystream_read = 0;    
        end
        $stop; // Stop simulation after a few cycles
    end

endmodule
