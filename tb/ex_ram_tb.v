module ram_tb();
reg	sys_clk;
reg	sys_rst_n;

reg	[31:0]	mem_addr;
reg	[15:0]	mem_wdata;
reg	mem_we;
//Clock generate
always #1        sys_clk <=	~sys_clk;
initial begin
	#0	sys_clk <=1'b0;sys_rst_n <=1'b1;
	#10	sys_rst_n <=1'b0;
	#2	sys_rst_n <=1'b1;
//Just wait to see what will happen
	
	
	#200 $finish;
end

wire	MemOE,MemWR,RamAdv,RamCS,RamClk,RamCRE,RamLB,RamWait,reload;
wire	[22:0]	MemAdr;
wire	[15:0]	mem_rdata;
wire	[22:0]	op_code;
wire	[15:0]	MemDB;
//Mt45w8 model----Noop//
assign MemDB =(MemWR ==1'b1)? 16'h11_00: 16'bz;
//--------------------//
assign op_code =23'd4435;
assign reload =1'b0;

ram_ctrl ram_ctrl_dut(
	.clk		(sys_clk),	//Max speed 80Mhz
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
	.mem_rdata	(mem_rdata),
	.mem_wdata	(mem_wdata),
	.rdy		(rdy),
	.op_code	(op_code),
	.reload		(reload)
);

//Read and Write Test
always @(posedge sys_clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		mem_addr <='d0;
		mem_wdata <='d0;
		mem_we <=1'b0;
	end
	else if(rdy) begin
		mem_we <=~mem_we;
		if(mem_we) begin
			mem_addr <=mem_addr +1'b1;
			mem_wdata <=mem_wdata +'d15;
		end
	end
endmodule