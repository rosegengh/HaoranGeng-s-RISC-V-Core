`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:37:52 09/30/2020
// Design Name:   aes_top_cipher
// Module Name:   C:/Users/roseg/OneDrive/Desktop/RISCV/Gengs-RISC-V/aes_cipher_sim.v
// Project Name:  Gengs-RISC-V
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: aes_top_cipher
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module aes_cipher_sim;

	reg clk;
	reg rst;
	reg kld;

	// Outputs
	wire [127:0] text_out;
	wire done;

	// Instantiate the Unit Under Test (UUT)

initial begin
		clk = 0;
		rst = 0;
		kld = 0;
		repeat(4)	@(posedge clk);
		rst = 1;
		repeat(20)	@(posedge clk);
		@(posedge clk);
		#1;
		kld = 1;
		@(posedge clk);
		#1;
		kld = 0;
		@(posedge clk);

		while(!done)	@(posedge clk);

end
always #5 clk = ~clk;
aes_top_cipher uut (
		.clk(clk), 
		.rst(rst), 
		.kld(kld), 
		.text_out(text_out),
		.done(done)
);
      
endmodule


