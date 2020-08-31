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
	 assign halt = !hit||!dataHit||!writeHit;
	 
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
	 
	 core core0(
		//.clk(!clk), 2-stage
		.clk(clk),
		.res(res),
		.halt(halt),
		.in_data(in_data), //instruction data
	   .in_addr(in_addr),//instruction address 
	
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
