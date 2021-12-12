//==============================================================================
// Stoplight Testbench Module for Lab 4
//==============================================================================
`timescale 1ns/100ps

`include "Stoplight.v"

`define ASSERT_EQ(ONE, TWO, MSG)               \
	begin                                      \
		if ((ONE) !== (TWO)) begin             \
			$display("\t[FAILURE]:%s", (MSG)); \
			errors = errors + 1;               \
		end                                    \
	end #0

module StoplightTATest;

	// Local Vars
	reg clk = 1;
	reg rst = 0;
	reg car = 0;
	reg [4:0] errors = 0;
	wire [2:0] lp, lw;

	// Light Colors
	localparam GRN = 3'b100;
	localparam YLW = 3'b010;
	localparam RED = 3'b001;

	// VCD Dump
	initial begin
		$dumpfile("StoplightTATest.vcd");
		$dumpvars;
	end

	// Stoplight Module
	Stoplight light(
		.clk        (clk),
		.rst        (rst),
		.car_present(car),
		.light_pros (lp),
		.light_wash (lw)
	);

	// Clock
	always begin
		#2.5 clk = ~clk;
	end

	// Main Test Logic
	initial begin
		// Reset the controller
		$display("\nResetting the Controller (Washington -> GREEN)...");
		#1; rst = 1; @(posedge clk);
		#1; rst = 0; @(posedge clk); // 10 Seconds Elapsed

		// Washington should be green
		`ASSERT_EQ(lw, GRN, "Washington light should be green after reset!");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is green!");

		// Green on Washington
		$display("\nWaiting 25 seconds (Washington -> GREEN)...");
		@(posedge clk); // 15 Seconds Elapsed
		@(posedge clk); // 20 Seconds Elapsed
		@(posedge clk); // 25 Seconds Elapsed
		@(posedge clk); // 30 Seconds Elapsed

		// Washington should still be green
		`ASSERT_EQ(lw, GRN, "Washington light should be green until a car arrives on Prospect!");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is green!");

		// Car arrives on Prospect Avenue
		$display("\nStream of cars arriving on Prospect (Washington -> YELLOW)...");
		#1; car = 1; @(posedge clk); #1;

		// Washington should be yellow
		`ASSERT_EQ(lw, YLW, "Washington light should be yellow now that car has arrived and >=20 seconds have elapsed!");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is yellow!");

		// Wait for light to change
		$display("\nWaiting 5 seconds (Prospect -> GREEN)...");
		@(posedge clk); #1;

		// Prospect should be green
		`ASSERT_EQ(lw, RED, "Washington light should be red while Prospect is green!");
		`ASSERT_EQ(lp, GRN, "Prospect light should be green!");

		// Green on Prospect
		$display("\nWaiting 20 seconds (Prospect -> YELLOW)...");
		@(posedge clk); // 5  seconds elapsed
		@(posedge clk); // 10 seconds elapsed
		@(posedge clk); // 15 seconds elapsed
		@(posedge clk); // 20 seconds elapsed
		#1;

		// Prospect should be yellow
		`ASSERT_EQ(lw, RED, "Washington light should be red while Prospect is yellow!");
		`ASSERT_EQ(lp, YLW, "Prospect light should be yellow (green should last exactly 20 seconds)!");

		// Wait for light to change
		$display("\nWaiting 5 seconds (Washington -> GREEN)...");
		@(posedge clk); #1;

		// Washington should be green
		`ASSERT_EQ(lw, GRN, "Washington light should be green!");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is green!");

		// Washington green for 20 seconds
		$display("\nWaiting 20 seconds, cars still present (Washington -> YELLOW)...");
		@(posedge clk); // 5  seconds elapsed
		@(posedge clk); // 10 seconds elapsed
		@(posedge clk); // 15 seconds elapsed
		@(posedge clk); // 20 seconds elapsed
		#1;

		// Washington should be yellow
		`ASSERT_EQ(lw, YLW, "Washington light should be yellow now that car has arrived and >=20 seconds have elapsed!");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is yellow!");

		$display("\nTESTS COMPLETED (%d FAILURES)", errors);
		$finish;
	end

endmodule
