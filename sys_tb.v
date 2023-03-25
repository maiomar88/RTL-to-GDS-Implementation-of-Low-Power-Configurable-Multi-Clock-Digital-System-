`timescale 1ns/1ps
module sys_top_tb #(parameter DATA_WIDTH = 8 ,  RF_ADDR = 4 ) ();

reg                            RST_N_TB;
reg                         UART_CLK_TB;
reg                          REF_CLK_TB;
reg                       UART_RX_IN_TB;
wire                       UART_TX_O_TB;
wire                    parity_error_TB;
wire                  framing_error_TB ;
//tx_Master clk
reg                        TX_Master_clk;  
reg      [6:0]                ser_count;     
//reg      [32:0]             DATA_RF_WR=33'b11_00000111_0_11_00000100_0_10_10101010_0; //EVEN PARITY
//reg      [21:0]             DATA_RF_RD=22'b11_00000100_0_10_10111011_0; //EVEN PARITY
//reg        [43:0]          DATA_ALU_OP=44'b11_0000_0001_0_11_0000_0010_0_11_0000_1000_0_10_1100_1100_0;    //CC_alufun=0001 means minus ,alu_out=6
//reg        [43:0]            DATA_ALU_OP=44'b11_0000_0010_0_11_0000_0010_0_11_0000_1000_0_10_1100_1100_0;  //CC_ALUFUN=0010 means mul , alu_out=16
//reg      [21:0]          ALU_OPER_W_NOP_CM=22'b10_0000_0101_0_10_1101_1101_0;                                //DD_ALUFUN=0101 means OR
//reg  [87:0]   WRITE_ALU_NOP ='b11_0000_0010_0_10_1101_1101_0_10_0000_0110_0_11_0000_0001_0_10_1010_1010_0_10_0000_0101_0_10_0000_0000_0_10_1010_1010_0; //ALU_0UT=30
reg    [65:0]  ALU_WITH_OP_ALUWITH_NOP ='b11_0000_0001_0_10_1101_1101_0_11_0000_0010_0_11_0000_0010_0_10_0000_1010_0_10_1100_1100_0; //alu_out=20,8
reg                   CM_WR_DONE;           //check write
initial
begin
RST_N_TB=1;
UART_CLK_TB=0;
REF_CLK_TB =0;
UART_RX_IN_TB=1;
TX_Master_clk=0;
CM_WR_DONE   =0;
//DATA =0;

repeat(8)@(posedge  TX_Master_clk);
RST_N_TB =0;
repeat(8)@(posedge  TX_Master_clk);
RST_N_TB =1;





repeat(100)@(posedge TX_Master_clk);
$stop;

end


// COMM 
 always@(negedge TX_Master_clk or negedge RST_N_TB)
   begin
  if(!RST_N_TB)
   begin
    ser_count    <=7'b0;
    UART_RX_IN_TB<=1'b1;
   end
  else  
  begin
 
    if(ser_count < 7'd66 && CM_WR_DONE==0)
	begin
      UART_RX_IN_TB<= ALU_WITH_OP_ALUWITH_NOP[ser_count];
          ser_count<=ser_count+1;
		  end
		else if (ser_count == 7'd65)
		 begin
		  CM_WR_DONE   <=1;	
         ser_count     <=7'b0;
		 
		
		 end
		 
 		
            		  
   end
   end

//CLK_GEN
always    #10                         REF_CLK_TB   =~ REF_CLK_TB ;
always   /* #52083.33 */    #20     UART_CLK_TB  =~ UART_CLK_TB;            //rxclk
always /* #416666.64*/      #160      TX_Master_clk=~TX_Master_clk;           //txclk




//DUT INSTANTION
SYS_TOP #(.DATA_WIDTH(DATA_WIDTH),.RF_ADDR(RF_ADDR) ) 
SYS_TOP_DUT (
.RST_N(RST_N_TB),.UART_CLK(UART_CLK_TB),.REF_CLK(REF_CLK_TB),
.UART_RX_IN(UART_RX_IN_TB),.UART_TX_O(UART_TX_O_TB),
.parity_error(parity_error_TB),.framing_error(framing_error_TB )
);
endmodule