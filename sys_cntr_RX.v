module sys_cntr_RX (
input                       clk,
input                       rst,
input   [7:0]         RX_P_Data,
input             RX_Data_Valid,
output reg                  ALU_EN,
output reg [3:0]           ALU_FUN,
output reg [3:0]              Adrr,
output reg [7:0]            Wrdata,
output reg                WR_En,
output reg                RD_En,
output reg           clk_div_en,
output reg              Gate_En

);
//internal signals
reg  [3:0]              Adrr_reg;
reg  [7:0]            Wrdata_reg;
reg  [3:0]           ALU_FUN_reg;

//regstering outputs
always@(posedge clk or negedge rst)
begin
if(!rst)
  begin
           Adrr_reg      <= 0;
           Wrdata_reg    <= 0;
           ALU_FUN_reg   <= 0;
   end
else
    begin
           Adrr_reg      <=   Adrr;
           Wrdata_reg    <= Wrdata;
           ALU_FUN_reg   <=ALU_FUN;
	end
end
 



        //comands paramter
             localparam    [7:0]      IDEAL=8'h00,
			                       RF_WR_CM=8'hAA,
						           RF_RD_CM=8'hBB,
					       ALU_OPER_W_OP_CM=8'hCC,
					      ALU_OPER_W_NOP_CM=8'hDD;
       //states inside each command 
	         localparam  [3:0]  RF_Wr_Addr=4'b0001,
			                    RF_Wr_Data=4'b0010,
						        RF_Rd_Addr=4'b0011,
						   RF_RD_TEMP_Addr=4'b0100,
						        Operand_A =4'b0101,
						        Operand_B =4'b0110,
				             ALU_FUN_state=4'b0111,
					 //   ALU_FUN_TEMP_state=4'b1000,
						ALU_FUN_TEMP_NOP  =4'b1001;
							 
						
				    
	reg    [3:0]   next_state,current_state;
//transation state 
always@(posedge clk or negedge rst)
begin
 if(!rst)
  current_state<= IDEAL;
  else 
  current_state<= next_state;
end
//outputlogic&states
always@(*)
begin
/*
    ALU_EN=0;
  // ALU_FUN='b0000;
    //  Adrr='b0000;    //don't ititalize it by zero as the always will triger again and tooke the 0 as address
 //   Wrdata=0;
     WR_En=0;
     RD_En=0;
clk_div_en=1;
   Gate_En=0;
   */
  case(current_state)
	  
IDEAL :
  begin
    ALU_EN=0;
   ALU_FUN='b0000;
  Adrr='b0000;    
    Wrdata=0;
     WR_En=0;
     RD_En=0;
clk_div_en=1;
   Gate_En=0;
              if(RX_Data_Valid)
		case(RX_P_Data)
		        RF_WR_CM:  next_state =          RF_Wr_Addr;
		        RF_RD_CM:  next_state =          RF_Rd_Addr;
		ALU_OPER_W_OP_CM:  next_state =           Operand_A;
	   ALU_OPER_W_NOP_CM:  next_state =    ALU_FUN_TEMP_NOP; 
	  
	   
	  
	   
	      
	                       
			            
		  
	             default:  next_state = IDEAL;
        endcase				 
		       else 
		                   next_state = IDEAL;
	end

RF_Wr_Addr:
begin
                                              WR_En =          1;
						                      Adrr  =  RX_P_Data;                      
		  if(RX_Data_Valid)
		      begin
		                          
                           next_state = RF_Wr_Data;
                         end
						   
						   		   
		              else 
		                   next_state = RF_Wr_Addr;
						   
end

RF_Wr_Data:
begin
                    WR_En=          1;
							    Wrdata =  RX_P_Data;
        if(RX_Data_Valid)
        begin
                 
		                    next_state =      IDEAL;
		                    end
						      
		  else 
		                     next_state = RF_Wr_Data;
		  
end
RF_Rd_Addr:
begin
                                  RD_En=          1;
							     Adrr  =  RX_P_Data;
        if(RX_Data_Valid)
        begin
                 
		                    next_state = RF_RD_TEMP_Addr;
		                    end
						      
		  else 
		                     next_state =RF_Rd_Addr;
		  
end
RF_RD_TEMP_Addr:
begin
                                  RD_En=          1;
							     Adrr  =  RX_P_Data;
        if(RX_Data_Valid)
        begin
                 
		                    next_state = IDEAL;
		                    end
						      
		  else 
		                     next_state =RF_RD_TEMP_Addr;
		  
end



Operand_A:
begin
                                 WR_En=           1;
								Adrr  =      4'b0000;
							   Wrdata =   RX_P_Data;
							 Gate_En  =           1;
							// ALU_EN   =           1;
		  if(RX_Data_Valid)
		    
                           next_state =   Operand_B;
						  
						   
		 else 
		                   next_state =   Operand_A;
						   
end

Operand_B:
begin
                                 WR_En=           1;
								Adrr  =      4'b0001;
							    Wrdata=   RX_P_Data;
								ALU_EN=           1;
							 Gate_En  =           1;
							 
		  if(RX_Data_Valid)
		    
                           next_state =    ALU_FUN_state;
						       
						   
		 else 
		                   next_state =   Operand_B;
						   
end

ALU_FUN_TEMP_NOP :
begin
                        //  ALU_EN    =          1;
						//	ALU_FUN   =  RX_P_Data;
							Gate_En  =           1;
		  if(RX_Data_Valid)
		    
                           next_state = ALU_FUN_state;
						        
					
						   
		 else 
		                   next_state =  ALU_FUN_TEMP_NOP;
						   
end	

   		
ALU_FUN_state:
begin
                            ALU_EN    =          1;
							ALU_FUN   =  RX_P_Data;
							 Gate_En  =           1;
		  if(RX_Data_Valid)
		           next_state =IDEAL;
                         //  next_state = ALU_FUN_TEMP_state;
						        
					
						   
		 else 
		                   next_state =  ALU_FUN_state;
						   
end	
/*
ALU_FUN_TEMP_state:                                      //temp the output to capture it correctly 
begin
                                    //  ALU_EN    =          1;
					                //	ALU_FUN   =  RX_P_Data;
							             Gate_En  =          1;
		 // if(RX_Data_Valid)
		    
                           next_state =IDEAL;
						      					   
		// else 
		               //    next_state =  ALU_FUN_TEMP_state;						   
end	
*/
endcase	
		
		
		
		
end


						  
	                        

endmodule
