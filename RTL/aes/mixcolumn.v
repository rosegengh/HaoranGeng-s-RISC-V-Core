`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:26:48 09/24/2020 
// Design Name: 
// Module Name:    mixcolumn 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mixcolumn(
	state,
	dout
    );
	input [1:128] state;
   output[1:128]  dout;
   wire [1:128] p;
	reg [1:8] mem[0:255];
	initial
	begin
	mem[0]=8'h0;
	mem[1]=8'h2;
	mem[2]=8'h4;
	mem[3]=8'h6;
	mem[4]=8'h8;
	mem[5]=8'hA;
	mem[6]=8'hC;
	mem[7]=8'hE;
	mem[8]=8'h10;
	mem[9]=8'h12;
	mem[10]=8'h14;
	mem[11]=8'h16;
	mem[12]=8'h18;
	mem[13]=8'h1A;
	mem[13]=8'h1A;
	men[14]=8'h1C;
	men[15]=8'h1E;
	men[16]=8'h20;
	men[17]=8'h22;
	men[18]=8'h24;
	men[19]=8'h26;
	men[20]=8'h28;
	men[21]=8'h2A;
	men[22]=8'h2C;
	men[23]=8'h2E;
	men[24]=8'h30;
	men[25]=8'h32;
	men[26]=8'h34;
	men[27]=8'h36;
	men[28]=8'h38;
	men[29]=8'h3A;
	men[30]=8'h3C;
	men[31]=8'h3E;
	men[32]=8'h40;
	men[33]=8'h42;
	men[34]=8'h44;
	men[35]=8'h46;
	men[36]=8'h48;
	men[37]=8'h4A;
	men[38]=8'h4C;
	men[39]=8'h4E;
	men[40]=8'h50;
	men[41]=8'h52;
	men[42]=8'h54;
	men[43]=8'h56;
	men[44]=8'h58;
	men[45]=8'h5A;
	men[46]=8'h5C;
	men[47]=8'h5E;
	men[48]=8'h60;
	men[49]=8'h62;
	men[50]=8'h64;
	men[51]=8'h66;
	men[52]=8'h68;
	men[53]=8'h6A;
	men[54]=8'h6C;
	men[55]=8'h6E;
	men[56]=8'h70;
	men[57]=8'h72;
	men[58]=8'h74;
	men[59]=8'h76;
	men[60]=8'h78;
	men[61]=8'h7A;
	men[62]=8'h7C;
	men[63]=8'h7E;
	men[64]=8'h80;
	men[65]=8'h82;
	men[66]=8'h84;
	men[67]=8'h86;
	men[68]=8'h88;
	men[69]=8'h8A;
	men[70]=8'h8C;
	men[71]=8'h8E;
	men[72]=8'h90;
	men[73]=8'h92;
	men[74]=8'h94;
	men[75]=8'h96;
	men[76]=8'h98;
	men[77]=8'h9A;
	men[78]=8'h9C;
	men[79]=8'h9E;
	men[80]=8'hA0;
	men[81]=8'hA2;
	men[82]=8'hA4;
	men[83]=8'hA6;
	men[84]=8'hA8;
	men[85]=8'hAA;
	men[86]=8'hAC;
	men[87]=8'hAE;
	men[88]=8'hB0;
	men[89]=8'hB2;
	men[90]=8'hB4;
	men[91]=8'hB6;
	men[92]=8'hB8;
	men[93]=8'hBA;
	men[94]=8'hBC;
	men[95]=8'hBE;
	men[96]=8'hC0;
	men[97]=8'hC2;
	men[98]=8'hC4;
	men[99]=8'hC6;
	men[100]=8'hC8;
	men[101]=8'hCA;
	men[102]=8'hCC;
	men[103]=8'hCE;
	men[104]=8'hD0;
	men[105]=8'hD2;
	men[106]=8'hD4;
	men[107]=8'hD6;
	men[108]=8'hD8;
	men[109]=8'hDA;
	men[110]=8'hDC;
	men[111]=8'hDE;
	men[112]=8'hE0;
	men[113]=8'hE2;
	men[114]=8'hE4;
	men[115]=8'hE6;
	men[116]=8'hE8;
	men[117]=8'hEA;
	men[118]=8'hEC;
	men[119]=8'hEE;
	men[120]=8'hF0;
	men[121]=8'hF2;
	men[122]=8'hF4;
	men[123]=8'hF6;
	men[124]=8'hF8;
	men[125]=8'hFA;
	men[126]=8'hFC;
	men[127]=8'hFE;
	men[128]=8'h1B;
	men[129]=8'h19;
	men[130]=8'h1F;
	men[131]=8'h1D;
	men[132]=8'h13;
	men[133]=8'h11;
	men[134]=8'h17;
	men[135]=8'h15;
	men[136]=8'hB;
	men[137]=8'h9;
	men[138]=8'hF;
	men[139]=8'hD;
	men[140]=8'h3;
	men[141]=8'h1;
	men[142]=8'h7;
	men[143]=8'h5;
	men[144]=8'h3B;
	men[145]=8'h39;
	men[146]=8'h3F;
	men[147]=8'h3D;
	men[148]=8'h33;
	men[149]=8'h31;
	men[150]=8'h37;
	men[151]=8'h35;
	men[152]=8'h2B;
	men[153]=8'h29;
	men[154]=8'h2F;
	men[155]=8'h2D;
	men[156]=8'h23;
	men[157]=8'h21;
	men[158]=8'h27;
	men[159]=8'h25;
	men[160]=8'h5B;
	men[161]=8'h59;
	men[162]=8'h5F;
	men[163]=8'h5D;
	men[164]=8'h53;
	men[165]=8'h51;
	men[166]=8'h57;
	men[167]=8'h55;
	men[168]=8'h4B;
	men[169]=8'h49;
	men[170]=8'h4F;
	men[171]=8'h4D;
	men[172]=8'h43;
	men[173]=8'h41;
	men[174]=8'h47;
	men[175]=8'h45;
	mem[176]=8'h7B;
	mem[177]=8'h79;
	mem[178]=8'h7F;
	mem[179]=8'h7D;
	mem[180]=8'h73;
	mem[181]=8'h71;
	mem[182]=8'h77;
	mem[183]=8'h75;
	mem[184]=8'h6B;
	mem[185]=8'h69;
	mem[186]=8'h6F;
	mem[187]=8'h6D;
	mem[188]=8'h63;
	mem[189]=8'h61;
	mem[190]=8'h67;
	mem[191]=8'h65;
	mem[192]=8'h9B;
	mem[193]=8'h99;
	mem[194]=8'h9F;
	mem[195]=8'h9D;
	mem[196]=8'h93;
	mem[197]=8'h91;
	mem[198]=8'h97;
	mem[199]=8'h95;
	mem[200]=8'h8B;
	mem[201]=8'h89;
	mem[202]=8'h8F;
	mem[203]=8'h8D;
	mem[204]=8'h83;
	mem[205]=8'h81;
	mem[206]=8'h87;
	mem[207]=8'h85;
	mem[208]=8'hBB;
	mem[209]=8'hB9;
	mem[210]=8'hBF;
	mem[211]=8'hBD;
	mem[212]=8'hB3;
	mem[213]=8'hB1;
	mem[214]=8'hB7;
	mem[215]=8'hB5;
	mem[216]=8'hAB;
	mem[217]=8'hA9;
	mem[218]=8'hAF;
	mem[219]=8'hAD;
	mem[220]=8'hA3;
	mem[221]=8'hA1;
	mem[222]=8'hA7;
	mem[223]=8'hA5;
	mem[224]=8'hDB;
	mem[225]=8'hD9;
	mem[226]=8'hDF;
	mem[227]=8'hDD;
	mem[228]=8'hD3;
	mem[229]=8'hD1;
	mem[230]=8'hD7;
	mem[231]=8'hD5;
	mem[232]=8'hCB;
	mem[233]=8'hC9;
	mem[234]=8'hCF;
	mem[235]=8'hCD;
	mem[236]=8'hC3;
	mem[237]=8'hC1;
	mem[238]=8'hC7;
	mem[239]=8'hC5;
	mem[240]=8'hFB;
	mem[241]=8'hF9;
	mem[242]=8'hFF;
	mem[243]=8'hFD;
	mem[244]=8'hF3;
	mem[245]=8'hF1;
	mem[246]=8'hF7;
	mem[247]=8'hF5;
	mem[248]=8'hEB;
	mem[249]=8'hE9;
	mem[250]=8'hEF;
	mem[251]=8'hED;
	mem[252]=8'hE3;
	mem[253]=8'hE1;
	mem[254]=8'hE7;
	mem[255]=8'hE5;
	end
	always@(state)
		begin
			p[1:8] <= mem[state[1:8]];
			p[9:16] <= mem[state[9:16]];
			p[17:24] <= mem[state[17:24]];
			p[25:32] <= mem[state[25:32]];
			
			p[33:40] <= mem[state[33:40]];
			p[41:48] <= mem[state[41:48]];
			p[49:56] <= mem[state[49:56]];
			p[57:64] <= mem[state[57:64]];
			
			p[33:40] <= mem[state[33:40]];
			p[41:48] <= mem[state[41:48]];
			p[49:56] <= mem[state[49:56]];
			p[57:64] <= mem[state[57:64]];
			
			p[65:72] <= mem[state[65:72]];
			p[73:80] <= mem[state[73:80]];
			p[81:88] <= mem[state[81:88]];
			p[89:96] <= mem[state[89:96]];
			
			p[97:104] <= mem[state[97:104]];
			p[105:112] <= mem[state[105:112]];
			p[113:120] <= mem[state[113:120]];
			p[121:128] <= mem[state[121:128]];
		end

endmodule
