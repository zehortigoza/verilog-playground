/*
 * It can address up to 16 PWM channels, to add more it necessary add more
 * change the SPI message protocol with host.
 */
`define PWM_CHANNELS 4
`define BYTES_TO_ADDRESS_PWM_CHANNELS 2

module main(
    clk,
    sclk,
    miso,
    mosi,
    ss,
    v_ref,//debug
    pwm0_pin,
    pwm1_pin,
    pwm2_pin,
    pwm3_pin
    );

output reg v_ref;

// SPI data
wire spi_rx_byte_available;
wire [7 : 0] spi_rx_byte;
wire spi_tx_ready_to_write;
reg [7 : 0] spi_tx_byte;
input wire clk;
input wire sclk;
output wire miso;
input wire mosi;
input wire ss;

// pwm channels data
reg [15 : 0] pwm_freq[ 0 : (`PWM_CHANNELS - 1) ];
reg [15 : 0] pwm_duty_cycle[ 0 : (`PWM_CHANNELS - 1) ];
output wire pwm0_pin;
output wire pwm1_pin;
output wire pwm2_pin;
output wire pwm3_pin;

//state machine data
reg old_spi_rx_byte_available;
reg state_idle;
reg state_duty_cyle;
reg state_write;
reg state_byte1;
reg [(`BYTES_TO_ADDRESS_PWM_CHANNELS - 1) : 0] pwm_ch;
reg [7 : 0] byte_buffer;

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
    .freq(pwm_freq[0]),
    .duty_cycle_usec(pwm_duty_cycle[0]),
    .pin(pwm0_pin)
);

pwm pwm1(
    .clk(clk),
    .freq(pwm_freq[1]),
    .duty_cycle_usec(pwm_duty_cycle[1]),
    .pin(pwm1_pin)
);

pwm pwm2(
    .clk(clk),
    .freq(pwm_freq[2]),
    .duty_cycle_usec(pwm_duty_cycle[2]),
    .pin(pwm2_pin)
);

pwm pwm3(
    .clk(clk),
    .freq(pwm_freq[3]),
    .duty_cycle_usec(pwm_duty_cycle[3]),
    .pin(pwm3_pin)
);

initial begin
    v_ref = 1;
end

always @ (posedge clk) begin
    if (ss == 1) begin
        state_idle <= 1;
    end else begin
        if (old_spi_rx_byte_available == 0) begin
            if (spi_rx_byte_available == 1) begin
                // SPI byte available

                if (state_idle == 1) begin
                    pwm_ch <= spi_rx_byte[0 +: `BYTES_TO_ADDRESS_PWM_CHANNELS];
                    state_idle <= 0;
                    state_duty_cyle <= spi_rx_byte[4];
                    state_write <= spi_rx_byte[5];
                    state_byte1 <= 0;

                    // if it is a read operation need to push the first byte now
                    if (spi_rx_byte[5] == 0) begin
                        if (spi_rx_byte[4] == 1) begin
                            spi_tx_byte <= pwm_duty_cycle[spi_rx_byte[0 +: `BYTES_TO_ADDRESS_PWM_CHANNELS]][0 +: 8];
                        end else begin
                            spi_tx_byte <= pwm_freq[spi_rx_byte[0 +: `BYTES_TO_ADDRESS_PWM_CHANNELS]][0 +: 8];
                        end
                    end
                end

                if (state_idle == 0) begin
                    if (state_byte1 == 0) begin
                        state_byte1 <= 1;

                        if (state_write == 1) begin
                            byte_buffer <= spi_rx_byte;
                        end

                        if (state_write == 0) begin
                            if (state_duty_cyle == 1) begin
                                spi_tx_byte <= pwm_duty_cycle[pwm_ch][8 +: 8];
                            end else begin
                                spi_tx_byte <= pwm_freq[pwm_ch][8 +: 8];
                            end

                            // increment channel counter
                            pwm_ch <= pwm_ch + 1;
                        end
                    end

                    if (state_byte1 == 1) begin
                        state_byte1 <= 0;

                        if (state_write == 1) begin
                            if (state_duty_cyle == 1) begin
                                pwm_duty_cycle[pwm_ch][0 +: 8] <= byte_buffer;
                                pwm_duty_cycle[pwm_ch][8 +: 8] <= spi_rx_byte;
                            end else begin
                                pwm_freq[pwm_ch][0 +: 8] <= byte_buffer;
                                pwm_freq[pwm_ch][8 +: 8] <= spi_rx_byte;
                            end

                            // increment channel counter
                            pwm_ch <= pwm_ch + 1;
                        end

                        if (state_write == 0) begin
                            // start sending the first byte of the next channel
                            if (state_duty_cyle == 1) begin
                                spi_tx_byte <= pwm_duty_cycle[pwm_ch][0 +: 8];
                            end else begin
                                spi_tx_byte <= pwm_freq[pwm_ch][0 +: 8];
                            end
                        end

                    end
                end

            end
        end
    end

    old_spi_rx_byte_available <= spi_rx_byte_available;
end

endmodule