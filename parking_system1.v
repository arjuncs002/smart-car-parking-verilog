`timescale 1ns / 1ps
module parking_system( 
    input clk,
    input reset_n,
    input sensor_entrance, 
    input sensor_exit, 
    input [1:0] password_1, 
    input [1:0] password_2,
    output wire GREEN_LED,
    output wire RED_LED,
    output reg [6:0] HEX_1,
    output reg [6:0] HEX_2
);

// States
parameter IDLE = 3'b000, 
          WAIT_PASSWORD = 3'b001, 
          WRONG_PASS = 3'b010, 
          RIGHT_PASS = 3'b011, 
          STOP = 3'b100,
          NO_ENTRY = 3'b101;

reg [2:0] current_state, next_state;
reg [31:0] counter_wait;
reg red_tmp, green_tmp;
reg [4:0] vehicle_count; // Max 31 vehicles

// State Register
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// Counter for password wait
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        counter_wait <= 0;
    else if (current_state == WAIT_PASSWORD)
        counter_wait <= counter_wait + 1;
    else
        counter_wait <= 0;
end

// Vehicle Counter Logic
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        vehicle_count <= 0;
    else begin
        if (current_state == RIGHT_PASS && sensor_entrance && !sensor_exit && vehicle_count < 20)
            vehicle_count <= vehicle_count + 1;
        else if (sensor_exit && vehicle_count > 0)
            vehicle_count <= vehicle_count - 1;
    end
end

// Next State Logic
always @(*)
begin
    case(current_state)
        IDLE: begin
            if (sensor_entrance == 1) begin
                if (vehicle_count < 20)
                    next_state = WAIT_PASSWORD;
                else
                    next_state = NO_ENTRY;
            end else
                next_state = IDLE;
        end

        WAIT_PASSWORD: begin
            if (counter_wait <= 3)
                next_state = WAIT_PASSWORD;
            else if ((password_1 == 2'b01) && (password_2 == 2'b10))
                next_state = RIGHT_PASS;
            else
                next_state = WRONG_PASS;
        end

        WRONG_PASS: begin
            if ((password_1 == 2'b01) && (password_2 == 2'b10))
                next_state = RIGHT_PASS;
            else
                next_state = WRONG_PASS;
        end

        RIGHT_PASS: begin
            if (sensor_entrance && sensor_exit)
                next_state = STOP;
            else if (sensor_exit)
                next_state = IDLE;
            else
                next_state = RIGHT_PASS;
        end

        STOP: begin
            if ((password_1 == 2'b01) && (password_2 == 2'b10))
                next_state = RIGHT_PASS;
            else
                next_state = STOP;
        end

        NO_ENTRY: begin
            if (sensor_exit == 1)
                next_state = IDLE;
            else
                next_state = NO_ENTRY;
        end

        default: next_state = IDLE;
    endcase
end

// Output Logic
always @(posedge clk)
begin
    case(current_state)
        IDLE: begin
            green_tmp = 0;
            red_tmp = 0;
            HEX_1 = 7'b1111111;
            HEX_2 = 7'b1111111;
        end
        WAIT_PASSWORD: begin
            green_tmp = 0;
            red_tmp = 1;
            HEX_1 = 7'b0000110; // E
            HEX_2 = 7'b0101011; // n
        end
        WRONG_PASS: begin
            green_tmp = 0;
            red_tmp = ~red_tmp;
            HEX_1 = 7'b0000110; // E
            HEX_2 = 7'b0000110; // E
        end
        RIGHT_PASS: begin
            green_tmp = ~green_tmp;
            red_tmp = 0;
            HEX_1 = 7'b0000010; // 6
            HEX_2 = 7'b1000000; // 0
        end
        STOP: begin
            green_tmp = 0;
            red_tmp = ~red_tmp;
            HEX_1 = 7'b0010010; // 5
            HEX_2 = 7'b0001100; // P
        end
        NO_ENTRY: begin
            green_tmp = 0;
            red_tmp = 1;
            HEX_1 = 7'b1000000; // 0
            HEX_2 = 7'b0101011; // n
        end
    endcase
end

assign RED_LED = red_tmp;
assign GREEN_LED = green_tmp;

endmodule
