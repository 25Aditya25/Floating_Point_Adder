module checker(input clk,output reg correct,Done);

	reg add;
	reg [15:0] number1,number2;
	wire [15:0] result;
	wire ready;
	
	parameter RDY=3'b000, case1=3'b001, case2=3'b010, case3=3'b011, case4=3'b100, case5=3'b101, case6=3'b110, DONE=3'b111;
	
	reg [47:0] test [1:7];
	reg [15:0] expected_result;
	
	reg [2:0] state= RDY;
	
	
	
	initial
	begin
		add=1'b0;
		//Test cases
		test[case1]={16'b0_10011_0001000000,16'b0_10011_0010000000,16'b0_10100_0001100000};//17+18=35
		test[case2]={16'b0_10011_0001000000,16'b0_10011_0001000000,16'b0_10100_0001000000};
		test[case3]={16'b0_10011_0001000000,16'b0_10011_0010000000,16'b0_10100_0001100000};//17+18=35
		test[case4]={16'b0_10011_0001000000,16'b0_10011_0001000000,16'b0_10100_0001000000};
		test[case5]={16'b0_10011_0001000000,16'b0_10011_0010000000,16'b0_10100_0001100000};//17+18=35
		test[case6]={16'b0_10011_0001000000,16'b0_10011_0001000000,16'b0_10100_0001000000};
	
		
		correct=1'b0;
		Done=1'b0;
		number1=test[case1][47:32];
		number2=test[case1][31:16];
		expected_result=test[case1][15:0];
		
		
		
	end
	
	floating_point_adder fpa(clk,add,number1,number2,result,ready);
	
	always@(posedge clk)
	begin
		case(state)
		RDY:
		begin
			//add=1'b1;
			state=case1;
		end
		
		case1:
		if(ready)
		begin
			if(result!=expected_result) 
			begin
				correct=1'b0;
				state=DONE;
			end
			else
			begin
				state=case2;
			end	
			
			number1=test[case2][47:32];
			number2=test[case2][31:16];
			expected_result=test[case2][15:0];
			add=1'b1;	

			
		end
		else add=1'b1;
		
		case2:
		if(ready)
		begin
			if(result!=expected_result) 
			begin
				correct=1'b0;
				state=DONE;
			end
			else
			begin
				state=case3;
			end	
			
			number1=test[case3][47:32];
			number2=test[case3][31:16];
			expected_result=test[case3][15:0];
			add=1'b1;	

			
		end
		else add=1'b1;
		
		
		
		case3:
		if(ready)
		begin
			if(result!=expected_result) 
			begin
				correct=1'b0;
				state=DONE;
			end
			else
			begin
				correct=1'b1;
				state=DONE;
				add=1'b0;
			end
		end
		
		
		DONE:
		begin
			Done=1'b1;
		end
		default:
		begin
			add=1'b0;
		end
		endcase
	end
	
	
	
	
endmodule