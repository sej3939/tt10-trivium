`timescale 1ns/1ps

//Design adapted from Dennis Du

module uart_tx
#(
    parameter CLK_FREQ = 100000000,
    parameter BAUD_RATE = 9600
)
(
    output wire tx_ready,
    output reg tx_serial_out,
    input wire [7:0] parallel_data_in,
    input wire tx_valid, 
    input wire rst_n,
    input wire clk 
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    reg [3:0] state = 0; 
    localparam IDLE = 4'b0000,      // Idle state (waiting for start bit)
               BIT0 = 4'b0001,
               BIT1 = 4'b0010, 
               BIT2 = 4'b0011,
               BIT3 = 4'b0100, 
               BIT4 = 4'b0101,
               BIT5 = 4'b0110,
               BIT6 = 4'b0111,
               BIT7 = 4'b1000,
               STOP = 4'b1001;      //Stop state  
    reg [7:0] data_reg = 0;         //local data register
    reg [$clog2(CLKS_PER_BIT):0] counter = 0; 

    assign tx_ready = (state == IDLE); //if tx waiting, then transmitter is ready

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            state <= IDLE; 
            tx_serial_out <= 1; //output a non-start bit
        end

        else begin
            case (state)
                
                IDLE: begin
                    tx_serial_out <= 1; //output a non-start bit

                    //however, if we are ready to transmit
                    if (tx_valid) begin
                        data_reg <= parallel_data_in; 
                        state <= BIT0; //transition to sending first bit 
                        counter <= CLKS_PER_BIT - 1;
                        tx_serial_out <= 0; //start bit  
                    end
                end

                BIT0,BIT1,BIT2,BIT3,BIT4,BIT5,BIT6,BIT7: begin
                    //once bit is fully sampled, move on to next bit or state
                    if (counter == 0) begin
                        tx_serial_out <= data_reg[state - 1]; //transmit appropriate bit
                        counter <= CLKS_PER_BIT - 1; //reset the counter
                        state <= state + 1; 
                    end
                    else begin
                        counter <= counter - 1; //decrement counter
                    end

                end

                STOP: begin
                    //if final counter is finished, end 
                    if (counter == 0) begin
                        tx_serial_out <= 1; //send out non start bit 
                        state <= IDLE; //go back to idle state
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
