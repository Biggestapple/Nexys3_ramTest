//----------------------------------------------------------------------------------------------------------
//	FILE: 		top_demo.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	This is a basic demo based on MT45W18
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.8.30			create
//-----------------------------------------------------------------------------------------------------------
module top_demo(
	input		sys_clk,		//Board 100Mhz
	//DDR Interface
	output		MemOE,
	output		MemWR,
	output		RamAdv,
	output		RamCS,
	output		RamClk,
	output		RamCRE,
	output		RamLB,
	output		RamUB,
	input		RamWait,
	
	output		[22:0]	MemAdr,
	inout		[15:0]	MemDB,
	//sevSeg Interface
	output		[3:0]	an,

	output		ca,
	output		cb,
	output		cc,
	output		cd,
	
	output		ce,
	output		cf,
	output		cg,
	output		dp,
	
	
	//Button Interface
	input		BtnU,
	input		BtnD,
	input		BtnS,
	
	//Switch Interface
	input		[7:0]	sw,
	//Led debug
	output		[4:0]	Led
);
wire	sys_rst_n;
wire	clk_50m;
wire	[15:0]		itest_data;
wire	[22:0]		op_code;
wire	reload;
wire	mem_rdy;
(* KEEP = "{TRUE|FALSE |SOFT}" *)wire	mem_we;
wire	[31:0]		mem_addr;
wire	[15:0]		mem_wdata;


assign reload =1'b0;
assign op_code =23'b000_00_00_1_0_011_1_0_1_0_0_01_1_111;
//Pll instance
pll	pll_inst(
	.CLK_IN1		(sys_clk),
	.CLK_OUT1	(clk_50m),
	.LOCKED		(sys_rst_n)
);

ram_ctrl ram_ctrl_inst(
	.clk		(clk_50m),	//Max speed 80Mhz
	.sys_rst_n	(sys_rst_n),
	//DDR Interface
	.MemOE		(MemOE),
	.MemWR		(MemWR),
	.RamAdv		(RamAdv),
	.RamCS		(RamCS),	//Just MtCE
	.RamClk		(RamClk),
	.RamCRE		(RamCRE),
	.RamLB		(RamLB),
	.RamUB		(RamUB),
	.RamWait	(RamWait),	//Ignore when using Asynchronous mode
	
	.MemAdr		(MemAdr),
	.MemDB		(MemDB),
	//Internal logic interface "Sample-Handing-Method"
	.mem_we		(mem_we),
	.mem_addr	(mem_addr),
	.mem_rdata	(itest_data),
	.mem_wdata	(mem_wdata),
	.rdy		(mem_rdy),
	.op_code	(op_code),
	.reload		(reload)
);

sevSeg_drive sevSeg_drive_inst(
	.sys_clk	(clk_50m),
	.sys_rst	(~sys_rst_n),
	
	.i_data		(itest_data),
	
	.shadow_zero(1'b0),
	
	.an			(an),
	
	.ca			(ca),
	.cb			(cb),
	.cc			(cc),
	.cd			(cd),
	
	.ce			(ce),
	.cf			(cf),
	.cg			(cg),
	.dp			(dp)
	
);

control	control_inst(
	.clk		(clk_50m),
	.sys_rst_n	(sys_rst_n),
	.sw			(sw),
	
	.BtnU		(BtnU),
	.BtnD		(BtnD),
	.BtnS		(BtnS),
	
	.mem_we		(mem_we),
	.mem_addr	(mem_addr),
	.mem_wdata	(mem_wdata),
	.mem_rdy	(mem_rdy),
	
	.debug		(Led)
	
);

endmodule