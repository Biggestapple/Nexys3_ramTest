//----------------------------------------------------------------------------------------------------------
//	FILE: 		sevSeg_drive.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	A driver of Seven-segment display on Basys2
// 	KEYWORDS:	fpga, basic module, Display
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			 		2023.5.17			create
//			 		2023.5.17			update:添加隐零端口
//					2023.5.28			update:添加BCD转换电路
//-----------------------------------------------------------------------------------------------------------
module		sevSeg_drive#(
	parameter			HEX_BYTE_LENGTH		=16,
	parameter			TIM_THOLD  			=16'hfb11,
	parameter			SYSTEM_CLK 			=50_000000
)(
	input				sys_clk,
	input				sys_rst,
	
	input				[HEX_BYTE_LENGTH-1:0]	i_data,
	
	input				shadow_zero,
	
	output		reg		[3:0]					an,
	
	output		reg		ca,
	output		reg		cb,
	output		reg		cc,
	output		reg		cd,
	
	output		reg		ce,
	output		reg		cf,
	output		reg		cg,
	output		reg		dp
	
	//input				BCD //High:Enable
	
);
//Note:Ref Figure 7. Seven-segment display

reg				[HEX_BYTE_LENGTH-1:0]		data;
reg				[3:0]						data_mask;

reg				[3:0]						state;

reg				[15:0]						time_cnt;//视觉暂留延时时间

always @(posedge sys_clk)
	if(sys_rst)
		data <={(HEX_BYTE_LENGTH)*{1'b0}};
	else 
		data <=i_data;
		

//Seven-segment driver
integer		index;
always @(posedge sys_clk) begin	
	case(data_mask)
		4'h0:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0000_0011;
		4'h1:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b1001_1111;
		4'h2:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0010_0101;
		4'h3:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0000_1101;
		4'h4:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b1001_1001;
		4'h5:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0100_1001;
		4'h6:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0100_0001;
		4'h7:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0001_1111;
		4'h8:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0000_0001;
		4'h9:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0000_1001;
		4'ha:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0001_0001;
		4'hb:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b1100_0001;
		4'hc:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0110_0011;
		4'hd:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b1000_0101;
		4'he:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0010_0001;
		4'hf:{ca,cb,cc,cd,ce,cf,cg,dp} <=8'b0111_0001;
	endcase
end
//数码管刷新FSM
localparam						IDLE =4'b0000;
localparam						S0 	 =4'b0001;
localparam						S1 	 =4'b0010;
localparam						S2 	 =4'b0011;
localparam						S3 	 =4'b0100;


localparam						S4 	 =4'b0101;
localparam						S5 	 =4'b0110;
localparam						S6 	 =4'b0111;
localparam						S7 	 =4'b1000;
always @(posedge sys_clk)
	if(sys_rst) begin
			state <=4'b0000;
			time_cnt <=16'h0000;
		end
	else begin
		case(state)
			IDLE:state <=S0;
			S0:begin
					data_mask <=data[3:0];
					//an[0] <=(shadow_zero ==1'b1) ?~(data[3:0] ==4'b0000):1'b1;
					if(shadow_zero ==1'b1) begin
						if(data[3:0] !=4'b0000)
							an[0] <=1'b0;
						else if(data[15:4] !=0)
							an[0] <=1'b0;
						else
							an[0] <=1'b1;
					end
					else
						an[0] <=1'b0;
					state <=S1;
				end
			S1:
				if(time_cnt ==TIM_THOLD) begin
						state <=S2;
						time_cnt <=16'h0000;
						an[0] <=1'b1;
					end
				else
					time_cnt <=time_cnt +1'b1;
			S2:begin
					data_mask <=data[7:4];
					//an[1] <=(shadow_zero ==1'b1) ?~(data[7:4] ==4'b0000):1'b1;
					if(shadow_zero ==1'b1) begin
						if(data[7:4] !=4'b0000)
							an[1] <=1'b0;
						else if(data[15:8] !=0)
							an[1] <=1'b0;
						else
							an[1] <=1'b1;
					end
					else
						an[1] <=1'b0;
					state <=S3;
				end
			S3:
				if(time_cnt ==TIM_THOLD) begin
					state <=S4;
					time_cnt <=16'h0000;
					an[1] <=1'b1;
					end
				else
					time_cnt <=time_cnt +1'b1;
			S4:begin
					data_mask <=data[11:8];
					//an[2] <=(shadow_zero ==1'b1) ?~(data[11:8] ==4'b0000):1'b1;
					if(shadow_zero ==1'b1) begin
						if(data[11:8] !=4'b0000)
							an[2] <=1'b0;
						else if(data[15:12] !=0)
							an[2] <=1'b0;
						else
							an[2] <=1'b1;
					end
					else
						an[2] <=1'b0;
					state <=S5;
				end
			S5:
				if(time_cnt ==TIM_THOLD) begin
						state <=S6;
						time_cnt <=16'h0000;
						an[2] <=1'b1;
					end
				else
					time_cnt <=time_cnt +1'b1;
			S6:begin
					data_mask <=data[15:12];
					an[3] <=(shadow_zero ==1'b1) ?(data[15:12] ==4'b0000):1'b0;
					state <=S7;
				end
			S7:
				if(time_cnt ==TIM_THOLD) begin
						state <=S0;
						time_cnt <=16'h0000;
						an[3] <=1'b1;
					end
				else
					time_cnt <=time_cnt +1'b1;
			default:
				state <=state;
		endcase
	end

endmodule