`timescale 1ns/1ps

//help taken from Dennis Du for UART

module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 10
) (
    // Read port
    input wire rd_enable,
    output reg [WIDTH-1:0] rd_data_buffer,
    output reg rd_valid,

    // Write port
    input wire wr_enable,
    input wire [WIDTH-1:0] wr_data_buffer,

    // Status
    output wire fifo_empty,
    output wire fifo_full,

    input wire clk,
    input wire rst_n
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    reg [WIDTH-1:0] memory [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] rd_ptr = 0;
    reg [ADDR_WIDTH-1:0] wr_ptr = 0;
    reg [ADDR_WIDTH:0] count = 0;

    assign fifo_empty = (count == 0);
    assign fifo_full = (count == DEPTH);
    
    always @(posedge clk or negedge rst_n) begin
        
        //if reset, then clear the fifo 
        if (!rst_n) begin 
            rd_ptr <= 0;
            wr_ptr <= 0;
            count <= 0;
            rd_valid <= 0;
        end 
        

        else begin
            //set read to not valid 
            rd_valid <= 0;

            // Write Operation - if wr enable and fifo not full
            if (wr_enable && !fifo_full) begin
                memory[wr_ptr] <= wr_data_buffer;
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
            end

            // Read Operation
            if (rd_enable && !fifo_empty) begin
                rd_data_buffer <= memory[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
                rd_valid <= 1;
            end
        end
    end

endmodule
