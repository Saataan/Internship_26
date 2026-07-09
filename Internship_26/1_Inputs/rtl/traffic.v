`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: traffic_light_controller
// Description: 4-way traffic light controller with:
//              - Clock divider (100MHz -> 1Hz approx)
//              - Emergency preemption with state resume
//              - Empty lane early skip removed (kept clean)
//////////////////////////////////////////////////////////////////////////////////

module traffic_light_controller(
    input clk,        // Fast input clock (e.g. 100MHz from FPGA)
    input rst,
    
    output reg [2:0] East_road,
    output reg [2:0] North_road,
    output reg [2:0] West_road,
    output reg [2:0] South_road
);

    // -------------------------------------------------------
    // Clock Divider
    // Divides clk_in by DIVISOR to produce clk_out
    // DIVISOR = 100,000,000 → 1Hz from 100MHz
    // For simulation keep DIVISOR small (e.g. 10)
    // -------------------------------------------------------
    reg [27:0] counter = 28'd0;
    reg clk_out;
    parameter DIVISOR = 28'd10; // Change to 28'd100000000 for real hardware

    always @(posedge clk) begin
        counter <= counter + 28'd1;
        if (counter >= (DIVISOR - 1))
            counter <= 28'd0;
        clk_out <= (counter < DIVISOR/2) ? 1'b0 : 1'b1;
    end

    // -------------------------------------------------------
    // FSM Registers
    // -------------------------------------------------------
    reg [2:0] state;
    reg [2:0] return_state;
    
    reg [4:0] count;

    parameter [2:0] east_green   = 3'b000;
    parameter [2:0] east_yellow  = 3'b001;
    parameter [2:0] north_green  = 3'b010;
    parameter [2:0] north_yellow = 3'b011;
    parameter [2:0] west_green   = 3'b100;
    parameter [2:0] west_yellow  = 3'b101;
    parameter [2:0] south_green  = 3'b110;
    parameter [2:0] south_yellow = 3'b111;

    parameter GREEN_COUNT  = 4'b1000; // 19 -> 20 slow cycles
    parameter YELLOW_COUNT = 4'b0011; //  3 ->  4 slow cycles

    // -------------------------------------------------------
    // FSM: runs on divided clock (clk_out)
    // -------------------------------------------------------
    always @(posedge clk_out or negedge rst) begin
        if (!rst) begin
            state        <= east_green;
            return_state <= east_green;
           
            count        <= 5'b00000;
        end

       
        // Normal cycling
        else begin
            case (state)
                east_green: begin
                    if (count == GREEN_COUNT) begin
                        count <= 5'b00000;
                        state <= east_yellow;
                    end else
                        count <= count + 1;
                end
                east_yellow: begin
                    if (count == YELLOW_COUNT) begin
                        count <= 5'b00000;
                        state <= north_green;
                    end else
                        count <= count + 1;
                end
                north_green: begin
                    if (count == GREEN_COUNT) begin
                        count <= 5'b00000;
                        state <= north_yellow;
                    end else
                        count <= count + 1;
                end
                north_yellow: begin
                    if (count == YELLOW_COUNT) begin
                        count <= 5'b00000;
                        state <= west_green;
                    end else
                        count <= count + 1;
                end
                west_green: begin
                    if (count == GREEN_COUNT) begin
                        count <= 5'b00000;
                        state <= west_yellow;
                    end else
                        count <= count + 1;
                end
                west_yellow: begin
                    if (count == YELLOW_COUNT) begin
                        count <= 5'b00000;
                        state <= south_green;
                    end else
                        count <= count + 1;
                end
                south_green: begin
                    if (count == GREEN_COUNT) begin
                        count <= 5'b00000;
                        state <= south_yellow;
                    end else
                        count <= count + 1;
                end
                south_yellow: begin
                    if (count == YELLOW_COUNT) begin
                        count <= 5'b00000;
                        state <= east_green;
                    end else
                        count <= count + 1;
                end
                default: begin
                    count <= 5'b00000;
                    state <= east_green;
                end
            endcase
        end
    end

    // -------------------------------------------------------
    // Output Logic
    // always@(*) fixes the sensitivity list issue
    // -------------------------------------------------------
    always @(*) begin
        if (!rst) begin
            East_road  = 3'b000;
            North_road = 3'b000;
            West_road  = 3'b000;
            South_road = 3'b000;
        end else begin
            case (state)
                east_green: begin
                    East_road  = 3'b001;
                    North_road = 3'b100;
                    West_road  = 3'b100;
                    South_road = 3'b100;
                end
                east_yellow: begin
                    East_road  = 3'b010;
                    North_road = 3'b110;
                    West_road  = 3'b100;
                    South_road = 3'b100;
                end
                north_green: begin
                    East_road  = 3'b100;
                    North_road = 3'b001;
                    West_road  = 3'b100;
                    South_road = 3'b100;
                end
                north_yellow: begin
                    East_road  = 3'b100;
                    North_road = 3'b010;
                    West_road  = 3'b110;
                    South_road = 3'b100;
                end
                west_green: begin
                    East_road  = 3'b100;
                    North_road = 3'b100;
                    West_road  = 3'b001;
                    South_road = 3'b100;
                end
                west_yellow: begin
                    East_road  = 3'b100;
                    North_road = 3'b100;
                    West_road  = 3'b010;
                    South_road = 3'b110;
                end
                south_green: begin
                    East_road  = 3'b100;
                    North_road = 3'b100;
                    West_road  = 3'b100;
                    South_road = 3'b001;
                end
               south_yellow: begin
                    East_road  = 3'b110;
                    North_road = 3'b100; 
                    West_road  = 3'b100;
                    South_road = 3'b010;
                end
                default: begin
                    East_road  = 3'b100;
                    North_road = 3'b100;
                    West_road  = 3'b100;
                    South_road = 3'b100;
                end
            endcase
        end
    end

endmodule
