`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:35:07 04/20/2020 
// Design Name: 
// Module Name:    core 
// Project Name: 	 gengh's risc-v
// Target Devices: 
// Tool versions: 
// Description: This the the main core, can handle RV32I instruction set. 2 stage pipleline flushing
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: reference by darkrisc https://github.com/darklife/darkriscv
//
//////////////////////////////////////////////////////////////////////////////////
// implemented opcodes:

`define LUI     7'b01101_11      // lui   rd,imm[31:12]
`define AUIPC   7'b00101_11      // auipc rd,imm[31:12]
`define JAL     7'b11011_11      // jal   rd,imm[xxxxx]
`define JALR    7'b11001_11      // jalr  rd,rs1,imm[11:0] 
`define BCC     7'b11000_11      // branch   rs1,rs2,imm[12:1]
`define LCC     7'b00000_11      // load   rd,rs1,imm[11:0]
`define SCC     7'b01000_11      // store   rs1,rs2,imm[11:0]
`define MCC     7'b00100_11      // arithmic  rd,rs1,imm[11:0]
`define RCC     7'b01100_11      // arithmic   rd,rs1,rs2 
`define MAC     7'b11111_11      // mac   rd,rs1,rs2
`define __RESETSP__ 32'd8192     //define sp_reset


// not implemented opcodes:




module core(
	input clk, //clock signal
	input res, //reset signal
	input halt,//halt signal
	
	//instruction set
	input [31:0] in_data, //instruction data
	output [31:0] in_addr,//instruction address 
	
	input [31:0] data_in, //input data
	output [31:0] data_out,//out_put data
	output [31:0] address, // address bus
	
	//for soc RAM and ROM
	output  write_e,   //write enable
	output  read_e	,	 //read enable
	output [3:0]  BE   //base address
    );

	 
	 //fetch and decode stage
	 reg [31:0] XIDATA;
	 
	 //tempory reg for specific instruction
	 reg XLUI; //load upper imm
	 reg XAUIPC;//add upper imm
	 reg XJAL; //jump and link
	 reg XJALR; // jump register
	 
	 //tempory reg for different types
	 reg XLCC;  //LOAD
	 reg XSCC; //STORE
	 reg XBCC; //BRANCH SB-TYPE
	 reg XMCC; //arthimic imm
	 reg XMAC; //mac
	 reg XRCC; // arthimic register
	 
	 reg[31:0] XSIMM;  //signal extended immediate
	 reg[31:0] XUIMM;  //non-signal extended immediate
	 //branch history table
	 reg [33:0] BTB [0:255];
	 //32 bits all 0 and -1, trick from darkrisc :)
	 wire [31:0] ALL0  = 0;
    wire [31:0] ALL1  = -1;
	 //Branch Prediction parameters
	 wire[1:0] STRONGLY_TAKEN=2'b11;
	 wire[1:0] WEAKLY_TAKEN=2'b10;
	 wire[1:0] WEAKLY_NOT_TAKEN =2'b01;
	 wire[1:0] STRONGLY_NOT_TAKEN=2'b00;
	 wire[1:0] BDESICION = BTB[PC[11:2]][33:32];
	 
	 //initialy set all buffer to 0
	 integer i;
    initial
    begin
        for(i=0;i!=256;i=i+1)
        begin        
            BTB[i] = 0;
        end
	 end
	 
	 always@(posedge clk)
	 begin
		if(!halt)
		begin
			//chcek the instuction's first seven bits opcode
			XIDATA <= in_data;
			XLUI   <= in_data[6:0] == `LUI;
			XAUIPC <= in_data[6:0] == `AUIPC;
			XJAL   <= in_data[6:0] == `JAL;
			XJALR  <= in_data[6:0] == `JALR;
			XLCC   <= in_data[6:0] == `LCC;
			XSCC   <= in_data[6:0] == `SCC;
			XBCC   <= in_data[6:0] == `BCC;
			XMCC   <= in_data[6:0] == `MCC;
			XMAC  <= in_data[6:0] == `MAC;
			XRCC   <= in_data[6:0] == `RCC;
	
			//capture only the imm value unsign extended the rest
			XUIMM <=
					in_data[6:0] == `JAL ?
							{ALL0[31:21],in_data[31],in_data[19:12],in_data[20],in_data[30:21],ALL0[0]}: //j-type
					in_data[6:0] == `BCC ?
							{ALL0[31:13],in_data[31],in_data[7],in_data[30:25],in_data[11:8],ALL0[0] } : //b-type branch
					in_data[6:0] == `SCC ?
							{ALL0[31:12],in_data[31:25],in_data[11:7]}:  //s -type
					in_data[6:0] == `LUI || 
					in_data[6:0] == `AUIPC ? {in_data[31:12], ALL0[11:0]} :  //u-type
							{ALL0[31:12], in_data[31:20]};  //i-type
			//capture only the imm value sign based on the in_data[31]
			XSIMM <=
					in_data[6:0] == `JAL ?
							{in_data[31] ? ALL1[31:21]:ALL0[31:21], in_data[31], in_data[19:12], in_data[20], in_data[30:21], ALL0[0]}: //j-type
					in_data[6:0] == `BCC ?
							{in_data[31] ? ALL1[31:13]:ALL0[31:13], in_data[31],in_data[7],in_data[30:25],in_data[11:8],ALL0[0] } : //b-type branch
					in_data[6:0] == `SCC ?
							{in_data[31] ? ALL1[31:12]:ALL0[31:12], in_data[31:25],in_data[11:7]}:  //s -type
					in_data[6:0] == `LUI || 
					in_data[6:0] == `AUIPC ? {in_data[31:12], ALL0[11:0]} :  //u-type
							{in_data[31] ? ALL1[31:12]:ALL0[31:12], in_data[31:20]};  //i-type
			
																			

		end
	 end
	 //2-stage
	 //reg FLUSH = -1;  
	 reg[1:0] FLUSH = -1; //flush instruction for piepline for 3 stage
	 reg[4:0] RESMODE = 0;
	 //this part is for sp_reset reference the idea from darkrisc
	 // use for halt signal
	 wire[4:0] DPTR = res ? RESMODE:XIDATA[11:7]; //set_sp reset
	 wire [4:0] S1PTR  = XIDATA[19:15];  //rs1 for R,I,S,SB Type
    wire [4:0] S2PTR  = XIDATA[24:20];  //rs2 for R,S,SB Type
	 
	 wire [6:0] OPCODE = FLUSH ? 0 : XIDATA[6:0];//Op code for all function
    wire [2:0] FCT3   = XIDATA[14:12]; // R,I,S,SB-type 14:12 function3
    wire [6:0] FCT7   = XIDATA[31:25]; //R-TYPE 31:25 function 7
	 
	 wire [31:0] SIMM  = XSIMM;
    wire [31:0] UIMM  = XUIMM;
	 //branch target address
	 wire [31:0] branch_target = (in_data[6:0] == `BCC) ? {in_data[31] ? ALL1[31:13]:ALL0[31:13], in_data[31],in_data[7],in_data[30:25],in_data[11:8],ALL0[0] } : 0;

	 //op_code decoder:
	 // if used for piepline flush, opcode = 0
    wire    LUI = FLUSH ? 0 : XLUI;   // OPCODE==7'b0110111;  lui rd imm
    wire  AUIPC = FLUSH ? 0 : XAUIPC; // OPCODE==7'b0010111;  auipc rd imm
    wire    JAL = FLUSH ? 0 : XJAL;   // OPCODE==7'b1101111;  jal rd imm
    wire   JALR = FLUSH ? 0 : XJALR;  // OPCODE==7'b1100111;  jalr rd rs1 imm
    
    wire    BCC = FLUSH ? 0 : XBCC; // OPCODE==7'b1100011; FCT3 sb-type
	 wire    SCC = FLUSH ? 0 : XSCC; // OPCODE==7'b0100011; FCT3 store
    wire    LCC = FLUSH ? 0 : XLCC; // OPCODE==7'b0000011; FCT3 load
    wire    MCC = FLUSH ? 0 : XMCC; // OPCODE==7'b0010011; FCT3 arithmic imm
    
    wire    RCC = FLUSH ? 0 : XRCC; // OPCODE==7'b0110011; FCT3 arithmic register
    wire    MAC = FLUSH ? 0 : XMAC; // OPCODE==7'b0110011; FCT3 mac rd rs1 rs2 
	 	 
	 //finish op code decode
	 
	 reg [31:0] NXPC2; //program counter next two instruction for 3 stage
	 reg [31:0] NXPC;  //program counter next instruction
	 reg[31:0] PC;     //program counter register
	 
	 //register map
	 reg [31:0] REG1 [0:31];	// general-purpose 32x32-bit registers (rs1)
    reg [31:0] REG2 [0:31];	// general-purpose 32x32-bit registers (rs2)
	
	 //assign rs1 rs2 sorce 1 and source 2 for execution
	 //render the register address to 32 bits
	 wire signed   [31:0] S1REG = REG1[S1PTR];
    wire signed   [31:0] S2REG = REG2[S2PTR];
    
    wire          [31:0] U1REG = REG1[S1PTR];
    wire          [31:0] U2REG = REG2[S2PTR];
	 
	 //execution for specific type of instruction
	 
	 //decode based on function code
	 /*
		Load and store instruction
		LDATA and SDATA are used for memory write back in last stage
		LDATA write to register
		SDATA direct connect to data_out for memory usage
	 */
	 // Load function code decode (OPCODE==7'b0000011)
	 /*check signed or unsigned LB or LBU, loade the imm data based on address into LDATA*/
	 wire [31:0] LDATA = FCT3 == 0 || FCT3 == 4 ? (address[1:0] == 1 ? {FCT3==0&&data_in[15] ? ALL1[31: 8]:ALL0[31: 8],data_in[15:8]}   : //load second quater
																  address[1:0] == 2 ? {FCT3==0&&data_in[23] ? ALL1[31: 8]:ALL0[31: 8],data_in[23:16]}  : //load third quater
																  address[1:0] == 3 ? {FCT3==0&&data_in[31] ? ALL1[31: 8]:ALL0[31: 8],data_in[31:24]} : //load fourth quater
			                                                             {FCT3==0&&data_in[7] ? ALL1[31: 8]:ALL0[31: 8],data_in[7:0]}): //load first quater
			 /*check signed or unsigned LH or LHU, loade the imm data based on address into LDATA*/
							   FCT3 == 1 || FCT3 == 5 ? (address[1:0] == 0 ? { FCT3==1&&data_in[15] ? ALL1[31:16]:ALL0[31:16] , data_in[15:0] } : //load first half
																                      { FCT3==1&&data_in[31] ? ALL1[31:16]:ALL0[31:16] , data_in[31:16]}): //load second half
																  data_in;
	 //Store Function code decode (OPCODE==7'b0100011)
	 wire [31:0] SDATA = FCT3== 0 ? /*check for store bytes SB, load the  data in rs2 based on address into SDATA*/
			(address[1:0] == 1 ? {ALL0[31:16],U2REG[7:0],ALL0[7:0]}: //second quater in rs2
			 address[1:0] == 2 ? {ALL0[31:24],U2REG[7:0],ALL0[15:0]}://third quater in rs2
			 address[1:0] == 3 ? {U2REG[7:0],ALL0[23:0]}:           //fourth quater in rs2
			                     {ALL0[31:8], U2REG[7:0]}):           //first quater in rs2
			               FCT3 == 1 ? /*check for store half SH, load the  data in rs2 based on address into SDATA*/
			(address[1:0] == 0 ? {ALL0[31:16], U2REG[15:0]}: //first half in rs2
			                     {U2REG[31:16], ALL0[15:0]})://second half in rs2
			               U2REG;
								
	 //main ALU for execution stage (OPCODEs==7'b0010011/7'b0110011) 
	 //Create the register rs2 for sign and unsign
	 
	 //check need to use register 2 value or imm
	 wire signed [31:0] S2REGX = XMCC ? SIMM : S2REG;
    wire        [31:0] U2REGX = XMCC ? UIMM : U2REG;
	 
	 //Main ALU operation for r-type case by the function code 3 store the rd value inside RMDATA
	 wire[31:0] RMDATA = FCT3 == 0 ? (XRCC&&FCT7[5] ? U1REG-U2REGX : U1REG+S2REGX):      //ADD FUNC7 == 0 and is r-type
								                                                                //SUB FUNC7 == 32 and is r-type
								FCT3 == 1 ? (U1REG<<U2REGX[4:0]):              //Shift left  SLL
								FCT3 == 2 ? (S1REG<S2REGX?1:0) :               //Set < signed SLT
								FCT3 == 3 ? (U1REG<U2REGX?1:0) :               //Set < unsigned SLTU 
								FCT3 == 4 ? (U1REG^S2REGX):                    // Xor 
								FCT3 == 5 ? (FCT7[5] ? U1REG>>>U2REGX[4:0] : U1REG>>U2REGX[4:0]): // Shift right Funct 7 == 0 and is r-type SRL
								                                                                 // Shift right Arithmetic Funct 7 == 32 and is r-type SRA
								FCT3 == 6 ? (U1REG|S2REGX):                    // Or 
								            (U1REG&S2REGX);                    // AND 
								
								
	 //Branch instruction (OPCODE==7'b1100011)
	 
	 //Store the branch value inside the BMUX
	 wire BMUX = XBCC == 1 && (                            //first check it is an sb-type instruction
									  FCT3==0 ? (U1REG==U2REG ? 1:0) :  //BEQ branch equal to
									  FCT3==1 ? (U1REG!=U2REG ? 1:0) :  //BNE branch not equal to
									  FCT3==4 ? (S1REG< S2REG ? 1:0) :  //BLT branch less than signed
									  FCT3==5 ? (S1REG> S2REG ? 1:0) :  //BGE branch greater than signed
									  FCT3==6 ? (U1REG<U2REG ? 1:0) :   //BLTU branch less than uhsigned
									  FCT3==7 ? (U1REG>U2REG ? 1:0) :   //BGEU branch greater than unsigned
									  0);
	 //get the instruction address value by jump, jump register and branch
	 wire        JREQ = (JAL||JALR);
	 //jump to instuction address or direct on current PC
    wire [31:0] JVAL = SIMM + (JALR? U1REG/*jump register?*/ : PC /*branch or direct jump on current PC*/);
	
	 //Main data workflow Clock
	 always@(posedge clk)
	 begin
			RESMODE <= RESMODE + 1;                //for sp_reset
			//FLUSH <= res ? 1 : halt ? FLUSH : (JAL||JALR||BMUX); //flush the piepline 2 stage
			FLUSH <= res ? 1 : halt ? FLUSH : FLUSH ? FLUSH -1 : (JAL||JALR) ? 2: (XBCC) ? (BTB[PC[11:2]] == 0 ? (BMUX ? 1:2) : (BTB[PC[11:2]][33] ? (BMUX ? 1:2) :(BMUX?2:0))):0  ; //flush the piepline for 3 stage
			//FLUSH <= res ? 1 : halt ? FLUSH : FLUSH ? FLUSH -1 : (JAL||JALR||BMUX) ? 2:0;
			//assign two register
			REG1[DPTR] <=   res ?  (RESMODE[4:0]==2 ? `__RESETSP__ : 0)  :   //reset sp
											  halt ? REG1[DPTR]:   //halt
											  DPTR == 0 ? 0:
											  AUIPC ? PC+SIMM: // add imm to pc
											  JAL || JALR ? NXPC: // jump to next pc 
											  LUI ? SIMM:      //loade imm to register
											  LCC ? LDATA:     //loade take memory out
											  MCC || RCC ? RMDATA: //r-type take alu out
											  REG1[DPTR];
			REG2[DPTR] <=   res ?  (RESMODE[4:0]==2 ? `__RESETSP__ : 0)  :   //reset sp
											  halt ? REG1[DPTR]:   //halt
											  DPTR == 0 ? 0:
											  AUIPC ? PC+SIMM: // add imm to pc
											  JAL || JALR ? NXPC: // jump to next pc 
											  LUI ? SIMM:      //loade imm to register
											  LCC ? LDATA:     //loade take memory out
											  MCC || RCC ? RMDATA: //r-type take alu out
											  REG2[DPTR];
			//program counter decode for next pc
			/*2stage
			NXPC <= res ? 32'd0: halt ? NXPC:     //reset and halt
							   JREQ ? JVAL:    //jump & link, jump & link register, branch instruction
								            NXPC + 4; //acting normal to next instruction pc = pc + 4
			*/
			//state machine for prediction
			//assign the branch history table when first met branch
			if(BCC && (BTB[PC[11:2]] == 0))
				BTB[PC[11:2]] <= {WEAKLY_TAKEN,SIMM};
			
			if(BCC && (BTB[PC[11:2]] != 0))
				BTB[PC[11:2]][33:32] <= 	BTB[PC[11:2]][33:32] == STRONGLY_TAKEN ? (BMUX? STRONGLY_TAKEN: WEAKLY_TAKEN ):
											BTB[PC[11:2]][33:32] == WEAKLY_TAKEN ? (BMUX? STRONGLY_TAKEN : WEAKLY_NOT_TAKEN):
											BTB[PC[11:2]][33:32] == WEAKLY_NOT_TAKEN ? (BMUX? WEAKLY_TAKEN : STRONGLY_NOT_TAKEN ):
											BTB[PC[11:2]][33:32] == STRONGLY_NOT_TAKEN ? (BMUX? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN ):
																			WEAKLY_TAKEN;

			//change current pc
			NXPC <= halt ? NXPC : NXPC2;
			NXPC2 <= res ? 32'd0 : halt ? NXPC2: //reset and halt
								JREQ ? JVAL:          //jump & link, jump & link register, branch instruction
								(in_data[6:0] == `BCC && BTB[NXPC[11:2]] == 0 &&(FLUSH == 0 || FLUSH == 1) )? NXPC + branch_target:
								(in_data[6:0] == `BCC &&BTB[NXPC[11:2]][33]  &&(FLUSH == 0 || FLUSH == 1) )?  NXPC+BTB[NXPC[11:2]][31:0]:
								(in_data[6:0] == `BCC &&!BTB[NXPC[11:2]][33] &&BTB[PC[11:2]] != 0 && (FLUSH == 0 || FLUSH == 1) )?  PC+4:
								(BCC && !BMUX && BTB[PC[11:2]] == 0) ? NXPC + 4:
								(BCC &&  BMUX && !BTB[PC[11:2]][33] && BTB[PC[11:2]] != 0) ?  PC+BTB[PC[11:2]][31:0]:
								(BCC &&  !BMUX && BTB[PC[11:2]][33] ) ?  NXPC + 4:
							
								
								NXPC2+4;              //acting normal to next instruction pc = pc + 4

			PC <= halt ? PC : NXPC;
											  
	 end
	 //IO and memory interface
	 assign data_out = SDATA; //store to memory
	 assign address = U1REG + SIMM;//memory access address
	 
	 assign read_e = LCC; //read memory only on load
	 assign write_e = SCC; //write memory only on store 
	 
	 //memeory based in the SCC and LCC
	 assign BE = FCT3==0||FCT3==4 ? ( address[1:0]==3 ? 4'b1000 : // sb/lb 
                                     address[1:0]==2 ? 4'b0100 : 
                                     address[1:0]==1 ? 4'b0010 :
                                                     4'b0001 ) :
                FCT3==1||FCT3==5 ? ( address[1]==1   ? 4'b1100 : // sh/lh half
                                                     4'b0011 ) :
                                                     4'b1111; // sw/lw
	 //assign in_addr = NXPC; //2 stage
	 assign in_addr = NXPC2; // 3 stage
	 
endmodule
