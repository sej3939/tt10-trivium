`timescale 1ns/1ps

module uart_rx
#(
    parameter CLK_FREQ = 100000000,
    parameter BAUD_RATE = 9600
)
(
    output reg [7:0] rx_data,
    output reg rx_valid,
    input wire received_bit,
    input wire rst_n,
    input wire clk, 
    input wire encryption_done  // New signal to control data reception
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    reg [3:0] state = 0;            // State variable
    localparam IDLE  = 4'b0000,     // Idle state (waiting for start bit)
               START = 4'b0001,     // Wait for middle of start bit
               BIT0  = 4'b0010, 
               BIT1  = 4'b0011,
               BIT2  = 4'b0100, 
               BIT3  = 4'b0101,
               BIT4  = 4'b0110,
               BIT5  = 4'b0111,
               BIT6  = 4'b1000,
               BIT7  = 4'b1001,
               STOP  = 4'b1010;     // Stop state  

    reg [$clog2(CLKS_PER_BIT):0] counter = 0; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin  // If reset
            state <= IDLE; 
            rx_valid <= 0; 
        end
        else begin
            case (state)
                IDLE: begin
                    rx_valid <= 0; 

                    // Only accept a new byte if encryption is done
                    if (received_bit == 0 && encryption_done == 1) begin
                        state <= START; 
                        counter <= CLKS_PER_BIT / 2; // Set counter as clock divided by 2
                    end
                end

                START: begin
                    if (counter == 0) begin
                        counter <= CLKS_PER_BIT - 1; 
                        state <= BIT0; // Move to bit 0
                    end
                    else begin
                        counter <= counter - 1; // Decrement counter
                    end
                end

                BIT0, BIT1, BIT2, BIT3, BIT4, BIT5, BIT6, BIT7: begin
                    if (counter == 0) begin
                        rx_data[state - 2] <= received_bit; // Store received bit
                        counter <= CLKS_PER_BIT - 1; 
                        state <= state + 1; // Move to the next state
                    end
                    else begin
                        counter <= counter - 1; 
                    end
                end
                
                STOP: begin
                    if (counter == 0) begin
                        rx_valid <= 1; 
                        state <= IDLE; 
                    end 
                    else begin
                        counter <= counter - 1; 
                    end
                end

                default: state <= IDLE; 
            endcase
        end
    end
endmodule
