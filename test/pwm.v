module pwm_tb;

reg clk = 0;
reg [15 : 0] freq = 400;
reg [15 : 0] duty_cycle_usec = 0;
wire pin;

initial begin
    $dumpfile("pwm.vcd");
    $dumpvars;
    //$monitor ("freq=0x%x duty_cycle=0x%x pin=%b", freq, duty_cycle_usec, pin);

    #100 duty_cycle_usec = 1000;

    #1000000 $finish;
end

always
    #1 clk = !clk;

pwm U0 (
    .clk(clk),
    .freq(freq),
    .duty_cycle_usec(duty_cycle_usec),
    .pin(pin)
);

endmodule