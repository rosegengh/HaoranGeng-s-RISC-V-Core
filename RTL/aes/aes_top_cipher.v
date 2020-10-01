`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:32:50 09/30/2020 
// Design Name: 
// Module Name:    aes_top_cipher 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: aes encryption top level wrap up module
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module aes_top(
	clk,
	rst,
	kld,
	text_out,
	done
	);
	input clk;
	input rst;
	input kld;
	wire	[383:0] tv = 384'h3243f6a8885a308d313198a2e03707342b7e151628aed2a6abf7158809cf4f3cd54e7519474ddb7ff5ee711cbab18dee;
	output[127:0] text_out;
	wire[127:0] key,text_in,plain,ciph,text_in2,text_out1;
	output done;
	wire done1;
	assign key = tv[383:256];
	assign text_in = tv[255:128];
	assign text_in2 = tv[127:0];
	assign plain   = tv[255:128];
	
	assign ciph    = tv[127:0];
	
	aes_cipher aes_c(clk,rst,kld,done1,key,text_in,text_out1);
	aes_decipher aes_dc(clk,rst,kld,done1,done,key,text_in2,text_out);


endmodule
