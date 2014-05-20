
module av_status_reg(

	input clk, 
	input reset_n, 

	
	//Avalon-MM inputs
	input [3:0] address,
	input write, 
	input read,
	input [31:0] writedata,
	
	//Avalon-MM output
	output [31:0] readdata,

	//to UDP module
	output [31:0] status_reg0_o,
	output [31:0] status_reg1_o,
	output [31:0] status_reg2_o,
	output [31:0] status_reg3_o,
	output [31:0] status_reg4_o,
	output [31:0] status_reg5_o,
	output [31:0] status_reg6_o,
	output [31:0] status_reg7_o,
	
	output udp_send
	
);

reg [31:0] udp_send_reg;
reg [31:0] udp_send_reg_new;

reg [31:0] status_reg0;
reg [31:0] status_reg0_new;

reg [31:0] status_reg1;
reg [31:0] status_reg1_new;

reg [31:0] status_reg2;
reg [31:0] status_reg2_new;

reg [31:0] status_reg3;
reg [31:0] status_reg3_new;

reg [31:0] status_reg4;
reg [31:0] status_reg4_new;

reg [31:0] status_reg5;
reg [31:0] status_reg5_new;

reg [31:0] status_reg6;
reg [31:0] status_reg6_new;

reg [31:0] status_reg7;
reg [31:0] status_reg7_new;

reg [31:0] readdata_reg, readdata_reg_new;

/*	Write operation	*/
always @ (*)
	if (write)
		case(address)
			4'd0:	
				begin
					udp_send_reg_new = writedata;
					status_reg0_new = status_reg0;
					status_reg1_new = status_reg1;
					status_reg2_new = status_reg2;
					status_reg3_new = status_reg3;
					status_reg4_new = status_reg4;
					status_reg5_new = status_reg5;
					status_reg6_new = status_reg6;
					status_reg7_new = status_reg7;
				end
			4'd1: 
				begin 
					udp_send_reg_new = udp_send_reg;
					status_reg0_new = writedata;
					status_reg1_new = status_reg1;
					status_reg2_new = status_reg2;
					status_reg3_new = status_reg3;
					status_reg4_new = status_reg4;
					status_reg5_new = status_reg5;
					status_reg6_new = status_reg6;
					status_reg7_new = status_reg7;
				end
			4'd2: 
				begin 
					udp_send_reg_new = udp_send_reg;
					status_reg0_new = status_reg0;
					status_reg1_new = writedata;
					status_reg2_new = status_reg2;
					status_reg3_new = status_reg3;
					status_reg4_new = status_reg4;
					status_reg5_new = status_reg5;
					status_reg6_new = status_reg6;
					status_reg7_new = status_reg7;
				end
			4'd3: 
				begin 
					udp_send_reg_new = udp_send_reg;
					status_reg0_new = status_reg0;
					status_reg1_new = status_reg1;
					status_reg2_new = writedata;
					status_reg3_new = status_reg3;
					status_reg4_new = status_reg4;
					status_reg5_new = status_reg5;
					status_reg6_new = status_reg6;
					status_reg7_new = status_reg7;
				end
			4'd4: 
				begin 
					udp_send_reg_new = udp_send_reg;
					status_reg0_new = status_reg0;
					status_reg1_new = status_reg1;
					status_reg2_new = status_reg2;
					status_reg3_new = writedata;
					status_reg4_new = status_reg4;
					status_reg5_new = status_reg5;
					status_reg6_new = status_reg6;
					status_reg7_new = status_reg7;
				end
			4'd5: 
				begin 
					udp_send_reg_new = udp_send_reg;
					status_reg0_new = status_reg0;
					status_reg1_new = status_reg1;
					status_reg2_new = status_reg2;
					status_reg3_new = status_reg3;
					status_reg4_new = writedata;
					status_reg5_new = status_reg5;
					status_reg6_new = status_reg6;
					status_reg7_new = status_reg7;
				end
			4'd6: 
				begin 
					udp_send_reg_new = udp_send_reg;
					status_reg0_new = status_reg0;
					status_reg1_new = status_reg1;
					status_reg2_new = status_reg2;
					status_reg3_new = status_reg3;
					status_reg4_new = status_reg4;
					status_reg5_new = writedata;
					status_reg6_new = status_reg6;
					status_reg7_new = status_reg7;
				end
			4'd7: 
				begin 
					udp_send_reg_new = udp_send_reg;
					status_reg0_new = status_reg0;
					status_reg1_new = status_reg1;
					status_reg2_new = status_reg2;
					status_reg3_new = status_reg3;
					status_reg4_new = status_reg4;
					status_reg5_new = status_reg5;
					status_reg6_new = writedata;
					status_reg7_new = status_reg7;
				end
			4'd8: 
				begin 
					udp_send_reg_new = udp_send_reg;
					status_reg0_new = status_reg0;
					status_reg1_new = status_reg1;
					status_reg2_new = status_reg2;
					status_reg3_new = status_reg3;
					status_reg4_new = status_reg4;
					status_reg5_new = status_reg5;
					status_reg6_new = status_reg6;
					status_reg7_new = writedata;
				end

			default:
				begin 
					udp_send_reg_new = udp_send_reg;
					status_reg0_new = status_reg0;
					status_reg1_new = status_reg1;
					status_reg2_new = status_reg2;
					status_reg3_new = status_reg3;
					status_reg4_new = status_reg4;
					status_reg5_new = status_reg5;
					status_reg6_new = status_reg6;
					status_reg7_new = status_reg7;
				end 
		endcase
	else	/*	write does not enabled	*/
				begin 
					udp_send_reg_new = udp_send_reg;
					status_reg0_new = status_reg0;
					status_reg1_new = status_reg1;
					status_reg2_new = status_reg2;
					status_reg3_new = status_reg3;
					status_reg4_new = status_reg4;
					status_reg5_new = status_reg5;
					status_reg6_new = status_reg6;
					status_reg7_new = status_reg7;
				end 		
	
/*	Read operation	*/	
always @ (*)
	if (read)
		case(address)
			4'd0:	readdata_reg_new = udp_send_reg;
			4'd1: readdata_reg_new = status_reg0;
			4'd1: readdata_reg_new = status_reg1;
			4'd1: readdata_reg_new = status_reg2;
			4'd1: readdata_reg_new = status_reg3;
			4'd1: readdata_reg_new = status_reg4;
			4'd1: readdata_reg_new = status_reg6;
			4'd1: readdata_reg_new = status_reg7;
			default:
				readdata_reg_new = readdata;
		endcase
	else 
		readdata_reg_new = readdata;
		

/* Internal register */

always @ (posedge clk or negedge reset_n)
	if (reset_n == 1'b0)
		begin
			udp_send_reg <= 32'd0;
			status_reg0	<= 32'h0;
			status_reg1	<= 32'h0;
			status_reg2	<= 32'h0;
			status_reg3	<= 32'h0;
			status_reg4	<= 32'h0;
			status_reg5	<= 32'h0;
			status_reg6	<= 32'h0;
			status_reg7	<= 32'h0;
			readdata_reg		<= 32'b0;
		end
	else 
		begin
			udp_send_reg <= udp_send_reg_new;
			status_reg0	<= status_reg0_new;
			status_reg1	<= status_reg1_new;
			status_reg2	<= status_reg2_new;
			status_reg3	<= status_reg3_new;
			status_reg4	<= status_reg4_new;
			status_reg5	<= status_reg5_new;
			status_reg6	<= status_reg6_new;
			status_reg7	<= status_reg7_new;
			
			readdata_reg		<= readdata_reg_new;
		end

assign status_reg0_o = status_reg0;
assign status_reg1_o = status_reg1;
assign status_reg2_o = status_reg2;
assign status_reg3_o = status_reg3;
assign status_reg4_o = status_reg4;
assign status_reg5_o = status_reg5;
assign status_reg6_o = status_reg6;
assign status_reg7_o = status_reg7;

assign readdata = readdata_reg;

		
/*	udp_send pulse generation	*/
reg [1:0] s_int;
always @ (posedge clk or negedge reset_n)	
	if (reset_n == 0)
		s_int <= 2'b0;
	else
		s_int <= {s_int[0], udp_send_reg[0]};

assign udp_send = ~s_int[1] & s_int[0];
			
endmodule
