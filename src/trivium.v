module trivium (
    input wire clk,
    input wire rst,         // Reset signal
    input wire enable,      // Enable encryption
    output reg keystream_bit // Output keystream bit
);

    parameter [79:0] key = 80'h9719CFC92A9FF688F9AA;
    parameter [79:0] iv = 80'hECBB76B09AFF71D0D151;
    // Trivium shift register
    reg [287:0] s;

    reg [10:0] i = 0;
    reg initialized = 0;

    // Feedback taps for keystream
    reg t1, t2, t3;
    reg t1_new, t2_new, t3_new;

    always @(*) begin
        t1 = s[222] ^ s[195] ^ (s[196] & s[197]) ^ s[117];
        t2 = s[126] ^ s[111] ^ (s[112] & s[113]) ^ s[24];
        t3 = s[45] ^ s[0] ^ (s[2] & s[1]) ^ s[219];
        t1_new = t1 ^ (s[196] & s[197]) ^ s[117];
        t2_new = t2 ^ (s[112] & s[113]) ^ s[24];
        t3_new = t3 ^ (s[2] & s[1]) ^ s[219];
    end

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
            i <= 0;
            initialized <= 0;
        end
        else if (enable) begin
            if (initialized) begin
                // Generate keystream bit
                keystream_bit <= t1 ^ t2 ^ t3;
            end
            
            // Shift registers and insert feedback
            s[287:195] <= {t3_new, s[287:196]};
            s[194:111] <= {t1_new, s[194:112]};
            s[110:0] <= {t2_new, s[110:1]};

            // initialize counter
            i <= i + 1;
            if (i == 1152) begin
                initialized <= 1;
            end
        end
    end

endmodule
