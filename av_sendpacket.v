
module av_sendpacket(

	input clk, 
	input reset_n, 

	
	//Avalon-MM inputs
	input [3:0] address,
	input write, 
	input read,
	input [31:0] writedata,
	
	//Avalon-MM output
	output [31:0] readdata,

	// Output
	output [15:0] checksum_o,
	output [15:0] local_port_o,
	output [15:0] remote_port_o,
	output [31:0] remote_IP_o,	
	output [31:0] remote_MAC_LSB_o,
	output [31:0] remote_MAC_MSB_o,

	output udp_sendpacket,
	output [15:0] length_o
	
);

reg [31:0]	cheksum_reg_new, local_port_reg_new, remote_port_reg_new, remote_IP_reg_new ,remote_MAC_LSB_reg_new, remote_MAC_MSB_reg_new;
reg [31:0]	cheksum_reg, local_port_reg, remote_port_reg, remote_IP_reg, remote_MAC_LSB_reg, remote_MAC_MSB_reg;
reg [31:0]  readdata_reg, readdata_reg_new;

reg [31:0] udp_sendpacket_reg;
reg [31:0] udp_sendpacket_reg_new;

/*	Write operation	*/
always @ (*)
	if (write)
		case(address)

			4'd0:	
				begin
					udp_sendpacket_reg_new = writedata;
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					remote_IP_reg_new      = remote_IP_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
				
			4'd1:	
				begin
					udp_sendpacket_reg_new = udp_sendpacket_reg;
					cheksum_reg_new        = writedata;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					remote_IP_reg_new      = remote_IP_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
					
			4'd2:
				begin	
					udp_sendpacket_reg_new = udp_sendpacket_reg;
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new      = writedata;
					remote_port_reg_new    = remote_port_reg;
					remote_IP_reg_new      = remote_IP_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
					
			4'd3:	
				begin
					udp_sendpacket_reg_new = udp_sendpacket_reg;
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new     = writedata;		
					remote_IP_reg_new      = remote_IP_reg;									
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
				
			4'd4:	
				begin
					udp_sendpacket_reg_new = udp_sendpacket_reg;
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;				
					remote_IP_reg_new       = writedata;									
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
	
			4'd5:	
				begin
					udp_sendpacket_reg_new = udp_sendpacket_reg;
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;			
					remote_IP_reg_new      = remote_IP_reg;			
					remote_MAC_LSB_reg_new  = writedata;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
					
			4'd6:	
				begin
					udp_sendpacket_reg_new = udp_sendpacket_reg;
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;			
					remote_IP_reg_new      = remote_IP_reg;					
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new  = writedata;
				end
			
			default:
				begin
					udp_sendpacket_reg_new = udp_sendpacket_reg;
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;		
					remote_IP_reg_new      = remote_IP_reg;					
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end 
		endcase
	else	/*	write does not enabled	*/
		begin 
					udp_sendpacket_reg_new = udp_sendpacket_reg;
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					remote_IP_reg_new      = remote_IP_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
		end		

	
	
/*	Read operation	*/	
always @ (*)
	if (read)
		case(address)
			4'd0:	readdata_reg_new = udp_sendpacket_reg;
			4'd1:	readdata_reg_new = cheksum_reg;
			4'd2: readdata_reg_new = local_port_reg;
			4'd3: readdata_reg_new = remote_port_reg;		
			4'd4: readdata_reg_new = remote_IP_reg;
			4'd5: readdata_reg_new = remote_MAC_LSB_reg;
			4'd6: readdata_reg_new = remote_MAC_MSB_reg;			
			default:
				readdata_reg_new = readdata;
		endcase
	else 
		readdata_reg_new = readdata;
		
				/* Internal register */
always @ (posedge clk or negedge reset_n)
	if (reset_n == 1'b0)
		begin // default Value 
			udp_sendpacket_reg 	<= 32'h02000000;
			cheksum_reg          <= 32'h00000BFF;
			local_port_reg       <= 32'h0000AAAA;
			remote_port_reg      <= 32'h0000FDE2;
			remote_IP_reg        <= 32'hac1b01eb; // 192.168.0.5		
			remote_MAC_LSB_reg   <= 32'hd93049d0; // X"74EA3A851BD8"; d4bd d930 49d0
			remote_MAC_MSB_reg   <= 32'h0000d4bd;
			readdata_reg		   <= 32'd0;
		end
	else 
		begin
			udp_sendpacket_reg	<= udp_sendpacket_reg_new;
			cheksum_reg          <= cheksum_reg_new; 
			local_port_reg       <= local_port_reg_new;
			remote_port_reg      <= remote_port_reg_new ;
			remote_IP_reg        <= remote_IP_reg_new;
			remote_MAC_LSB_reg   <= remote_MAC_LSB_reg_new;
			remote_MAC_MSB_reg   <= remote_MAC_MSB_reg_new;
			readdata_reg		   <= readdata_reg_new;
		end
	
	
	assign readdata        = readdata_reg;
	assign checksum_o[15:0]      = cheksum_reg[15:0];
	assign local_port_o[15:0]    = local_port_reg[15:0];
	assign remote_port_o[15:0]   = remote_port_reg[15:0];
	assign remote_IP_o     = remote_IP_reg;
	assign remote_MAC_LSB_o = remote_MAC_LSB_reg;
	assign remote_MAC_MSB_o = remote_MAC_MSB_reg;
	
	assign length_o[15:0] = udp_sendpacket_reg[31:15];
		
/*	udp_sendpacket pulse generation	*/
reg [1:0] s_int;
always @ (posedge clk or negedge reset_n)	
	if (reset_n == 0)
		s_int <= 2'b0;
	else
		s_int <= {s_int[0], udp_sendpacket_reg[0]};

assign udp_sendpacket = ~s_int[1] & s_int[0];
			
endmodule
