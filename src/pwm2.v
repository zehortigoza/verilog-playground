`define MAIN_CLK_FREQUENCY 25000000
`define USEC_IN_SEC 1000000
`define CYCLES_IN_USEC 16'd25 // MAIN_CLK_FREQUENCY / USEC_IN_SEC

module pwm(
    clk,
    period_usec,
    duty_cycle_usec,
    pin
);

input wire clk;

input wire [15 : 0] period_usec;
input wire [15 : 0] duty_cycle_usec;
output reg pin = 0;

reg [15 : 0] period_count = 0;
reg [15 : 0] duty_cycle_count = 0;

always @ (posedge clk) begin
    if (period_count == 0) begin
        period_count <= period_usec * `CYCLES_IN_USEC;
        duty_cycle_count <= duty_cycle_usec * `CYCLES_IN_USEC;

        if (duty_cycle_usec > 0) begin
            pin <= 1;
        end

        if (duty_cycle_usec == 0) begin
            pin <= 0;
        end
    end

    if (period_count > 0) begin
        period_count <= period_count - 1'b1;
        if (duty_cycle_count == 0) begin
            pin <= 0;
        end

        if (duty_cycle_count > 0) begin
            duty_cycle_count <= duty_cycle_count - 1'b1;
        end
    end
end

endmodule
