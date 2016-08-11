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
reg [15 : 0] pwm0_freq = 490;
reg [15 : 0] pwm0_duty_cycle_usec = 1250;
output wire pwm0_pin;

//state machine data
reg [7 : 0] rx_previous_byte;
reg [3 : 0] pwm_ch;
reg pwm_select_duty_cycle;
reg pwm_write;
typedef enum { IDLE = 0, BYTE0, BYTE1 } state;
reg old_spi_rx_byte_available;

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
        state <= IDLE;
    end else begin
        if (old_spi_rx_byte_available == 0) begin
            if (spi_rx_byte_available == 1) begin
                //data available
                
                case (state)
                    IDLE: begin
                        pwm_ch[0] <= spi_rx_byte[0];
                        pwm_ch[1] <= spi_rx_byte[1];
                        pwm_ch[2] <= spi_rx_byte[2];
                        pwm_ch[3] <= spi_rx_byte[3];
                        //TODO handle channels
                        pwm_select_duty_cycle <= spi_rx_byte[4];
                        pwm_write <= spi_rx_byte[5];
                        //TODO handle read
                        state <= BYTE0;
                    end
                    BYTE0: begin
                        led0_pin <= !spi_rx_byte[0];
                        led1_pin <= !spi_rx_byte[1];
                        led2_pin <= !spi_rx_byte[2];
                        led3_pin <= !spi_rx_byte[3];
                        state <= BYTE1;
                    end
                    BYTE1: begin
                        pwm0_duty_cycle_usec[0] <= rx_previous_byte[0];
                        pwm0_duty_cycle_usec[1] <= rx_previous_byte[1];
                        pwm0_duty_cycle_usec[2] <= rx_previous_byte[2];
                        pwm0_duty_cycle_usec[3] <= rx_previous_byte[3];
                        pwm0_duty_cycle_usec[4] <= rx_previous_byte[4];
                        pwm0_duty_cycle_usec[5] <= rx_previous_byte[5];
                        pwm0_duty_cycle_usec[6] <= rx_previous_byte[6];
                        pwm0_duty_cycle_usec[7] <= rx_previous_byte[7];
                        pwm0_duty_cycle_usec[8] <= spi_rx_byte[0];
                        pwm0_duty_cycle_usec[9] <= spi_rx_byte[1];
                        pwm0_duty_cycle_usec[10] <= spi_rx_byte[2];
                        pwm0_duty_cycle_usec[11] <= spi_rx_byte[3];
                        pwm0_duty_cycle_usec[12] <= spi_rx_byte[4];
                        pwm0_duty_cycle_usec[13] <= spi_rx_byte[5];
                        pwm0_duty_cycle_usec[14] <= spi_rx_byte[6];
                        pwm0_duty_cycle_usec[15] <= spi_rx_byte[7];
                        state <= BYTE0;
                        pwm_ch <= pwm_ch + 1;
                    end
                endcase
                
                rx_previous_byte <= spi_rx_byte;
            end
        end
    end

    old_spi_rx_byte_available <= spi_rx_byte_available;
end

always @ (posedge spi_tx_ready_to_write) begin
    spi_tx_byte <= spi_rx_byte + 1;
end

endmodule