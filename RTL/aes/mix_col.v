`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:37:03 09/30/2020 
// Design Name: 
// Module Name:    mix_col 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: mix column module
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mix_col(
	s0,
	s1,
	s2,
	s3,
	out
    );
	 input[7:0] s0,s1,s2,s3;
	 output[31:0] out;
	 wire[7:0] temp0,temp1,temp2,temp3;
	 assign temp0 = {s0[6:0],1'b0} ^ (8'h1b&{8{s0[7]}});
	 assign temp1 = {s1[6:0],1'b0} ^ (8'h1b&{8{s1[7]}});
	 assign temp2 = {s2[6:0],1'b0} ^ (8'h1b&{8{s2[7]}});
	 assign temp3 = {s3[6:0],1'b0} ^ (8'h1b&{8{s3[7]}});
	 
	 assign out[31:24] = temp0 ^ temp1 ^ s1 ^ s2 ^ s3;
	 assign out[23:16] = s0 ^ temp1  ^ temp2 ^ s2^s3;
	 assign out[15:08] = s0^s1 ^ temp2 ^ temp3 ^ s3;
	 assign out[7:0] = temp0 ^ s0 ^ s1 ^ s2 ^ temp3;
	 

endmodule
