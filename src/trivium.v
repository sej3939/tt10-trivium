module tt_trivium (
    input wire clk,
    input wire rst,         // Reset signal
    input wire init,        // Initialization trigger
    input wire enable,      // Enable encryption
    input wire [79:0] key,  // 80-bit key
    input wire [79:0] iv,   // 80-bit IV
    output reg keystream_bit // Output keystream bit
);

    // Trivium shift register
    reg [287:0] s;

    integer i;
    reg initialized = 0;

    // Feedback taps for keystream
    reg t1, t2, t3;

    // Initialization Phase
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers
            s = 288'b0;
            initialized <= 0;
        end
        else if (init && !initialized) begin
            // Load key into s
            s[287:208] = key[79:0];

            // Load IV into s
            s[194:115] = iv[79:0];

            // Set the last 3 bits of s to 1 as per Trivium spec
            s[110:0] = 3'b111;

            // Shift register state is cycled 4 full times (4*288=1152)
            for (i = 0; i < 1151; i = i + 1) begin
                // Generate taps for shifting
                t1 = s[222] ^ s[195] ^ (s[196] & s[197]) ^ s[117];
                t2 = s[126] ^ s[111] ^ (s[112] & s[113]) ^ s[24];
                t3 = s[45] ^ s[0] ^ (s[2] & s[1]) ^ s[219];
                // Shift registers and insert feedback
                s[287:195] = {t3, s[287:196]};
                s[194:111] = {t1, s[194:112]};
                s[110:0] = {t2, s[110:1]};
            end
            initialized <= 1;
        end
    end

    // Keystream Generation
    always @(posedge clk) begin
        if (initialized && enable) begin
            // Generate taps for keystream
            t1 = s[222] ^ s[195];
            t2 = s[126] ^ s[111];
            t3 = s[45] ^ s[0];

            // Generate keystream bit
            keystream_bit = t1 ^ t2 ^ t3;

            // Generate taps for shifting
            t1 = t1 ^ (s[196] & s[197]) ^ s[117];
            t2 = t2 ^ (s[112] & s[113]) ^ s[24];
            t3 = t3 ^ (s[2] & s[1]) ^ s[219];

            // Shift registers and insert feedback
            s[287:195] = {t3, s[287:196]};
            s[194:111] = {t1, s[194:112]};
            s[110:0] = {t2, s[110:1]};
        end
    end

endmodule
