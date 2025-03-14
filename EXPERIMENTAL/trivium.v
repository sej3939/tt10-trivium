module trivium (
    input wire clk,
    input wire rst_n,       // Reset signal
    input wire enable,      // Enable encryption
    output reg keystream_bit,   // Output keystream bit
    output reg init_flag    // Initialization flag
);

    parameter [79:0] key = 80'h9719CFC92A9FF688F9AA;
    parameter [79:0] iv = 80'hECBB76B09AFF71D0D151;
    // Trivium shift register
    reg [287:0] s;
    
    // Initialization counter
    reg [10:0] init_cnt;

    // Feedback taps for keystream
    wire t1, t2, t3;
    wire t1_new, t2_new, t3_new;

    assign t1 = s[222] ^ s[195];
    assign t2 = s[126] ^ s[111];
    assign t3 = s[45] ^ s[0];
    assign t1_new = t1 ^ (s[196] & s[197]) ^ s[117];
    assign t2_new = t2 ^ (s[112] & s[113]) ^ s[24];
    assign t3_new = t3 ^ (s[2] & s[1]) ^ s[219];
    
    // Initialization Phase
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Load key into s
            s[287:208] <= key[79:0];
            s[207:193] <= 0;
            // Load IV into s
            s[194:115] <= iv[79:0];
            s[114:3] <= 0;
            // Set the last 3 bits of s to 1 as per Trivium spec
            s[2:0] <= 3'b111;
            init_cnt <= 0;
            init_flag <= 0;
        end
        else if (enable) begin
            // Generate keystream bit
            if (init_flag)
                keystream_bit <= t1 ^ t2 ^ t3;
            
            // Shift registers and insert feedback
            s[287:195] <= {t3_new, s[287:196]};
            s[194:111] <= {t1_new, s[194:112]};
            s[110:0] <= {t2_new, s[110:1]};

            // initialize counter
            if (init_cnt == 1151)
                init_flag <= 1;
            else
                init_cnt <= init_cnt + 1;
        end
    end

endmodule
