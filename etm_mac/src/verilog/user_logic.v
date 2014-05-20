//----------------------------------------------------------------------------
// user_logic.vhd - module
//----------------------------------------------------------------------------
//
// ***************************************************************************
// ** Copyright (c) 1995-2007 Xilinx, Inc.  All rights reserved.            **
// **                                                                       **
// ** Xilinx, Inc.                                                          **
// ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
// ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
// ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
// ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
// ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
// ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
// ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
// ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
// ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
// ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
// ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
// ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
// ** FOR A PARTICULAR PURPOSE.                                             **
// **                                                                       **
// ***************************************************************************
//
//----------------------------------------------------------------------------
// Filename:          user_logic.vhd
// Version:           1.00.a
// Description:       User logic module.
// Date:              Sun Aug 03 07:06:59 2008 (by Create and Import Peripheral Wizard)
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------

module user_logic
(
  // -- ADD USER PORTS BELOW THIS LINE ---------------
  //Phy interface         
  Gtx_clk                 ,//used only in GMII mode
  Rx_clk                  ,
  Tx_clk                  ,//used only in MII mode
  Tx_er                   ,
  Tx_en                   ,
  Txd                     ,
  Rx_er                   ,
  Rx_dv                   ,
  Rxd                     ,
  Crs                     ,
  Col                     ,  
  //mdx
  Mdo,  
  MdoEn,
  Mdi, 
  Mdc                     ,// MII Management Data Clock   
  // -- ADD USER PORTS ABOVE THIS LINE ---------------

  // -- DO NOT EDIT BELOW THIS LINE ------------------
  // -- Bus protocol ports, do not add to or delete 
  Bus2IP_Clk,                     // Bus to IP clock
  Bus2IP_Reset,                   // Bus to IP reset
  Bus2IP_Addr,                    // Bus to IP address bus
  Bus2IP_CS,                      // Bus to IP chip select for user logic memory selection
  Bus2IP_RNW,                     // Bus to IP read/not write
  Bus2IP_Data,                    // Bus to IP data bus
  Bus2IP_BE,                      // Bus to IP byte enables
  IP2Bus_Data,                    // IP to Bus data bus
  IP2Bus_RdAck,                   // IP to Bus read transfer acknowledgement
  IP2Bus_WrAck,                   // IP to Bus write transfer acknowledgement
  IP2Bus_Error                    // IP to Bus error response
  // -- DO NOT EDIT ABOVE THIS LINE ------------------
); // user_logic

// -- ADD USER PARAMETERS BELOW THIS LINE ------------
// --USER parameters added here 
// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_SLV_AWIDTH                   = 32;
parameter C_SLV_DWIDTH                   = 32;
parameter C_NUM_MEM                      = 1;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

// -- ADD USER PORTS BELOW THIS LINE -----------------
                //Phy interface         
output          Gtx_clk                 ;//used only in GMII mode                           
input           Rx_clk                  ;                                                   
input           Tx_clk                  ;//used only in MII mode                            
output          Tx_er                   ;                                                   
output          Tx_en                   ;                                                   
output  [7:0]   Txd                     ;                                                   
input           Rx_er                   ;                                                   
input           Rx_dv                   ;                                                   
input   [7:0]   Rxd                     ;                                                   
input           Crs                     ;                                                   
input           Col                     ;                                                   
output          Mdo;                // MII Management Data Output
output          MdoEn;              // MII Management Data Output Enable
input           Mdi;                       
output          Mdc                     ;// MII Management Data Clock                       
// -- ADD USER PORTS ABOVE THIS LINE -----------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol ports, do not add to or delete
input                                     Bus2IP_Clk;
input                                     Bus2IP_Reset;
input      [0 : C_SLV_AWIDTH-1]           Bus2IP_Addr;
input      [0 : C_NUM_MEM-1]              Bus2IP_CS;
input                                     Bus2IP_RNW;
input      [0 : C_SLV_DWIDTH-1]           Bus2IP_Data;
input      [0 : C_SLV_DWIDTH/8-1]         Bus2IP_BE;
output     [0 : C_SLV_DWIDTH-1]           IP2Bus_Data;
output                                    IP2Bus_RdAck;
output                                    IP2Bus_WrAck;
output                                    IP2Bus_Error;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

//----------------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------------
// --USER nets declarations added here as needed for user logic
wire  [2:0]   Speed                   ;
wire          Rx_mac_ra               ;
reg           Rx_mac_rd               ;
wire  [31:0]  Rx_mac_data             ;
wire  [1:0]   Rx_mac_BE               ;
wire          Rx_mac_pa               ;
wire          Rx_mac_sop              ;
wire          Rx_mac_eop              ;
wire          Tx_mac_wa               ;
reg           Tx_mac_wr               ;
reg   [31:0]  Tx_mac_data             ;
reg   [1:0]   Tx_mac_BE               ;//big endian
reg           Tx_mac_sop              ;
reg           Tx_mac_eop              ;
reg           Pkg_lgth_fifo_rd        ;
wire          Pkg_lgth_fifo_ra        ;
wire  [15:0]  Pkg_lgth_fifo_data      ;

wire           CSB                    ;
wire           WRB                    ;
wire   [15:0]  CD_in                  ;
wire   [15:0]  CD_out                 ;
wire   [31:0]  CD_in_2                ;
reg    [31:0]  CD_out_2               ;
wire   [7:0]   CA                     ;   
reg            IP2Bus_RdAck;
reg            IP2Bus_RdAck_tmp;
reg            IP2Bus_RdAck_tmp_pl1;
reg            IP2Bus_RdAck_tmp_pl2;
reg    [4:0]   rx_fifo_ctrl_reg       ;
// --USER logic implementation added here

// ------------------------------------------------------------
// Example code to drive IP to Bus signals
// ------------------------------------------------------------
assign CSB = ~(Bus2IP_CS[0]&&!Bus2IP_Addr[22]);
assign WRB = Bus2IP_RNW;
assign IP2Bus_Error   = 0;
assign CD_in[7:0]       =Bus2IP_Data[24:31];
assign CD_in[15:8]      =Bus2IP_Data[16:23];
assign CD_in_2[7:0]     =Bus2IP_Data[24:31]; 
assign CD_in_2[15:8]    =Bus2IP_Data[16:23]; 
assign CD_in_2[23:16]   =Bus2IP_Data[8:15]; 
assign CD_in_2[31:24]   =Bus2IP_Data[0:7]; 
assign IP2Bus_Data = Bus2IP_Addr[22]?{CD_out_2[31:24],CD_out_2[23:16],CD_out_2[15:8],CD_out_2[7:0]}:{16'b0,CD_out[15:8],CD_out[7:0]};
assign CA = Bus2IP_Addr[23:30];
assign IP2Bus_WrAck = Bus2IP_CS[0]& !Bus2IP_RNW;

always @(posedge Bus2IP_Reset or posedge Bus2IP_Clk)
    if (Bus2IP_Reset)
        IP2Bus_RdAck_tmp    <=0;
    else if (Bus2IP_CS[0]& Bus2IP_RNW)
        IP2Bus_RdAck_tmp    <=1;
    else
        IP2Bus_RdAck_tmp    <=0;
        
always @(posedge Bus2IP_Reset or posedge Bus2IP_Clk)
    if (Bus2IP_Reset)
        begin
        IP2Bus_RdAck_tmp_pl1    <=0;
        IP2Bus_RdAck_tmp_pl2    <=0;
        end
    else
        begin
        IP2Bus_RdAck_tmp_pl1    <=IP2Bus_RdAck_tmp;
        IP2Bus_RdAck_tmp_pl2    <=IP2Bus_RdAck_tmp_pl1;
        end

always @(posedge Bus2IP_Reset or posedge Bus2IP_Clk)
    if (Bus2IP_Reset)
        IP2Bus_RdAck    <=0;
    else if (IP2Bus_RdAck_tmp_pl1&&!IP2Bus_RdAck_tmp_pl2)
        IP2Bus_RdAck    <=1;
    else
        IP2Bus_RdAck    <=0;       

//---------------------------------------------------
// write signals 
//---------------------------------------------------        
                
          
always @(posedge Bus2IP_Reset or posedge Bus2IP_Clk)
    if (Bus2IP_Reset)          
        {Tx_mac_sop,Tx_mac_eop,Tx_mac_BE}       <=0;          
    else if(Bus2IP_CS[0]&& !Bus2IP_RNW &&Bus2IP_Addr[22:29]==8'h82)    
        {Tx_mac_sop,Tx_mac_eop,Tx_mac_BE}       <=CD_in_2[3:0];
 
always @(posedge Bus2IP_Reset or posedge Bus2IP_Clk)
    if (Bus2IP_Reset)          
        Tx_mac_data       <=0;          
    else if(Bus2IP_CS[0]&& !Bus2IP_RNW &&Bus2IP_Addr[22:29]==8'h84)    
        Tx_mac_data       <=CD_in_2;        


always @(posedge Bus2IP_Reset or posedge Bus2IP_Clk)
    if (Bus2IP_Reset)
        rx_fifo_ctrl_reg    <=0;
    else if(Bus2IP_CS[0]&&IP2Bus_RdAck&&Bus2IP_Addr[22:29]==8'h85)
        rx_fifo_ctrl_reg    <={Rx_mac_sop,Rx_mac_eop,Rx_mac_BE,Rx_mac_pa};   
 
always @(*)
    if(Bus2IP_CS[0]&&IP2Bus_RdAck&&Bus2IP_Addr[22:29]==8'h81)
        Pkg_lgth_fifo_rd    =1;
    else
        Pkg_lgth_fifo_rd    =0;        

always @(posedge Bus2IP_Reset or posedge Bus2IP_Clk)
    if (Bus2IP_Reset)
        Tx_mac_wr    <=0;
    else if(Bus2IP_CS[0]&&IP2Bus_WrAck &&Bus2IP_Addr[22:29]==8'h84)
        Tx_mac_wr    <=1;
    else
        Tx_mac_wr    <=0;  

always @(*)
    if(Bus2IP_CS[0]&&!IP2Bus_RdAck_tmp&&Bus2IP_Addr[22:29]==8'h85)
        Rx_mac_rd    =1;
    else
        Rx_mac_rd    =0;           
           
always @(posedge Bus2IP_Reset or posedge Bus2IP_Clk)
    if (Bus2IP_Reset) 
          CD_out_2  <=0;
    else if(Bus2IP_CS[0]& Bus2IP_RNW)
        case (Bus2IP_Addr[22:29])
            8'h80   :    CD_out_2  <={Pkg_lgth_fifo_ra,Tx_mac_wa,Rx_mac_ra};  
            8'h81   :    CD_out_2  <={16'b0,Pkg_lgth_fifo_data};
            8'h82   :    CD_out_2  <={13'b0,Tx_mac_sop,Tx_mac_eop,Tx_mac_BE};  
            8'h83   :    CD_out_2  <={11'b0,rx_fifo_ctrl_reg};  
            8'h84   :    CD_out_2  <=Tx_mac_data;   
            8'h85   :    CD_out_2  <=Rx_mac_data;  
            default :    CD_out_2  <=32'b0;  
        endcase
        
        


// do synthesis attribute box_type of MAC_top is user_black_box;
MAC_top U_MAC_top (
.Reset                      (Bus2IP_Reset              ),               
.Clk_125M                   (Bus2IP_Clk                 ),
.Clk_user                   (Bus2IP_Clk                 ),
.Clk_reg                    (Bus2IP_Clk                 ),
.Speed                      (Speed                      ),
//user interface            (//user interface           ),
.Rx_mac_ra                  (Rx_mac_ra                  ),
.Rx_mac_rd                  (Rx_mac_rd                  ),
.Rx_mac_data                (Rx_mac_data                ),
.Rx_mac_BE                  (Rx_mac_BE                  ),
.Rx_mac_pa                  (Rx_mac_pa                  ),
.Rx_mac_sop                 (Rx_mac_sop                 ),
.Rx_mac_eop                 (Rx_mac_eop                 ),
//user interface            (//user interface           ),
.Tx_mac_wa                  (Tx_mac_wa                  ),
.Tx_mac_wr                  (Tx_mac_wr                  ),
.Tx_mac_data                (Tx_mac_data                ),
.Tx_mac_BE                  (Tx_mac_BE                  ),
.Tx_mac_sop                 (Tx_mac_sop                 ),
.Tx_mac_eop                 (Tx_mac_eop                 ),
//pkg_lgth fifo             (//pkg_lgth fifo            ),
.Pkg_lgth_fifo_rd           (Pkg_lgth_fifo_rd           ),
.Pkg_lgth_fifo_ra           (Pkg_lgth_fifo_ra           ),
.Pkg_lgth_fifo_data         (Pkg_lgth_fifo_data         ),
//Phy interface             (//Phy interface            ),
.Gtx_clk                    (Gtx_clk                    ),
.Rx_clk                     (Rx_clk                     ),
.Tx_clk                     (Tx_clk                     ),
.Tx_er                      (Tx_er                      ),
.Tx_en                      (Tx_en                      ),
.Txd                        (Txd                        ),
.Rx_er                      (Rx_er                      ),
.Rx_dv                      (Rx_dv                      ),
.Rxd                        (Rxd                        ),
.Crs                        (Crs                        ),
.Col                        (Col                        ),
//host interface            (//host interface           ),
.CSB                        (CSB                        ),
.WRB                        (WRB                        ),
.CD_in                      (CD_in                      ),
.CD_out                     (CD_out                     ),
.CA                         (CA                         ),
//mdx                       (//mdx                      ),
.Mdo                        (Mdo                        ),
.MdoEn                      (MdoEn                      ),
.Mdi                        (Mdi                        ),
.Mdc                        (Mdc                        ));

endmodule
