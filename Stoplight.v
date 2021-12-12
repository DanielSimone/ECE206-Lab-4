//==============================================================================
// Stoplight Module for Lab 4
//
// Note on lights:
// 	Each bit represents the on/off signal for a light.
// 	Bit | Light
// 	------------
// 	0   | Red
// 	1   | Yellow
// 	2   | Green
//==============================================================================

module Stoplight(
	input            clk,         // Clock signal
	input            rst,         // Reset signal for FSM
	input            car_present, // Is there a car on Prospect?
	output reg [2:0] light_pros,  // Prospect Avenue Light
	output reg [2:0] light_wash   // Washington Road Light
);

	// Declare Local Vars Here
	reg [3:0] state;
	reg [3:0] next_state;
	// ...

	// Declare State Names Here
	localparam WASH_GREEN_INIT = 4'd0;
	localparam WASH_WAIT_5 = 4'd1;
	localparam WASH_WAIT_10 = 4'd2;
	localparam WASH_WAIT_15 = 4'd3;
	localparam WASH_YELLOW = 4'd4;
	localparam PROS_GREEN = 4'd5;
	localparam PROS_WAIT_5 = 4'd6;
	localparam PROS_WAIT_10 = 4'd7;
	localparam PROS_WAIT_15 = 4'd8;
	localparam PROS_YELLOW = 4'd9;

	// Light Colors
	localparam RED = 3'b001;
	localparam YLW = 3'b010;
	localparam GRN = 3'b100;

	// Output Combinational Logic
	always @( * ) begin
		// Write your output logic here
		light_pros = 3'b000;
		light_wash = 3'b000;
		if (state == WASH_GREEN_INIT || state == WASH_WAIT_5 || state == WASH_WAIT_10 || state == WASH_WAIT_15) begin
			light_pros = RED;
			light_wash = GRN;
		end
		if (state == WASH_YELLOW) begin
			light_pros = RED;
			light_wash = YLW;
		end
		if (state == PROS_GREEN || state == PROS_WAIT_5 || state == PROS_WAIT_10 || state == PROS_WAIT_15) begin
			light_pros = GRN;
			light_wash = RED;
		end
		if (state == PROS_YELLOW) begin
			light_pros = YLW;
			light_wash = RED;
		end
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Write your Next State Logic Here
		if (state == WASH_GREEN_INIT) next_state = WASH_WAIT_5;
		else if (state == WASH_WAIT_5) next_state = WASH_WAIT_10;
		else if (state == WASH_WAIT_10) next_state = WASH_WAIT_15;
		else if (state == WASH_WAIT_15 && ~car_present) next_state = WASH_WAIT_15;
		else if (state == WASH_WAIT_15 && car_present) next_state = WASH_YELLOW;
		else if (state == WASH_YELLOW) next_state = PROS_GREEN;
		else if (state == PROS_GREEN) next_state = PROS_WAIT_5;
		else if (state == PROS_WAIT_5) next_state = PROS_WAIT_10;
		else if (state == PROS_WAIT_10) next_state = PROS_WAIT_15;
		else if (state == PROS_WAIT_15) next_state = PROS_YELLOW;
		else if (state == PROS_YELLOW) next_state = WASH_GREEN_INIT;
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			// Update state to reset state
			state <= WASH_GREEN_INIT;
		end
		else begin
			// Update state to next state
			state <= next_state;
		end
	end

endmodule
