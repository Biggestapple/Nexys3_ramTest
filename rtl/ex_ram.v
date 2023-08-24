//----------------------------------------------------------------------------------------------------------
//	FILE: 		ex_ram.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	MT45W18 basic control unit(Only Asynchronous Mode supports)
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.8.30			create
//									 8.31			Bug fixed
//-----------------------------------------------------------------------------------------------------------
module ram_ctrl(
	input		clk,			//Max speed 80Mhz
	input		sys_rst_n,
	//DDR Interface
	output	reg	MemOE,
	output	reg	MemWR,
	output	reg	RamAdv,
	output	reg	RamCS,			//Just MtCE
	output	reg	RamClk,
	output	reg	RamCRE,
	output	reg	RamLB,
	output	reg	RamUB,
	input		RamWait,		//Ignore when using Asynchronous mode
	
	output	reg	[22:0]	MemAdr,
	inout		[15:0]	MemDB,
	//Internal logic interface "Sample-Handing-Method"
	input	mem_we,
	input	[31:0]		mem_addr,
	output	reg	[15:0]	mem_rdata,
	input	[15:0]		mem_wdata,
	output	reg	rdy,
	input	[22:0]		op_code,
	input	reload
);
localparam	IDLE			=9'b0000_00001;
localparam	CONFIG_REG_S0	=9'b0000_00010;
localparam	CONFIG_REG_S1	=9'b0000_00100;
localparam	CONFIG_REG_S2	=9'b0000_01000;
localparam	CONFIG_REG_S3	=9'b0001_00000;
localparam	P0 				=9'b0010_00000;
localparam	P1				=9'b1100_00000;
localparam	MEM_RD			=9'b0100_00000;
localparam	MEM_WR			=9'b1000_00000;


localparam	DY_WAIT=2'b01;
localparam	DY_START_CNT=2'b10;
reg	[8:0]	state;
reg	[1:0]	dy_state;
reg	[15:0]	dy_cnt;				//Using for time delay
reg	[15:0]	dy_tar;				//Setting the delay time
reg			dy_finish;			///Only One-clock
reg			dy_start;

reg			inoutGate;
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n)begin
		mem_rdata <='d0;
		MemOE <=1'b1;
		MemWR <=1'b1;
		RamAdv <=1'b1;
		RamCS <=1'b1;
		RamClk <=1'b0;			//Ingore
		RamCRE <=1'b0;			//Active High
		RamLB <=1'b1;
		RamUB <=1'b1;
		
		dy_tar <='d0;
		dy_start <=1'b0;
		rdy <=1'b0;
		inoutGate <=1'b0;		//Default:Input mode
		state <=IDLE;
	end
	else begin
		RamCRE <=1'b0;
		dy_start <=1'b0;
		rdy <=1'b0;
		case(state)
			IDLE:begin
					state <=CONFIG_REG_S0;
					rdy <=1'b0;
				end
			CONFIG_REG_S0:begin
				MemAdr <=op_code;
				RamCRE <=1'b1;
				RamAdv <=1'b0;
				RamCS <=1'b0;
				MemWR <=1'b1;
				state <=CONFIG_REG_S1;
			end
			CONFIG_REG_S1:begin
				RamAdv <=1'b1;
				dy_tar <='d16;
				dy_start <=1'b1;
				if(dy_finish)
					state <=CONFIG_REG_S2;
				else
					state <=state;
			end
			CONFIG_REG_S2:begin
				MemWR <=1'b0;
				dy_tar <='d8;
				dy_start <=1'b1;
				if(dy_finish) begin
						MemWR <=1'b1;
						state <=CONFIG_REG_S3;
					end
				else
					state <=state;
			end
			CONFIG_REG_S3:begin
				RamCS <=1'b1;
				state <=P0;			//Basic config finished
			end
			P0:begin
					RamLB <=1'b0;
					RamUB <=1'b0;
					RamCS <=1'b0;
					RamAdv <=1'b0;	//ALways enable
				
					MemWR <=1'b1;
					MemOE <=1'b1;
					state <=P1;
					inoutGate <=1'b0;
				end
			P1:
				if(reload ==1'b1)
					state <=IDLE;
				else if(mem_we)
					state <=MEM_WR;
				else
					state <=MEM_RD;
			MEM_RD:begin
				MemAdr <=mem_addr[22:0];
				MemOE <=1'b0;
								//The following WAITING
				dy_tar <='d5;
				dy_start <=1'b1;
								//'b zzzz
				inoutGate <=1'b0;
				if(dy_finish)begin
								//Fetch the data
					mem_rdata <=MemDB;
					rdy <=1'b1;
					state <=P0;
				end
				else
					state <=state;
			end
			MEM_WR:begin
				MemAdr <=mem_addr[22:0];
				MemWR <=1'b0;
				
				dy_tar <='d5;
				dy_start <=1'b1;
				
				inoutGate <=1'b1;
				if(dy_finish)begin
					state <=P0;
					rdy <=1'b1;	//This signal has time problem
				end
				else
					state <=state;
			end
			default: 
				state <=IDLE;
		endcase
	end
//Time delay module
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
			dy_state <=DY_WAIT;
			dy_finish <=1'b0;
			dy_cnt <='d0;
		end
	else begin
		dy_finish <=1'b0;
		case(dy_state)
			DY_WAIT:begin
					dy_cnt <='d0;
					if(dy_start)
						dy_state <=DY_START_CNT;
					else
						dy_state <=dy_state;
				end
			DY_START_CNT:
				if(dy_cnt !=dy_tar)
					dy_cnt <=dy_cnt +1'b1;
				else begin
					dy_finish <=1'b1;
					dy_state <=DY_WAIT;
				end
			default:;
		endcase
	end
assign MemDB =(inoutGate ==1'b0)? 16'bz :mem_wdata;
//Inout	port...:)
endmodule