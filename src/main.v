module main(
    clk,
    sclk,
    miso,
    mosi,
    ss,
    led0_pin,
    led1_pin,
    led2_pin,
    led3_pin,
    led4_pin,
    v_ref,
    pwm0_pin
    );

input wire clk;
input wire sclk;
output wire miso;
input wire mosi;
input wire ss;

output reg v_ref;

// SPI
wire spi_rx_byte_available;
wire [7 : 0] spi_rx_byte;
wire spi_tx_ready_to_write;
reg [7 : 0] spi_tx_byte;

reg [7 : 0] spi_rx_buffer[0 : 3];
reg [1 : 0] spi_rx_buffer_index;
reg old_spi_rx_byte_available;

// PWM0
reg [15 : 0] pwm0_freq = 490;
reg [15 : 0] pwm0_duty_cycle_usec = 1250;
output wire pwm0_pin;

//debug
output reg led0_pin = 1;
output reg led1_pin = 1;
output reg led2_pin = 1;
output reg led3_pin = 1;
output reg led4_pin;

spi_slave spi0(
    .clk(clk),
    .sclk(sclk),
    .miso(miso),
    .mosi(mosi),
    .ss(ss),
    .rx_byte_available(spi_rx_byte_available),
    .rx_byte(spi_rx_byte),
    .tx_read_to_write(spi_tx_ready_to_write),
    .tx_byte(spi_tx_byte)
);

pwm pwm0(
    .clk(clk),
    .freq(pwm0_freq),
    .duty_cycle_usec(pwm0_duty_cycle_usec),
    .pin(pwm0_pin)
);

initial begin
    v_ref = 1;
end

always @ (posedge clk) begin
    led4_pin <= (!spi_rx_byte_available);
    
    if (ss == 1) begin
        spi_rx_buffer_index <= 0;
    end else begin
        if (old_spi_rx_byte_available == 0) begin
            if (spi_rx_byte_available == 1) begin
                //data available
                spi_rx_buffer[spi_rx_buffer_index] <= spi_rx_byte;
                spi_rx_buffer_index <= spi_rx_buffer_index + 1;
                
                if (spi_rx_buffer_index == 1) begin
                    pwm0_duty_cycle_usec[0] <= spi_rx_buffer[0][0];
                    pwm0_duty_cycle_usec[1] <= spi_rx_buffer[0][1];
                    pwm0_duty_cycle_usec[2] <= spi_rx_buffer[0][2];
                    pwm0_duty_cycle_usec[3] <= spi_rx_buffer[0][3];
                    pwm0_duty_cycle_usec[4] <= spi_rx_buffer[0][4];
                    pwm0_duty_cycle_usec[5] <= spi_rx_buffer[0][5];
                    pwm0_duty_cycle_usec[6] <= spi_rx_buffer[0][6];
                    pwm0_duty_cycle_usec[7] <= spi_rx_buffer[0][7];
                    pwm0_duty_cycle_usec[8] <= spi_rx_byte[0];
                    pwm0_duty_cycle_usec[9] <= spi_rx_byte[1];
                    pwm0_duty_cycle_usec[10] <= spi_rx_byte[2];
                    pwm0_duty_cycle_usec[11] <= spi_rx_byte[3];
                    pwm0_duty_cycle_usec[12] <= spi_rx_byte[4];
                    pwm0_duty_cycle_usec[13] <= spi_rx_byte[5];
                    pwm0_duty_cycle_usec[14] <= spi_rx_byte[6];
                    pwm0_duty_cycle_usec[15] <= spi_rx_byte[7];
                end

                if (spi_rx_buffer_index == 0) begin
                    led0_pin <= (!spi_rx_byte[0]);
                    led1_pin <= (!spi_rx_byte[1]);
                    led2_pin <= (!spi_rx_byte[2]);
                    led3_pin <= (!spi_rx_byte[3]);
                end
            end
        end
    end
    
    old_spi_rx_byte_available <= spi_rx_byte_available;
end

always @ (posedge spi_tx_ready_to_write) begin
    spi_tx_byte <= spi_rx_byte + 1;
end

endmodule