//==============================================================================
// Stoplight Testbench Module for Lab 4
//==============================================================================
`timescale 1ns/100ps

`include "Stoplight.v"

`define ASSERT_EQ(ONE, TWO, MSG)               \
	begin                                      \
		if ((ONE) !== (TWO)) begin             \
			$display("\t[FAILURE]:%s", (MSG)); \
			//errors = errors + 1;               \              
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
		$display("\nResetting the Controller (Washington -> GREEN)...");
		#1; rst = 1; @(posedge clk);
		#1; rst = 0; @(posedge clk); // 10 Seconds Elapsed

		// Washington should still be green
		`ASSERT_EQ(lw, GRN, "Washington light should be green until a car arrives on Prospect!");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is green!");

		@(posedge clk); // 15 Seconds Elapsed
		@(posedge clk); // 20 Seconds Elapsed
		@(posedge clk); // 25 Seconds Elapsed
		@(posedge clk); // 30 Seconds Elapsed

		@(posedge clk); // 35 Seconds Elapsed
		@(posedge clk); // 40 Seconds Elapsed

		//Car Arrives on Prospect at 41 secs
		$display("\nCar arrives on Prospect Avenue");
		#1; car = 1; @(posedge clk); #1;
		//46 secs elapsed

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
		#1; car = 1; #1; // 67 seconds elapsed

		// Washington should still be green
		`ASSERT_EQ(lp, GRN, "Prospect light should be green");
		`ASSERT_EQ(lw, RED, "Washington light should be red when Prospect is green!");

		@(posedge clk); // 70 seconds elapsed

		$display("\nCars are still at the light");
		#2; // 72 seconds elapsed

		`ASSERT_EQ(lp, YLW, "Prospect light should turn yellow");
		`ASSERT_EQ(lw, RED, "Washington light should be red when Prospect is yellow!");

		@(posedge clk); // 75 seconds elapsed

		$display("\nCar is trapped on Prospect as the light turns red.");
		#2; // 77 seconds elapsed

		`ASSERT_EQ(lw, GRN, "Washington light should turn green");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is green!");

		@(posedge clk); // 80 seconds elapsed 
		@(posedge clk); // 85 seconds elapsed 

		$display("\nThe car on Prospect turns right on red.");
		#1; car = 0; #1; // 87 seconds have elsapsed

		`ASSERT_EQ(lw, GRN, "Washington light is still green");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is green!");

		@(posedge clk); // 90 seconds elapsed 
		@(posedge clk); // 95 seconds elapsed 
		@(posedge clk); // 100 seconds elapsed 
		@(posedge clk); // 105 seconds elapsed 

		$display("\nCar arrives on Prospect.");
		#1; car = 1; #1 // 107 seconds elapsed 

		
		`ASSERT_EQ(lw, GRN, "Washington light is still green");
		`ASSERT_EQ(lp, RED, "Prospect light should be red when Washington is green!");

		@(posedge clk); // 110 seconds elapsed
		@(posedge clk); // 115 seconds elapsed

		$display("\nCar on Prospect makes a left turn on Green.");
		#1; car = 0; #1; // 117 seconds elapsed

		`ASSERT_EQ(lp, GRN, "Prospect light should have turned green");
		`ASSERT_EQ(lw, RED, "Washington light should be red when Prospect is green!");

		@(posedge clk); // 120 seconds elapsed 
		@(posedge clk); // 125 seconds elapsed
		@(posedge clk); // 130 seconds elapsed

		$display("\nAnother car shows up to the Prospect Light.");
		#1; car = 1; #1; // 132 seconds elapsed

		`ASSERT_EQ(lp, GRN, "Prospect light should have turned green");
		`ASSERT_EQ(lw, RED, "Washington light should be red when Prospect is green!");

		@(posedge clk); // 135 seconds elapsed

		$display("\nCar on Prospect leaves.");
		#1; car = 0; #1; // 137 seconds elapsed


		$finish;
	end

endmodule