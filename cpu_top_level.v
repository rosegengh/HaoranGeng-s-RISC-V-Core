`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:58:55 04/27/2020 
// Design Name: 
// Module Name:    cpu_top_level 
// Project Name:   gengh's risc-v
// Target Devices: 
// Tool versions: 
// Description: The top level of the risc process with ram and rom,
//              Using harvard architecture
//              
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Referenced by darkrisc https://github.com/darklife/darkriscv
//
//////////////////////////////////////////////////////////////////////////////////

module cpu_top_level(
	 input clk, //clock signal
	 input res, //reset signal
	 output [3:0] LED,  
    output [3:0] DEBUG	 
    );
	 // internal/external reset logic
	 reg [7:0] IRES = -1;
	 //synchronous reset
	 always@(posedge clk) IRES <= res==0 ? -1 : IRES[7] ? IRES-1 : 0; // reset low
	 //always@(posedge XCLK) IRES <= res==1 ? -1 : IRES[7] ? IRES-1 : 0; // reset high 
	 wire RES = IRES[7];
	 
	 //initialize memory
	 reg [31:0] ROM [0:1023]; // ro memory for instruction
    reg [31:0] RAM [0:1023]; // rw memory for data
	 
	 integer i;
    initial
    begin
	     //reset ram and rom
        for(i=0;i!=1024;i=i+1)
        begin        
            ROM[i] = 32'd0;
            RAM[i] = 32'd0;
        end
		  $readmemh("cpu_rom.mem",ROM);        
        $readmemh("cpu_ram.mem",RAM);
	 end
	 
	 wire [31:0] in_data; //instruction data
	 wire [31:0] in_addr;//instruction address 
	
	 wire [31:0] data_in; //input data
	 wire [31:0] data_out;//out_put data
	 wire [31:0] address; // address bus
	
	 //for soc RAM and ROM
	 wire  write_e;   //write enable
	 wire  read_e;		 //read enable
	 wire  [3:0] BE;   //base address
	 wire [31:0] IOMUX [0:3]; //for waitr for memroy read and write
	 wire halt;
	 reg  [15:0] GPIOFF = 0;
    reg  [15:0] LEDFF  = 0;
	 
	 
	 reg [31:0] ROMFF;  //instruction memory
	 /*
	 //instruction cache
	 reg [55:0] Icache [0:63]; //instruction cache
	 reg [63:0] Itag = 0;      //instruction cache tag
	 
	 wire [31:0] Idata = Icache[in_addr[7:2]][31:0];   //data
	 wire [31:8] Iaddress = Icache[in_addr[7:2]][55:32]; //address
	 wire hit = Itag[in_addr[7:2]] && Iaddress == in_addr[31:8];
	 reg IFFX =0;
	 reg IFFX2 = 0;
	 always@(posedge clk)
	 begin
		ROMFF <= ROM[in_addr[11:2]];
		if(IFFX2)
		begin
			IFFX2 <= 0;
			IFFX <= 0;
		end
		else
		if(!hit)
		begin
			Icache[in_addr[7:2]] <= {in_addr[31:8], ROMFF};
			Itag[in_addr[7:2]] <= IFFX;
			IFFX <= 1;
			IFFX2 <= IFFX;
		end
	 end
	 assign in_data = Idata;
	 */
	 
	 
	 wire hit = 1;   //always hit to read the instruction memory
	 
	 always @(posedge clk)
	 begin
		 if(!halt) //3 stage
		 ROMFF <= ROM[in_addr[11:2]]; //reading the instruction from ROM
	 end
	 
	 assign in_data = ROMFF;
	 
	 
	 //if the wait stage is nor performed
	 //the read memory instruction will not performed due to the halt
	 reg [31:0] RAMFF; //data memory data
	 //performing wait_stage for reading RAM memroy
	 reg[1:0] DACK = 0;
	 wire writeHit = 1;  //write memory always hit
	 wire dataHit = ! ((write_e || read_e) && DACK != 1);  //data hit
	 always@(posedge clk) 
    begin
        DACK <= res ? 0 : DACK ? DACK-1 : (read_e||write_e) ? 1 : 0; // wait-states for 1 clock cycle
    end
	 
	 
	 always @(posedge clk)
	 begin
		RAMFF <= RAM[address[11:2]];
	 end
	 
	 reg [31:0] IOMUXFF;
	 //write memory 2 stage
	 /*
	 always @(posedge clk)
	 begin
			if(write_e && address[31] == 0 && BE[3]) RAM[address[11:2]][31: 24] <= data_out[31: 24];
			if(write_e && address[31] == 0 && BE[2]) RAM[address[11:2]][23: 16] <= data_out[23: 16];
			if(write_e && address[31] == 0 && BE[1]) RAM[address[11:2]][15: 8] <= data_out [15:  8];
			if(write_e && address[31] == 0 && BE[0]) RAM[address[11:2]][7: 0] <= data_out  [7:   0];
			IOMUXFF <= IOMUX[address[3:2]]; // read w/ 2 wait-states
			
	 end
	*/
	 //write memory 3 stage
	 always @(posedge clk)
	 begin
		if(!halt && write_e && address[31] == 0)
		begin
			RAM[address[11:2]] <= {BE[3] ? data_out[31:24] : RAMFF[31:24],
									     BE[2] ? data_out[23:16] : RAMFF[23:16],
										  BE[1] ? data_out[15:8] : RAMFF[15:8],
										  BE[0] ? data_out[7:0] : RAMFF[7:0]};
		end
		IOMUXFF <= IOMUX[address[3:2]];
	 end
	 //load data from ram
	 assign data_in = address[31] ?  IOMUXFF  : RAMFF; 
	 assign halt = !hit||!dataHit||!writeHit || !AESLOGIC;
	 
	 //config output for top_level
	 always@(posedge clk)
    begin
		if(write_e&&address[31]&&address[3:0]==4'b1000)
        begin
            LEDFF <= data_out[15:0];
        end

        if(write_e&&address[31]&&address[3:0]==4'b1010)
        begin
            GPIOFF <= data_out[31:16];
        end
	 end
	
	
	wire EN_shiftrows_e;
	wire EN_Addround_e;
	wire EN_SubMix_e;
	wire EN_SubBytes_e;
	
	wire Load_AES_e;
	
	wire DE_shiftrows_e;
	wire DE_Addround_e;
	wire DE_SubMix_e;
	wire DE_SubBytes_e;
	
	wire Store_AES_e;
	wire [127:0] aes_store;
	wire [2:0] AES_FCT3;
	wire [31:0] s1,s2,sd;
	
	wire [31:0] imcrypto_out;
	wire IMLOAD_e;
	wire IMSTORE_e;
	wire IMMOVE_e;
	wire IMADD_e;
	wire IMAND_e;
	wire IMOR_e;
	wire IMXOR_e;
	wire IMNOT_e;
	wire IMSCR_e;
	wire IMSR_e;
	wire IMCSL_e;
	
	
	reg[1:0] DelayLData= 1;
	reg[1:0] DelayLAdd = 1;
	reg[1:0] DelayLShift = 1;
	reg[1:0] DelayLSubMix = 1;
	reg[1:0] DelayLSub= 1;
	
	reg[1:0] DelaySData = 1;
	reg[1:0] DelaySAdd = 1;
	reg[1:0] DelaySShift = 1;
	reg[1:0] DelaySSubMix = 1;
	reg[1:0] DelaySSub= 1;
	
	reg[1:0] DelayIMLOAD = 1;
	reg[1:0] DelayIMSTORE = 1;
	reg[1:0] DelayIMMOVE = 1;
	reg[1:0] DelayIMADD = 1;
	reg[1:0] DelayIMAND = 1;
	reg[1:0] DelayIMOR =1;
	reg[1:0] DelayIMXOR = 1;
	reg[1:0] DelayIMNOT = 1;
	reg[1:0] DelayIMSCR = 1;
	reg[1:0] DelayIMSR = 1;
	reg[1:0] DelayIMCSL = 1;
	
	
	
	always@(posedge clk) 
   begin
        DelayLAdd <= res ? 0 : DelayLAdd ? DelayLAdd-1 : EN_Addround_e ? 1 : 0;
		  DelayLShift <= res ? 0 : DelayLShift ? DelayLShift-1 : EN_shiftrows_e ? 1 : 0;
		  DelayLSubMix <= res ? 0 : DelayLSubMix ? DelayLSubMix-1 : EN_SubMix_e ? 1 : 0;
		  DelayLSub <= res ? 0 : DelayLSub ? DelayLSub-1 : EN_SubBytes_e ? 1 : 0;
		  
		  DelayLData <= res ? 0 : DelayLData ? DelayLData-1 : Load_AES_e ? 1 : 0;
		  
		  DelaySAdd <= res ? 0 : DelaySAdd ? DelaySAdd-1 : DE_Addround_e ? 1 : 0;
		  DelaySShift <= res ? 0 : DelaySShift ? DelaySShift-1 : DE_shiftrows_e ? 1 : 0;
		  DelaySSubMix <= res ? 0 : DelaySSubMix ? DelaySSubMix-1 : DE_SubMix_e ? 1 : 0;
		  DelaySSub <= res ? 0 : DelaySSub ? DelaySSub-1 : DE_SubBytes_e ? 1 : 0;
		  
		  DelaySData <= res ? 0 : DelaySData ? DelaySData-1 : Store_AES_e ? 1 : 0;
		  
		  DelayIMLOAD <= res ? 0 : DelayIMLOAD ?DelayIMLOAD -1 : IMLOAD_e ? 1 : 0;
		  DelayIMSTORE <= res ? 0: DelayIMSTORE ?DelayIMSTORE -1 : IMSTORE_e ? 1 : 0;
		  DelayIMMOVE <= res ? 0:  DelayIMMOVE ?DelayIMMOVE -1 : IMMOVE_e ? 1 : 0;
	     DelayIMADD <= res ? 0:   DelayIMADD ?DelayIMADD -1 : IMADD_e ? 1 : 0;
	     DelayIMAND <= res ? 0:   DelayIMAND ?DelayIMAND -1 : IMAND_e ? 1 : 0;
	     DelayIMOR <= res ? 0:    DelayIMOR ?DelayIMOR -1 : IMOR_e ? 1 : 0;
	     DelayIMXOR <= res ? 0:   DelayIMXOR?DelayIMXOR -1 : IMXOR_e ? 1 : 0;
	     DelayIMNOT <= res ? 0:   DelayIMNOT ?DelayIMNOT -1 : IMNOT_e ? 1 : 0;
	     DelayIMSCR <= res ? 0:   DelayIMSCR ?DelayIMSCR -1 : IMSCR_e ? 1 : 0;
	     DelayIMSR <= res ? 0:    DelayIMSR ?DelayIMSR -1 : IMSR_e ? 1 : 0;
	     DelayIMCSL <= res ? 0:   DelayIMCSL ?DelayIMCSL -1 : IMCSL_e ? 1 : 0;
		  
		  
		  
		  
		  
	end
	wire EN_Addround_done = !(EN_Addround_e && DelayLAdd == 0);
	wire EN_shiftrows_done = !(EN_shiftrows_e && DelayLShift == 0);
	wire EN_SubMix_done= !(EN_SubMix_e && DelayLSubMix == 0);
	wire EN_SubBytes_done = !(EN_SubBytes_e && DelayLSub == 0);
	
	wire Load_AES_done = !(Load_AES_e && DelayLData == 0);
	
	
	wire [127:0] aes_load = Load_AES_done ? 128'hffffffffffffffffffffffffffffffff: 0;
	wire [31:0] imcrypto_in = IMLOAD_done ? 2323 : 0;
	wire DE_shiftrows_done= !(DE_Addround_e && DelaySAdd == 0);
	wire DE_Addround_done= !(DE_shiftrows_e && DelaySShift == 0);
	wire DE_SubMix_done = !(DE_SubMix_e && DelaySSubMix == 0);
	wire DE_SubBytes_done = !(DE_SubBytes_e && DelaySSub == 0);
	
	wire Store_AES_done = !(Store_AES_e && DelaySData == 0);
	
	
	wire IMLOAD_done = !(IMLOAD_e && DelayIMLOAD == 0);
	wire IMSTORE_done = !(IMSTORE_e && DelayIMSTORE == 0);
	
	wire IMMOVE_done = !(IMMOVE_e && DelayIMMOVE == 0);
	wire IMADD_done = !(IMADD_e && DelayIMADD == 0);
	wire IMAND_done = !(IMAND_e && DelayIMAND == 0);
	wire IMOR_done = !(IMOR_e && DelayIMOR == 0);
	wire IMXOR_done = !(IMXOR_e && DelayIMXOR == 0);
	wire IMNOT_done = !(IMNOT_e && DelayIMNOT == 0);
	wire IMSCR_done = !(IMSCR_e && DelayIMSCR == 0);
	wire IMSR_done = !(IMSR_e && DelayIMSR == 0);
	wire IMCSL_done = !(IMCSL_e && DelayIMCSL == 0);
	
	wire  AESLOGIC = (EN_shiftrows_done && EN_Addround_done && EN_SubMix_done  && EN_SubBytes_done && DE_shiftrows_done && DE_Addround_done && DE_SubMix_done && DE_SubBytes_done && Store_AES_done && Load_AES_done
							&& IMLOAD_done && IMSTORE_done && IMMOVE_done && IMADD_done && IMAND_done && IMOR_done && IMXOR_done && IMNOT_done && IMSCR_done && IMSR_done && IMCSL_done);
	
	 core core0(
		//.clk(!clk), 2-stage
		.clk(clk),
		.res(res),
		.halt(halt),
		.in_data(in_data), //instruction data
	   .in_addr(in_addr),//instruction address 
		
		.EN_shiftrows_done(EN_shiftrows_done),
	   .EN_Addround_done(EN_Addround_done),
	   .EN_SubMix_done(EN_SubMix_done),
	   .EN_SubBytes_done(EN_SubBytes_done),
		
	   .Load_AES_done(Load_AES_done),
		
		
	   .DE_shiftrows_done(DE_shiftrows_done),
	   .DE_Addround_done(DE_Addround_done),
	   .DE_SubMix_done(DE_SubMix_done),
	   .DE_SubBytes_done(DE_SubBytes_done),
		
		.Store_AES_done(Store_AES_done),
	   .aes_load(aes_load),
		
		
		.imcrypto_in(imcrypto_in),
		.IMLOAD_done(IMLOAD_done),
		.IMSTORE_done(IMSTORE_done),
		.IMMOVE_done(IMMOVE_done),
		.IMADD_done(IMADD_done),
		.IMAND_done(IMAND_done),
		.IMOR_done(IMOR_done),
		.IMXOR_done(IMXOR_done),
		.IMNOT_done(IMNOT_done),
		.IMSCR_done(IMSCR_done),
		.IMSR_done(IMSR_done),
		.IMCSL_done(IMCSL_done),
		
		.EN_shiftrows_e(EN_shiftrows_e),
	   .EN_Addround_e(EN_Addround_e),
	   .EN_SubMix_e(EN_SubMix_e),
	   .EN_SubBytes_e(EN_SubBytes_e),
		
		.Load_AES_e(Load_AES_e),
		
		
		
		
	   .DE_shiftrows_e(DE_shiftrows_e),
	   .DE_Addround_e(DE_Addround_e),
	   .DE_SubMix_e(DE_SubMix_e),
	   .DE_SubBytes_e(DE_SubBytes_e),
		
		.Store_AES_e(Store_AES_e),
		.aes_store(aes_store),
		//.AES_FCT3(AES_FCT3),
		
		.imcrypto_out(imcrypto_out),
		.IMLOAD_e(IMLOAD_e),
		.IMSTORE_e(IMSTORE_e),
		.IMMOVE_e(IMMOVE_e),
		.IMADD_e(IMADD_e),
		.IMAND_e(IMAND_e),
		.IMOR_e(IMOR_e),
		.IMXOR_e(IMXOR_e),
		.IMNOT_e(IMNOT_e),
		.IMSCR_e(IMSCR_e),
		.IMSR_e(IMSR_e),
		.IMCSL_e(IMCSL_e),
		.s1(s1),
		.s2(s2),
		.sd(sd),
		
		
	   .data_in(data_in), //input data
	   .data_out(data_out),//out_put data
	   .address(address), // address bus
		.write_e(write_e),   //write enable
	   .read_e(read_e),		 //read enable
		.BE(BE)               //base address
	 );
	 assign LED   = LEDFF[3:0];
	 assign DEBUG =  GPIOFF[3:0];
	 
endmodule
