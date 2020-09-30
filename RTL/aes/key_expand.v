`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:35:55 09/30/2020 
// Design Name: 
// Module Name:    key_expand 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: key expansion module
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module key_expand(
	clk,
	ld,
	key,
	w0,
	w1,
	w2,
	w3
    );
	 input   clk;
	 input   ld;
	 input [127:0] key;
	 output[31:0] w0,w1,w2,w3;
	 reg[31:0]  w[3:0];
	 wire [31:0] temp_w;
	 wire[31:0] subword;
	 wire[31:0] rcon;
	 
	 assign w0 = w[0];
	 assign w1 = w[1];
	 assign w2 = w[2];
    assign w3 = w[3];
	 always @(posedge clk)	w[0] <= #1 ld ? key[127:096] : w[0]^subword^rcon;
	 always @(posedge clk)	w[1] <= #1 ld ? key[095:064] : w[0]^w[1]^subword^rcon;
	 always @(posedge clk)	w[2] <= #1 ld ? key[063:032] : w[0]^w[2]^w[1]^subword^rcon;
	 always @(posedge clk)	w[3] <= #1 ld ? key[031:000] : w[0]^w[3]^w[2]^w[1]^subword^rcon;
	 assign temp_w =w[3];
	 
	 sbox u0(temp_w[23:16],subword[31:24]);
	 sbox u1(temp_w[15:08],subword[23:16]);
	 sbox u2(temp_w[7:0],subword[15:08]);
	 sbox u3(temp_w[31:24],subword[7:0]);
	 aes_rcon r0(clk,ld,rcon);
	 
	 
	 
	 
	 

endmodule
