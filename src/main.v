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

// PWM0
reg [15 : 0] pwm0_freq = 400;
reg [15 : 0] pwm0_duty_cycle_usec = 0;
output wire pwm0_pin;

//state machine data
reg old_spi_rx_byte_available;
reg state_idle;
reg state_duty_cyle;
reg state_write;
reg state_byte1;
reg [3 : 0] pwm_ch;
reg [7 : 0] byte_buffer;

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

// state machine
always @ (posedge clk) begin
    if (ss == 1) begin
        state_idle <= 1;
    end else begin
        if (old_spi_rx_byte_available == 0) begin
            if (spi_rx_byte_available == 1) begin
                // SPI byte available

                if (state_idle == 1) begin
                    pwm_ch <= spi_rx_byte[0 +: 4];
                    state_idle <= 0;
                    state_duty_cyle <= spi_rx_byte[4];
                    state_write <= spi_rx_byte[5];
                    state_byte1 <= 0;
                    
                    //if it is a read operation need to push the first byte now
                    if (spi_rx_byte[5] == 0) begin
                        if (spi_rx_byte[4] == 1) begin
                            spi_tx_byte <= pwm0_duty_cycle_usec[0 +: 8];
                        end else begin
                            spi_tx_byte <= pwm0_freq[0 +: 8];
                        end
                    end
                end // "if (state_idle == 1)"
                
                if (state_idle == 0) begin
                    if (state_byte1 == 0) begin
                        state_byte1 <= 1;

                        if (state_write == 1) begin
                            byte_buffer <= spi_rx_byte;
                        end
                        
                        if (state_write == 0) begin
                            if (state_duty_cyle == 1) begin
                                spi_tx_byte <= pwm0_duty_cycle_usec[8 +: 8];
                            end else begin
                                spi_tx_byte <= pwm0_freq[8 +: 8];
                            end

                            // increment channel counter
                            pwm_ch <= pwm_ch + 1;
                        end
                    end // "if (state_byte1 == 0)"
                    
                    if (state_byte1 == 1) begin
                        state_byte1 <= 0;

                        if (state_write == 1) begin
                            if (state_duty_cyle == 1) begin
                                pwm0_duty_cycle_usec[0 +: 8] <= byte_buffer;
                                pwm0_duty_cycle_usec[8 +: 8] <= spi_rx_byte;
                            end else begin
                                pwm0_freq[0 +: 8] <= byte_buffer;
                                pwm0_freq[8 +: 8] <= spi_rx_byte;
                            end

                            // increment channel counter
                            pwm_ch <= pwm_ch + 1;
                        end

                        if (state_write == 0) begin
                            // start sending the first byte of the next channel
                            if (state_duty_cyle == 1) begin
                                spi_tx_byte <= pwm0_duty_cycle_usec[0 +: 8];
                            end else begin
                                spi_tx_byte <= pwm0_freq[0 +: 8];
                            end
                        end

                    end // "if (state_byte1 == 1)"
                end // "if (state_idle == 0)"

            end // "if (spi_rx_byte_available == 1)"
        end // "if (old_spi_rx_byte_available == 0)"
    end // "if (ss == 1)" else

    old_spi_rx_byte_available <= spi_rx_byte_available;
end // alwasys

endmodule