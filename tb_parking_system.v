`timescale 1ns / 1ps

module tb_parking_system;

  reg clk;
  reg reset_n;
  reg sensor_entrance;
  reg sensor_exit;
  reg [1:0] password_1;
  reg [1:0] password_2;

  wire GREEN_LED;
  wire RED_LED;
  wire [6:0] HEX_1;
  wire [6:0] HEX_2;

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

  initial begin
    clk = 0;
    forever #10 clk = ~clk; // 50MHz
  end

  initial begin
    reset_n = 0;
    sensor_entrance = 0;
    sensor_exit = 0;
    password_1 = 0;
    password_2 = 0;

    #50;
    reset_n = 1;

    // Fill all 20 slots
    repeat (20) begin
      #20 sensor_entrance = 1;
      #20 sensor_entrance = 0;
      password_1 = 2'b01;
      password_2 = 2'b10;
      #100;
      password_1 = 0;
      password_2 = 0;
      #40;
    end

    // Try 21st car ? should go to NO_ENTRY
    sensor_entrance = 1;
    #30 sensor_entrance = 0;
    password_1 = 2'b01;
    password_2 = 2'b10;
    #100;

    // Exit one car
    sensor_exit = 1;
    #30 sensor_exit = 0;
    #30;

    // Re-enter successfully
    sensor_entrance = 1;
    #30 sensor_entrance = 0;
    password_1 = 2'b01;
    password_2 = 2'b10;
    #100;

    $stop;
  end

endmodule
