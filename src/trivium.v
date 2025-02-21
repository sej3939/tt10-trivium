module trivium (
    input wire clk,
    input wire rst,         // Reset signal
    input wire enable,      // Enable encryption
    input wire [79:0] key,  // 80-bit key
    input wire [79:0] iv,   // 80-bit IV
    output reg keystream_bit // Output keystream bit
);

    // Trivium shift register
    reg [287:0] s;

    reg [10:0] i;
    reg initialized = 0;

    // Feedback taps for keystream
    reg t1, t2, t3;

    // Initialization Phase
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Load key into s
            s[287:208] <= key[79:0];
            s[207:193] <= 0;
            // Load IV into s
            s[194:115] <= iv[79:0];
            s[114:3] <= 0;
            // Set the last 3 bits of s to 1 as per Trivium spec
            s[2:0] <= 3'b111;
            initialized <= 0;
        end
    end

    // Keystream Generation
    always @(posedge clk) begin
        if (enable) begin
            // Generate taps for keystream
            t1 = s[222] ^ s[195];
            t2 = s[126] ^ s[111];
            t3 = s[45] ^ s[0];

            if (initialized) begin
                // Generate keystream bit
                keystream_bit = t1 ^ t2 ^ t3;
            end

            // Generate taps for shifting
            t1 = t1 ^ (s[196] & s[197]) ^ s[117];
            t2 = t2 ^ (s[112] & s[113]) ^ s[24];
            t3 = t3 ^ (s[2] & s[1]) ^ s[219];

            // Shift registers and insert feedback
            s[287:195] <= {t3, s[287:196]};
            s[194:111] <= {t1, s[194:112]};
            s[110:0] <= {t2, s[110:1]};

            // initialize counter
            i = i + 1;
            if (i == 1152) begin
                initialized <= 1;
            end
        end
    end

endmodule
