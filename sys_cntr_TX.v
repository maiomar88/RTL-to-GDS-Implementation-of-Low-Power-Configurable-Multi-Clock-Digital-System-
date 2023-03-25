module sys_cntr_TX (
input                              clk,
input                              rst,
input       [15:0]             ALU_OUT,
input                        ALU_Valid,
input       [7:0]               RDdata,
input                     RDdata_Valid,
input                        busy_sync,   
output reg               TX_Data_Valid, 
output reg  [7:0]            TX_P_Data
);

   localparam [2:0]           IDEAL =3'b000,
                       ALU_1ST_Frame=3'b001,
					   ALU_2nd_Frame=3'b010,
					  ALU_TEMP_Frame=3'b011,
					    RDdata_Frame=3'b100;
						
reg  [2:0]	      current_state,next_state;

//transation state 
always@(posedge clk or negedge rst)
begin
 if(!rst)
  current_state<= IDEAL;
  else 
  current_state<= next_state;
end
 //outputlogic$state
 always@(*)
 begin
TX_Data_Valid = 0;
TX_P_Data     = 'h00;
  
       case(current_state)
 IDEAL: 
	  begin
	   //  if(!busy_sync )
		// begin
		     if(RDdata_Valid)
		   begin
		   next_state=RDdata_Frame;
		   end
		     else if (ALU_Valid)
			   next_state=ALU_1ST_Frame;
			  else
			   next_state=IDEAL;
		   end
	// end
	  
ALU_1ST_Frame:
begin
      TX_Data_Valid = 1;
      TX_P_Data     = ALU_OUT[7:0];
	  
           if(!busy_sync )
		     next_state=ALU_TEMP_Frame;
			else 
			 next_state=ALU_1ST_Frame;
		   
end
ALU_TEMP_Frame:
begin
      TX_Data_Valid = 1;
      TX_P_Data     = 0;
	  
           if(!busy_sync )
		     next_state=ALU_2nd_Frame;
			else 
			 next_state=ALU_TEMP_Frame;
		   
end


ALU_2nd_Frame:
begin
       TX_Data_Valid = 1;
       TX_P_Data     = ALU_OUT[15:7];
	   
            if(!busy_sync )
		     next_state=IDEAL;
			else 
			 next_state=ALU_2nd_Frame;
end
RDdata_Frame:
begin
      TX_Data_Valid = 1;
      TX_P_Data     = RDdata_Frame;
	  
            if(!busy_sync )
		     next_state=IDEAL;
			else 
			 next_state=RDdata_Frame;
end
			 
 
 
 endcase

 end
 
 endmodule
 
