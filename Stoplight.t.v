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

module StoplightTest;

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
		$dumpfile("StoplightTest.vcd");
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
		#1; rst = 1; @(posedge clk); // 5 Seconds Elapsed
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
		@(posedge clk); // 35 Seconds Elapsed
		@(posedge clk); // 40 Seconds Elapsed

		//Car Arrives on Prospect at 41 secs
		$display("\nCar arrives on Prospect (Washington -> YELLOW)...");
		#1; car = 1; @(posedge clk); #1; //46 Seconds Elapsed

		`ASSERT_EQ(lw, YLW, "Washington light should be turning to yellow.");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is yellow!");

		$display("\nCar is waiting for the light to turn Green");
		@(posedge clk); #1; car = 0; #1; // Prospect Light Changes from Red to Green, Washington now Red (51 secs)
		
		`ASSERT_EQ(lw, RED, "Washington light is Red when Prosepct is Green!");
		`ASSERT_EQ(lp, GRN, "Prospect light should be green.");

		@(posedge clk); // 55 Seconds Elapsed
		@(posedge clk); // 60 Seconds Elapsed
		@(posedge clk); // 65 Seconds Elapsed 

		$display("\nA stream of cars arrive at Prospect");
		#1; car = 1; #1 // 67 Seconds Elapsed

		// Washington should still be green
		`ASSERT_EQ(lp, GRN, "Prospect light should be green");
		`ASSERT_EQ(lw, RED, "Washington light should be red when Prospect is green!");

		@(posedge clk); // 70 Seconds Elapsed

		$display("\nCars are still at the light");
		#1; // 71 Seconds Elapsed

		`ASSERT_EQ(lp, YLW, "Prospect light should turn yellow");
		`ASSERT_EQ(lw, RED, "Washington light should be red when Prospect is yellow!");

		@(posedge clk); // 75 Seconds Elapsed

		$display("\nCar is trapped on Prospect as the light turns red.");
		#1; // 76 Seconds Elapsed

		`ASSERT_EQ(lw, GRN, "Washington light should turn green");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is green!");

		@(posedge clk); // 80 Seconds Elapsed
		@(posedge clk); // 85 Seconds Elapsed

		$display("\nThe car on Prospect turns right on red.");
		#1; car = 0; #1; // 87 Seconds Elapsed

		`ASSERT_EQ(lw, GRN, "Washington light is still green");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is green!");

		@(posedge clk); // 90 Seconds Elapsed
		@(posedge clk); // 95 Seconds Elapsed
		@(posedge clk); // 100 Seconds Elapsed
		@(posedge clk); // 105 Seconds Elapsed

		$display("\nCar arrives on Prospect.");
		#1; car = 1; #1 // 107 Seconds Elapsed

		`ASSERT_EQ(lw, GRN, "Washington light is still green");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is green!");

		@(posedge clk); // 110 Seconds Elapsed
		@(posedge clk); // 115 Seconds Elapsed

		$display("\nCar on Prospect makes a left turn on Green.");
		#1; car = 0; #1; // 117 Seconds Elapsed

		`ASSERT_EQ(lp, GRN, "Prospect light should have turned green");
		`ASSERT_EQ(lw, RED, "Washington light should be red when Prospect is green!");

		@(posedge clk); // 120 Seconds Elapsed 
		@(posedge clk); // 125 Seconds Elapsed
		@(posedge clk); // 130 Seconds Elapsed

		$display("\nAnother car shows up to the Prospect Light.");
		#1; car = 1; #1; // 132 Seconds Elapsed

		`ASSERT_EQ(lp, GRN, "Prospect light should have turned green");
		`ASSERT_EQ(lw, RED, "Washington light should be red when Prospect is green!");

		@(posedge clk); // 135 Seconds Elapsed

		$display("\nCar on Prospect leaves.");
		#1; car = 0; #1; // 137 Seconds Elapsed

		$display("\nTESTS COMPLETED (%d FAILURES)", errors);
		$finish;
	end

endmodule