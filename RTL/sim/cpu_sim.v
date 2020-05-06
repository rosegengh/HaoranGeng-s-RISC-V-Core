`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:41:05 04/29/2020
// Design Name:   cpu_top_level
// Module Name:   C:/Users/roseg/Desktop/RISCV/Gengs-RISC-V/cpu_sim.v
// Project Name:  Gengs-RISC-V
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu_top_level
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////  
module cpu_sim;

	// Inputs
	reg clk = 0;
	reg res = 1;

	// Outputs
	wire [3:0] LED;
	wire [3:0] DEBUG;
   initial while(1) #(500e6/100000000) clk = !clk;
	// Instantiate the Unit Under Test (UUT)
	cpu_top_level uut (
		.clk(clk), 
		.res(res), 
		.LED(LED), 
		.DEBUG(DEBUG)
	);

	initial begin
		// Initialize Inputs
		
		#1e3    res = 0;

		// Wait 100 ns for global reset to finish
		#100000000e3 $finish();          // run  1ms
        
		// Add stimulus here

	end
      
endmodule

