module spi_slave(
    clk,
    sclk,
    miso,
    mosi,
    ss,
    rx_data_available,
    rx_data,
    tx_empty,
    tx_data
    );

input wire clk;
input wire sclk;
input wire mosi;
input wire ss;
input wire [0 : 7] tx_data;

output reg miso;
output reg rx_data_available;
output reg [0 : 7] rx_data;
output reg tx_empty;

reg [2 : 0] index;
reg old_ss;
reg old_sclk;

initial begin
    miso = 0;
    rx_data_available = 0;
    rx_data = 0;
    tx_empty = 0;
    old_ss = ss;
    old_sclk = sclk;
end

always @ (posedge clk) begin
    // slave selected
    if (ss == 0) begin
        // fall edge happen?
        if (old_ss == 1) begin
            // reset
            index <= 0;
            tx_empty <= 1;
        end else begin
            if (sclk == 1) begin
                // rise edge happen?
                if (old_sclk == 0) begin
                    index <= index + 1;
                    // byte read, notify that byte can be read
                    if (index == 7) begin
                        rx_data_available <= 1;
                        tx_empty <= 1;
                    end else begin
                        rx_data_available <= 0;
                    end
                end
            end else begin
                // fall edge happen?
                if (old_sclk == 1) begin
                    tx_empty <= 0;
                end
            end
        end
    end

    // update state
    old_ss <= ss;
    old_sclk <= sclk;
end

always @ (posedge sclk) begin
    rx_data[index] <= mosi;
end

always @ (negedge sclk) begin
    miso <= tx_data[index];
end

endmodule