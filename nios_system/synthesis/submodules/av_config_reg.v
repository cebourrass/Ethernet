
module av_config_reg(

	input clk, 
	input reset_n, 

	
	//Avalon-MM inputs
	input [3:0] address,
	input write, 
	input read,
	input [31:0] writedata,
	
	input [31:0] reg_0,
	input [31:0] reg_1,
	input [31:0] reg_2,
	input [31:0] reg_3,
	input [31:0] reg_4,
	input [31:0] reg_5,
	input [31:0] reg_6,
	input [31:0] reg_7,
	input udp_data_valid,
	

	//Avalon-MM output
	output [31:0] readdata,
	
	output av_irq
);

reg [31:0] control_reg;
reg [31:0] control_reg_new;

reg [31:0] readdata_reg, readdata_reg_new;

/*	Write operation	*/
always @ (*)
	if (write)
		case(address)
			4'b0:	control_reg_new = writedata;
			default:
				begin
					control_reg_new = control_reg;
				end 
		endcase
	else	/*	write does not enabled	*/
		begin 
			control_reg_new = control_reg;
		end		
	
/*	Read operation	*/	
always @ (*)
	if (read)
		case(address)
			4'd0:	readdata_reg_new = control_reg;
			4'd1: readdata_reg_new = reg0_int;
			4'd2: readdata_reg_new = reg1_int;
			4'd3: readdata_reg_new = reg2_int;
			4'd4: readdata_reg_new = reg3_int;
			4'd5: readdata_reg_new = reg4_int;
			4'd6: readdata_reg_new = reg5_int;
			4'd7: readdata_reg_new = reg6_int;
			4'd8: readdata_reg_new = reg7_int;
			default:
				readdata_reg_new = readdata;
		endcase
	else 
		readdata_reg_new = readdata;
		
always @ (posedge clk or negedge reset_n)
	if (reset_n == 1'b0)		
		readdata_reg <= 32'd0;
	else 
		readdata_reg <= readdata_reg_new;
		
assign readdata = readdata_reg;
		

/* Internal register */

reg [31:0] reg0_int;
reg [31:0] reg1_int;
reg [31:0] reg2_int;
reg [31:0] reg3_int;
reg [31:0] reg4_int;
reg [31:0] reg5_int;
reg [31:0] reg6_int;
reg [31:0] reg7_int;		
			
/* reg_int copy of the external reg*/
always @ (posedge clk or negedge reset_n)
	if (reset_n == 1'b0)
		begin
			reg0_int <= 32'd00;
			reg1_int <= 32'd00;
			reg2_int <= 32'd00;
			reg3_int <= 32'd00;
			reg4_int <= 32'd00;
			reg5_int <= 32'd00;
			reg6_int <= 32'd00;
			reg7_int <= 32'd00;
		end
	else 
		if (udp_data_valid && ~control_reg[2])
			begin
				reg0_int <= reg_0;
				reg1_int <= reg_1;
				reg2_int <= reg_2;
				reg3_int <= reg_3;
				reg4_int <= reg_4;
				reg5_int <= reg_5;
				reg6_int <= reg_6;
				reg7_int <= reg_7;
			end
		else
			begin
				reg0_int <= reg0_int;
				reg1_int <= reg1_int;
				reg2_int <= reg2_int;
				reg3_int <= reg3_int;
				reg4_int <= reg4_int;
				reg5_int <= reg5_int;
				reg6_int <= reg6_int;
				reg7_int <= reg7_int;
			end
			
		
				
				
always @ (posedge clk or negedge reset_n)
	if (reset_n == 1'b0)
		begin				
			control_reg <= 32'd0;
		end
	else
		begin
			control_reg[0] <= udp_data_valid;
			control_reg[1] <= new_data;
			control_reg[2] <= control_reg_new[2];
			control_reg[31:3] <= 28'd0;
		end
				
				
				
reg new_data;
always @ (posedge clk or negedge reset_n)
	if (reset_n == 1'b0)
		new_data <= 1'd0;
	else
		if(udp_pulse)
			new_data <= 1'b1;
		else if (ro_pulse)
			new_data <= 1'b0;
		else 
			new_data <= new_data;
			
assign av_irq = new_data;				

		
/*	data valid pulse generation	*/
reg [1:0] dv_int;
always @ (posedge clk or negedge reset_n)	
	if (reset_n == 0)
		dv_int <= 2'b0;
	else
		dv_int <= {dv_int[0], udp_data_valid};
		
wire udp_pulse;
assign udp_pulse = ~dv_int[1] & dv_int[0];

/*	ro pulse generation	*/
reg [1:0] ro_int;
always @ (posedge clk or negedge reset_n)	
	if (reset_n == 0)
		ro_int <= 2'b0;
	else
		ro_int <= {ro_int[0], control_reg[2]};
		
wire ro_pulse;
assign ro_pulse = ~ro_int[0] & ro_int[1];
			
endmodule

