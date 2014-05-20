
module av_eth_config (


	input clk,
	input reset_n,
	input write, 
	input read,
	input [31:0] writedata,
	input [3:0] address,
	
	// Output

	output [15:0] checksum_o,
	output [15:0] local_port_o,
	output [15:0] remote_port_o,
	
	output [31:0] local_IP_o,
	output [31:0] remote_IP_o,
	
	// MAC Address need 48 bits
	output [31:0] local_MAC_LSB_o,
	output [31:0] local_MAC_MSB_o,
	
	output [31:0] remote_MAC_LSB_o,
	output [31:0] remote_MAC_MSB_o,
	
	//Avalon-MM output
	output [31:0] readdata
	
	);
	
	
	
reg [31:0]	cheksum_reg_new, local_port_reg_new, remote_port_reg_new, local_IP_reg_new, remote_IP_reg_new;
reg [31:0]	local_MAC_LSB_reg_new, local_MAC_MSB_reg_new, remote_MAC_LSB_reg_new, remote_MAC_MSB_reg_new;

reg [31:0]	cheksum_reg, local_port_reg, remote_port_reg, local_IP_reg, remote_IP_reg;
reg [31:0]	local_MAC_LSB_reg, local_MAC_MSB_reg, remote_MAC_LSB_reg, remote_MAC_MSB_reg;

reg [31:0] readdata_reg, readdata_reg_new;

/*	Write operation	*/
always @ (*)
	if (write)
		case(address)
			4'd0:	
				begin
					cheksum_reg_new        = writedata;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					local_IP_reg_new       = local_IP_reg;
					remote_IP_reg_new      = remote_IP_reg;
					local_MAC_LSB_reg_new  = local_MAC_LSB_reg;
					local_MAC_MSB_reg_new  = local_MAC_MSB_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
					
			4'd1:
				begin	
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new      = writedata;
					remote_port_reg_new    = remote_port_reg;
					local_IP_reg_new       = local_IP_reg;
					remote_IP_reg_new      = remote_IP_reg;
					local_MAC_LSB_reg_new  = local_MAC_LSB_reg;
					local_MAC_MSB_reg_new  = local_MAC_MSB_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
					
			4'd2:	
				begin
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new     = writedata;
					local_IP_reg_new       = local_IP_reg;
					remote_IP_reg_new      = remote_IP_reg;
					local_MAC_LSB_reg_new  = local_MAC_LSB_reg;
					local_MAC_MSB_reg_new  = local_MAC_MSB_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
					
			4'd3:	
				begin
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					local_IP_reg_new        = writedata;
					remote_IP_reg_new      = remote_IP_reg;
					local_MAC_LSB_reg_new  = local_MAC_LSB_reg;
					local_MAC_MSB_reg_new  = local_MAC_MSB_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end	
				
			4'd4:	
				begin
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					local_IP_reg_new       = local_IP_reg;
					remote_IP_reg_new       = writedata;
					local_MAC_LSB_reg_new  = local_MAC_LSB_reg;
					local_MAC_MSB_reg_new  = local_MAC_MSB_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
					
			4'd5:	
				begin
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					local_IP_reg_new       = local_IP_reg;
					remote_IP_reg_new      = remote_IP_reg;
					local_MAC_LSB_reg_new   = writedata;
					local_MAC_MSB_reg_new  = local_MAC_MSB_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
			
			4'd6:	
				begin
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					local_IP_reg_new       = local_IP_reg;
					remote_IP_reg_new      = remote_IP_reg;
					local_MAC_LSB_reg_new  = local_MAC_LSB_reg;
					local_MAC_MSB_reg_new   = writedata;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
					
			4'd7:	
				begin
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					local_IP_reg_new       = local_IP_reg;
					remote_IP_reg_new      = remote_IP_reg;
					local_MAC_LSB_reg_new  = local_MAC_LSB_reg;
					local_MAC_MSB_reg_new  = local_MAC_MSB_reg;
					remote_MAC_LSB_reg_new  = writedata;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end
					
			4'd8:	
				begin
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					local_IP_reg_new       = local_IP_reg;
					remote_IP_reg_new      = remote_IP_reg;
					local_MAC_LSB_reg_new  = local_MAC_LSB_reg;
					local_MAC_MSB_reg_new  = local_MAC_MSB_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new  = writedata;
				end
			
			default:
				begin
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					local_IP_reg_new       = local_IP_reg;
					remote_IP_reg_new      = remote_IP_reg;
					local_MAC_LSB_reg_new  = local_MAC_LSB_reg;
					local_MAC_MSB_reg_new  = local_MAC_MSB_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
				end 
		endcase
	else	/*	write does not enabled	*/
		begin 
					cheksum_reg_new        = cheksum_reg;
					local_port_reg_new     = local_port_reg;
					remote_port_reg_new    = remote_port_reg;
					local_IP_reg_new       = local_IP_reg;
					remote_IP_reg_new      = remote_IP_reg;
					local_MAC_LSB_reg_new  = local_MAC_LSB_reg;
					local_MAC_MSB_reg_new  = local_MAC_MSB_reg;
					remote_MAC_LSB_reg_new = remote_MAC_LSB_reg;
					remote_MAC_MSB_reg_new = remote_MAC_MSB_reg;
		end		

/*	Read operation	*/	
always @ (*)
	if (read)
		case(address)
			4'd0:	readdata_reg_new = cheksum_reg;
			4'd1: readdata_reg_new = local_port_reg;
			4'd2: readdata_reg_new = remote_port_reg;
			4'd3: readdata_reg_new = local_IP_reg;
			4'd4: readdata_reg_new = remote_IP_reg;
			4'd5: readdata_reg_new = local_MAC_LSB_reg;
			4'd6: readdata_reg_new = local_MAC_MSB_reg;
			4'd7: readdata_reg_new = remote_MAC_LSB_reg;
			4'd8: readdata_reg_new = remote_MAC_MSB_reg;			
			default:
				readdata_reg_new = readdata;
		endcase
	else 
		readdata_reg_new = readdata;
		
		
		/* Internal register */

always @ (posedge clk or negedge reset_n)
	if (reset_n == 1'b0)
		begin // default Value 
			cheksum_reg          <= 32'h0000F957;
			local_port_reg       <= 32'h0000AAAA;
			remote_port_reg      <= 32'h0000FDE2;
			local_IP_reg         <= 32'hC0A80004; // 192.168.0.4
			remote_IP_reg        <= 32'hC0A80005; // 192.168.0.5
			local_MAC_LSB_reg    <= 32'h3A851BD7; // X"74EA3A851BD7";
			local_MAC_MSB_reg    <= 32'h000074EA;
		//	remote_MAC_LSB_reg   <= 32'h3A851BD8; // X"74EA3A851BD8";
		//	remote_MAC_MSB_reg   <= 32'h000074EA;
			remote_MAC_LSB_reg   <= 32'hFFFFFFFF; // X"74EA3A851BD8";
			remote_MAC_MSB_reg   <= 32'h0000FFFF;
			readdata_reg		   <= 32'd0;
		end
	else 
		begin
			cheksum_reg          <= cheksum_reg_new; 
			local_port_reg       <= local_port_reg_new;
			remote_port_reg      <= remote_port_reg_new ;
			local_IP_reg         <= local_IP_reg_new  ;
			remote_IP_reg        <= remote_IP_reg_new;
			local_MAC_LSB_reg    <= local_MAC_LSB_reg_new;
			local_MAC_MSB_reg    <= local_MAC_MSB_reg_new;
			remote_MAC_LSB_reg   <= remote_MAC_LSB_reg_new;
			remote_MAC_MSB_reg   <= remote_MAC_MSB_reg_new;
			readdata_reg		   <= readdata_reg_new;
		end



	assign readdata        = readdata_reg;
	assign checksum_o[15:0]      = cheksum_reg[15:0];
	assign local_port_o[15:0]    = local_port_reg[15:0];
	assign remote_port_o[15:0]   = remote_port_reg[15:0];
	assign local_IP_o      =  local_IP_reg;
	assign remote_IP_o     = remote_IP_reg;
	assign local_MAC_LSB_o = local_MAC_LSB_reg;
	assign local_MAC_MSB_o = local_MAC_MSB_reg;
	assign remote_MAC_LSB_o = remote_MAC_LSB_reg;
	assign remote_MAC_MSB_o = remote_MAC_MSB_reg;
	
endmodule

