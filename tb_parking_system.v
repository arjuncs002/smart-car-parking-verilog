`timescale 1ns / 1ps

module tb_parking_system;

  // Inputs
  reg clk;
  reg reset_n;
  reg sensor_entrance;
  reg sensor_exit;
  reg [1:0] password_1;
  reg [1:0] password_2;

  // Outputs
  wire GREEN_LED;
  wire RED_LED;
  wire [6:0] HEX_1;
  wire [6:0] HEX_2;

  // Instantiate the Unit Under Test (UUT)
  parking_system uut (
    .clk(clk),
    .reset_n(reset_n),
    .sensor_entrance(sensor_entrance),
    .sensor_exit(sensor_exit),
    .password_1(password_1),
    .password_2(password_2),
    .GREEN_LED(GREEN_LED),
    .RED_LED(RED_LED),
    .HEX_1(HEX_1),
    .HEX_2(HEX_2)
  );

  // Clock Generation
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  // Stimulus
  initial begin
    // Initialize inputs
    reset_n = 0;
    sensor_entrance = 0;
    sensor_exit = 0;
    password_1 = 2'b00;
    password_2 = 2'b00;
    #50;

    // Release reset
    reset_n = 1;
    #20;

    // Simulate multiple valid entries (20 times to reach max)
    repeat (20) begin
      // Sensor detects car at entrance
      sensor_entrance = 1;
      #20;

      // Wait at WAIT_PASSWORD state
      #40;

      // Correct password
      password_1 = 2'b01;
      password_2 = 2'b10;
      #80;

      // Car enters fully
      sensor_entrance = 1;
      sensor_exit = 0;
      #40;

      // Car passed
      sensor_entrance = 0;
      sensor_exit = 1;
      #40;

      // Reset for next car
      sensor_exit = 0;
      password_1 = 2'b00;
      password_2 = 2'b00;
      #40;
    end

    // Now at max capacity, try one more entry
    sensor_entrance = 1;
    #20;

    // No password should be accepted now
    password_1 = 2'b01;
    password_2 = 2'b10;
    #100;

    // Try removing a car
    sensor_entrance = 0;
    sensor_exit = 1;
    #40;
    sensor_exit = 0;

    // New car enters again after space is freed
    sensor_entrance = 1;
    #20;
    password_1 = 2'b01;
    password_2 = 2'b10;
    #100;
    sensor_entrance = 1;
    sensor_exit = 0;
    #40;
    sensor_entrance = 0;
    sensor_exit = 1;
    #40;
    sensor_exit = 0;

    $stop;
  end

endmodule
