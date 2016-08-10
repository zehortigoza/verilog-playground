/*
 * Slave SPI block.
 * Notes:
 *  - clk should be at least 4 times faster than sclk
 *  - it do not send the 7bit of the first byte of a
 *    transaction(right after select slave in ss line) 
 */

module spi_slave(
    clk,
    sclk,
    miso,
    mosi,
    ss,
    rx_byte_available,
    rx_byte,
    tx_read_to_write,
    tx_byte
    );

input wire clk;
input wire sclk;
input wire mosi;
input wire ss;
input wire [0 : 7] tx_byte;

output reg miso;
output reg rx_byte_available;
output reg [0 : 7] rx_byte;
output reg tx_read_to_write;

reg [2 : 0] index;
reg old_ss;
reg old_sclk;

initial begin
    miso = 0;
    rx_byte_available = 0;
    rx_byte = 0;
    tx_read_to_write = 1;
    old_ss = ss;
    old_sclk = sclk;
end

always @ (posedge clk) begin
    if (old_ss == 1) begin
        if (ss == 0) begin
            // reset
            index <= 0;
            tx_read_to_write <= 0;
        end
    end else begin
        if (old_sclk == 0) begin
            // rise edge on sclk
            if (sclk == 1) begin
                // increment index
                index <= index + 1;
                // check if byte is ready
                if (index == 7) begin
                    rx_byte_available <= 1;
                    tx_read_to_write <= 1;
                end else begin
                    rx_byte_available <= 0;
                end
            end
        end else begin
            // fall edge on sclk
            if (sclk == 0) begin
                tx_read_to_write <= 0;
            end
        end
    end

    // update state
    old_ss <= ss;
    old_sclk <= sclk;
end

// read data
always @ (posedge sclk) begin
    rx_byte[index] <= mosi;
end

// write data
always @ (negedge sclk) begin
    miso <= tx_byte[index];
end

endmodule