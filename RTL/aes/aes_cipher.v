`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:34:11 09/30/2020 
// Design Name: 
// Module Name:    aes_cipher 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: aes encryption main module
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module aes_cipher(clk, rst, ld, done, key, text_in, text_out );
input		clk, rst;
input		ld;
output		done;
input	[127:0]	key;
input	[127:0]	text_in;
output	[127:0]	text_out;


wire	[31:0]	w0, w1, w2, w3;
reg	[127:0]	text_in_r;
reg	[127:0]	text_out;
//temp for key expand
reg	[7:0]	sa00, sa01, sa02, sa03;
reg	[7:0]	sa10, sa11, sa12, sa13;
reg	[7:0]	sa20, sa21, sa22, sa23;
reg	[7:0]	sa30, sa31, sa32, sa33;
//temp for add round key
wire	[7:0]	sa00_next, sa01_next, sa02_next, sa03_next;
wire	[7:0]	sa10_next, sa11_next, sa12_next, sa13_next;
wire	[7:0]	sa20_next, sa21_next, sa22_next, sa23_next;
wire	[7:0]	sa30_next, sa31_next, sa32_next, sa33_next;
//temp for subbytes
wire	[7:0]	sa00_sub, sa01_sub, sa02_sub, sa03_sub;
wire	[7:0]	sa10_sub, sa11_sub, sa12_sub, sa13_sub;
wire	[7:0]	sa20_sub, sa21_sub, sa22_sub, sa23_sub;
wire	[7:0]	sa30_sub, sa31_sub, sa32_sub, sa33_sub;
//temp for shift rows
wire	[7:0]	sa00_sr, sa01_sr, sa02_sr, sa03_sr;
wire	[7:0]	sa10_sr, sa11_sr, sa12_sr, sa13_sr;
wire	[7:0]	sa20_sr, sa21_sr, sa22_sr, sa23_sr;
wire	[7:0]	sa30_sr, sa31_sr, sa32_sr, sa33_sr;
//temp for mix column
wire	[7:0]	sa00_mc, sa01_mc, sa02_mc, sa03_mc;
wire	[7:0]	sa10_mc, sa11_mc, sa12_mc, sa13_mc;
wire	[7:0]	sa20_mc, sa21_mc, sa22_mc, sa23_mc;
wire	[7:0]	sa30_mc, sa31_mc, sa32_mc, sa33_mc;
wire	[31:0] mix_temp0,mix_temp1,mix_temp2,mix_temp3;
reg		done, ld_r;
reg	[3:0]	dcnt;

//logic for round looping
always @(posedge clk)
	if(!rst)	dcnt <= #1 4'h0;
	else
	if(ld)		dcnt <= #1 4'hb;
	else
	if(|dcnt)	dcnt <= #1 dcnt - 4'h1;

always @(posedge clk) done <= #1 !(|dcnt[3:1]) & dcnt[0] & !ld;
always @(posedge clk) if(ld) text_in_r <= #1 text_in;
always @(posedge clk) ld_r <= #1 ld;

//add key expansion
key_expand u0(clk,ld,key,w0,w1,w2,w3);

//subbytes
sbox us00(sa00,sa00_sub);
sbox us01(sa01,sa01_sub);
sbox us02(sa02,sa02_sub);
sbox us03(sa03,sa03_sub);
sbox us10(sa10,sa10_sub);
sbox us11(sa11,sa11_sub);
sbox us12(sa12,sa12_sub);
sbox us13(sa13,sa13_sub);
sbox us20(sa20,sa20_sub);
sbox us21(sa21,sa21_sub);
sbox us22(sa22,sa22_sub);
sbox us23(sa23,sa23_sub);
sbox us30(sa30,sa30_sub);
sbox us31(sa31,sa31_sub);
sbox us32(sa32,sa32_sub);
sbox us33(sa33,sa33_sub);

//add round key
always @(posedge clk)	sa33 <= #1 ld_r ? text_in_r[007:000] ^ w3[07:00] : sa33_next;
always @(posedge clk)	sa23 <= #1 ld_r ? text_in_r[015:008] ^ w3[15:08] : sa23_next;
always @(posedge clk)	sa13 <= #1 ld_r ? text_in_r[023:016] ^ w3[23:16] : sa13_next;
always @(posedge clk)	sa03 <= #1 ld_r ? text_in_r[031:024] ^ w3[31:24] : sa03_next;
always @(posedge clk)	sa32 <= #1 ld_r ? text_in_r[039:032] ^ w2[07:00] : sa32_next;
always @(posedge clk)	sa22 <= #1 ld_r ? text_in_r[047:040] ^ w2[15:08] : sa22_next;
always @(posedge clk)	sa12 <= #1 ld_r ? text_in_r[055:048] ^ w2[23:16] : sa12_next;
always @(posedge clk)	sa02 <= #1 ld_r ? text_in_r[063:056] ^ w2[31:24] : sa02_next;
always @(posedge clk)	sa31 <= #1 ld_r ? text_in_r[071:064] ^ w1[07:00] : sa31_next;
always @(posedge clk)	sa21 <= #1 ld_r ? text_in_r[079:072] ^ w1[15:08] : sa21_next;
always @(posedge clk)	sa11 <= #1 ld_r ? text_in_r[087:080] ^ w1[23:16] : sa11_next;
always @(posedge clk)	sa01 <= #1 ld_r ? text_in_r[095:088] ^ w1[31:24] : sa01_next;
always @(posedge clk)	sa30 <= #1 ld_r ? text_in_r[103:096] ^ w0[07:00] : sa30_next;
always @(posedge clk)	sa20 <= #1 ld_r ? text_in_r[111:104] ^ w0[15:08] : sa20_next;
always @(posedge clk)	sa10 <= #1 ld_r ? text_in_r[119:112] ^ w0[23:16] : sa10_next;
always @(posedge clk)	sa00 <= #1 ld_r ? text_in_r[127:120] ^ w0[31:24] : sa00_next;

//shiftrows
assign sa00_sr = sa00_sub;
assign sa01_sr = sa01_sub;
assign sa02_sr = sa02_sub;
assign sa03_sr = sa03_sub;
assign sa10_sr = sa11_sub;
assign sa11_sr = sa12_sub;
assign sa12_sr = sa13_sub;
assign sa13_sr = sa10_sub;
assign sa20_sr = sa22_sub;
assign sa21_sr = sa23_sub;
assign sa22_sr = sa20_sub;
assign sa23_sr = sa21_sub;
assign sa30_sr = sa33_sub;
assign sa31_sr = sa30_sub;
assign sa32_sr = sa31_sub;
assign sa33_sr = sa32_sub;
//mix column
mix_col m0(sa00_sr,sa10_sr,sa20_sr,sa30_sr,mix_temp0);
mix_col m1(sa01_sr,sa11_sr,sa21_sr,sa31_sr,mix_temp1);
mix_col m2(sa02_sr,sa12_sr,sa22_sr,sa32_sr,mix_temp2);
mix_col m3(sa03_sr,sa13_sr,sa23_sr,sa33_sr,mix_temp3);
assign {sa00_mc, sa10_mc, sa20_mc, sa30_mc}  = mix_temp0;
assign {sa01_mc, sa11_mc, sa21_mc, sa31_mc}  = mix_temp1;
assign {sa02_mc, sa12_mc, sa22_mc, sa32_mc}  = mix_temp2;
assign {sa03_mc, sa13_mc, sa23_mc, sa33_mc}  = mix_temp3;

//running CBC mode of operation 
assign sa00_next = sa00_mc ^ w0[31:24];
assign sa01_next = sa01_mc ^ w1[31:24];
assign sa02_next = sa02_mc ^ w2[31:24];
assign sa03_next = sa03_mc ^ w3[31:24];
assign sa10_next = sa10_mc ^ w0[23:16];
assign sa11_next = sa11_mc ^ w1[23:16];
assign sa12_next = sa12_mc ^ w2[23:16];
assign sa13_next = sa13_mc ^ w3[23:16];
assign sa20_next = sa20_mc ^ w0[15:08];
assign sa21_next = sa21_mc ^ w1[15:08];
assign sa22_next = sa22_mc ^ w2[15:08];
assign sa23_next = sa23_mc ^ w3[15:08];
assign sa30_next = sa30_mc ^ w0[07:00];
assign sa31_next = sa31_mc ^ w1[07:00];
assign sa32_next = sa32_mc ^ w2[07:00];
assign sa33_next = sa33_mc ^ w3[07:00];

// text out
always @(posedge clk) text_out[127:120] <= #1 sa00_sr ^ w0[31:24];
always @(posedge clk) text_out[095:088] <= #1 sa01_sr ^ w1[31:24];
always @(posedge clk) text_out[063:056] <= #1 sa02_sr ^ w2[31:24];
always @(posedge clk) text_out[031:024] <= #1 sa03_sr ^ w3[31:24];
always @(posedge clk) text_out[119:112] <= #1 sa10_sr ^ w0[23:16];
always @(posedge clk) text_out[087:080] <= #1 sa11_sr ^ w1[23:16];
always @(posedge clk) text_out[055:048] <= #1 sa12_sr ^ w2[23:16];
always @(posedge clk) text_out[023:016] <= #1 sa13_sr ^ w3[23:16];
always @(posedge clk) text_out[111:104] <= #1 sa20_sr ^ w0[15:08];
always @(posedge clk) text_out[079:072] <= #1 sa21_sr ^ w1[15:08];
always @(posedge clk) text_out[047:040] <= #1 sa22_sr ^ w2[15:08];
always @(posedge clk) text_out[015:008] <= #1 sa23_sr ^ w3[15:08];
always @(posedge clk) text_out[103:096] <= #1 sa30_sr ^ w0[07:00];
always @(posedge clk) text_out[071:064] <= #1 sa31_sr ^ w1[07:00];
always @(posedge clk) text_out[039:032] <= #1 sa32_sr ^ w2[07:00];
always @(posedge clk) text_out[007:000] <= #1 sa33_sr ^ w3[07:00];


endmodule


