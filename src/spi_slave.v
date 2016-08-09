module spi_slave(
    sclk,
    miso,
    mosi,
    ss,
    rx_data_available,
    rx_data,
    tx_empty,
    tx_data
    );

input wire sclk;
input wire mosi;
input wire ss;
input wire [0:7] tx_data;

output reg miso;
output reg rx_data_available;
output reg [0:7] rx_data;
output reg tx_empty = 0;

//state = 8 = idle
//state = [1-7] = reading/writing bits
reg [3 : 0] state;

always @ (negedge ss) begin
    $display("spi_slave: slave selected");
    state <= 0;
    tx_empty <= 1;
end

always @ (posedge ss) begin
    $display("spi_slave: slave unselected");
    state <= 8;
    tx_empty <= 0;
end

// receive data
always @ (posedge sclk) begin
    if (state != 8) begin
        $display("spi_slave: rise edge state=%x", state);
        rx_data[state] <= mosi;
        if (state == 7) begin
            rx_data_available <= 1;
            state <= 0;
        end else begin
            rx_data_available <= 0;
            state <= state + 1;
        end
    end
end

// transmit data
always @ (posedge sclk) begin
    if (state != 8) begin
        $display("spi_slave: fall edge state=%x tx_data[state]=%b", state, tx_data[state]);
        miso <= tx_data[state];
        if (state == 7) begin
            tx_empty <= 1;
        end else begin
            tx_empty <= 0;
        end
    end
end

endmodule