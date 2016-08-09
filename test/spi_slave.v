module spi_slave_tb;

reg sclk;
reg mosi;
reg ss;

wire miso;


wire rx_data_available;
wire [7:0] rx_data;
wire tx_empty;
reg [7:0] tx_data;

initial begin
    $dumpfile("spi_slave.vcd");
    $dumpvars;

    $monitor ("sclk=%b ss=%b miso=%b mosi=%b rx_data_available=%b tx_empty=%b rx_data=0x%x", sclk, ss, miso, mosi, rx_data_available, tx_empty, rx_data);
    sclk = 0;
    mosi = 0;
    ss = 0;
    tx_data = 0;

    #5 $display("test: power up");
    #0 ss = 1;

    #10 $display("test: selected slave");
    #0 ss = 0;
    #0 $display("test: master assert mosi with bit0");
    #0 mosi = 0;

    #1 $display("test: spi_slave should assert tx_empty");

    #1 $display("test: write value to tx_data");
    #0 tx_data = 13;

    // master and slave read lines bit 0
    #0 sclk = 1;

    #5 $display("test: master assert mosi with bit1");
    #0 sclk = 0;
    #0 mosi = 0;

    // master and slave read lines bit 1
    #5 sclk = 1;

    #5 $display("test: master assert mosi with bit2");
    #0 sclk = 0;
    #0 mosi = 0;

    // master and slave read lines bit 2
    #5 sclk = 1;

    #5 $display("test: master assert mosi with bit3");
    #0 sclk = 0;
    #0 mosi = 0;

    // master and slave read lines bit 3
    #5 sclk = 1;

    #5 $display("test: master assert mosi with bit4");
    #0 sclk = 0;
    #0 mosi = 1;

    // master and slave read lines bit 4
    #5 sclk = 1;

    #5 $display("test: master assert mosi with bit5");
    #0 sclk = 0;
    #0 mosi = 0;

    // master and slave read lines bit 5
    #5 sclk = 1;

    #5 $display("test: master assert mosi with bit6");
    #0 sclk = 0;
    #0 mosi = 1;

    // master and slave read lines bit 6
    #5 sclk = 1;

    #5 $display("test: master assert mosi with bit7");
    #0 sclk = 0;
    #0 mosi = 0;

    // master and slave read lines bit 7
    #5 sclk = 1;

    #5 $display("test: end of sclock");
    #0 sclk = 0;

    #10 $display("test: unselect slave");
    #0 ss = 1;
    
    #5 $finish;
end

spi_slave U0 (
    .sclk(sclk),
    .miso(miso),
    .mosi(mosi),
    .ss(ss),
    .rx_data_available(rx_data_available),
    .rx_data(rx_data),
    .tx_empty(tx_empty),
    .tx_data(tx_data)
);

endmodule