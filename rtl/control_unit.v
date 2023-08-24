//----------------------------------------------------------------------------------------------------------
//	FILE: 		control_unit.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	Basic control logic (Just for function testing)
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.8.30			create
//-----------------------------------------------------------------------------------------------------------
module control(
	input		clk,
	input		sys_rst_n,
	input	[7:0]		sw,
	
	input		BtnU,
	input		BtnD,
	input		BtnS,
	
	output	reg	mem_we,
	output	reg	[31:0]	mem_addr,
	output	reg	[15:0]	mem_wdata,
	input		mem_rdy,
	
	output	[4:0]		debug

);
reg		[4:0]		state;


reg	BtnD_regi	[3:0];
reg	BtnU_regi	[3:0];
reg	BtnS_regi	[3:0];

wire	ifBtnD,ifBtnU,ifBtnS;
reg		BtnD_reg1,BtnD_reg2;
reg		BtnU_reg1,BtnU_reg2;
reg		BtnS_reg1,BtnS_reg2;
wire	clk_div128_4;
reg		[10:0]	clk_cnt;
wire	btnU_pos,btnD_pos,btnS_pos;

localparam	S0=5'b00001;
localparam	S1=5'b00010;
localparam	S2=5'b00100;
localparam	S3=5'b11000;

integer index;
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n)
		clk_cnt <='d0;
	else
		clk_cnt <=clk_cnt +1'b1;

assign clk_div128_4 =clk_cnt[10];
always @(posedge clk_div128_4 or negedge sys_rst_n)
	if(!sys_rst_n)begin
		BtnD_regi[0] <=1'b0;
		BtnD_regi[1] <=1'b0;
		BtnD_regi[2] <=1'b0;
		BtnD_regi[3] <=1'b0;
		
		BtnU_regi[0] <=1'b0;
		BtnU_regi[1] <=1'b0;
		BtnU_regi[2] <=1'b0;
		BtnU_regi[3] <=1'b0;
		
		BtnS_regi[0] <=1'b0;
		BtnS_regi[1] <=1'b0;
		BtnS_regi[2] <=1'b0;
		BtnS_regi[3] <=1'b0;
	end 
	else begin
		BtnD_regi[0] <=BtnD;
		BtnU_regi[0] <=BtnU;
		BtnS_regi[0] <=BtnS;
		for(index =0;index <3; index =index+1) begin
			BtnD_regi[index+1] <=BtnD_regi[index];
			BtnU_regi[index+1] <=BtnU_regi[index];
			BtnS_regi[index+1] <=BtnS_regi[index];
		end
	end
assign ifBtnD ={BtnD_regi[0],BtnD_regi[1],BtnD_regi[2],BtnD_regi[3]} == 4'b1111;
assign ifBtnU ={BtnU_regi[0],BtnU_regi[1],BtnU_regi[2],BtnU_regi[3]} == 4'b1111;
assign ifBtnS ={BtnS_regi[0],BtnS_regi[1],BtnS_regi[2],BtnS_regi[3]} == 4'b1111;
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		BtnD_reg1 <=1'b0;
		BtnD_reg2 <=1'b0;
		BtnU_reg1 <=1'b0;
		BtnU_reg2 <=1'b0;
		BtnS_reg1 <=1'b0;
		BtnS_reg2 <=1'b0;
	end
	else begin
		BtnD_reg1 <=ifBtnD;
		BtnD_reg2 <=BtnD_reg1;
		BtnU_reg1 <=ifBtnU;
		BtnU_reg2 <=BtnU_reg1;
		BtnS_reg1 <=ifBtnS;
		BtnS_reg2 <=BtnS_reg1;
	end
assign btnD_pos =(~BtnD_reg2 && BtnD_reg1);
assign btnU_pos =(~BtnU_reg2 && BtnU_reg1);
assign btnS_pos =(~BtnS_reg2 && BtnS_reg1);
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		mem_wdata <=16'd0;
		mem_we <=1'b0;
		mem_addr <=32'd0;
		state <=S0;
	end
	else begin
		mem_we <=1'b0;
		case(state)
			S0: begin
					if(btnU_pos)
						mem_addr <=mem_addr +'d1;
					else if(btnD_pos)
						mem_addr <=mem_addr -'d1;
					else	
						mem_addr <=mem_addr;
					if(btnS_pos)
						state <=S1;
					else
						state <=state;
					end
			S1:
				if(mem_rdy) begin
						mem_we <=1'b1;
						mem_wdata[7:0]  <=sw;
						state <=S2;
					end
				else 
					state <=state;
			S2:
				if(btnS_pos)
					state <=S3;
				else
					state <=state;
			S3:
				if(mem_rdy) begin
						mem_we <=1'b1;
						mem_wdata[15:8]  <=sw;
						state <=S0;
					end
				else 
					state <=state;
			default:
				state <=S0;
		endcase
	end

assign debug =state;
endmodule