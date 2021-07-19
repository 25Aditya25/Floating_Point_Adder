module checker2(input CLOCK_50,output LEDR);

	reg add;
	reg [15:0] number1,number2;
	wire [15:0] result;
	wire ready;
	
	parameter RDY=3'b000, waiting=3'b010, issue=3'b001, DONE=3'b011;
	
	
	reg [47:0] test [0:7];
	reg [15:0] expected_result;
	
	reg [2:0] state= RDY;
	reg [2:0] count=3'b000;
	
	reg Done,correct;
	
	assign LEDR[0]=Done;
	assign LEDR[1]=correct;
	
	initial
	begin
		add=1'b0;
		//Test cases
		test[0]={16'b0_10011_0001000000,16'b0_10011_0001000000,16'b0_10100_0001000000};
		test[1]={16'b0_10011_0001000000,16'b0_10011_0010000000,16'b0_10100_0001100000};//17+18=35
		test[2]={16'b0_10011_0001000000,16'b0_10011_0001000000,16'b0_10100_0001000000};
		test[3]={16'b0_10011_0001000000,16'b0_10011_0010000000,16'b0_10100_0001100000};//17+18=35
		test[4]={16'b0_10011_0001000000,16'b0_10011_0001000000,16'b0_10100_0001000000};
		test[5]={16'b0_10011_0001000000,16'b0_10011_0010000000,16'b0_10100_0001100000};//17+18=35
		test[6]={16'b0_10011_0001000000,16'b0_10011_0001000000,16'b0_10100_0001000000};
		test[7]={16'b0_10011_0001000000,16'b0_10011_0010000000,16'b0_10100_0001100000};//17+18=35
		
		correct=1'b0;
		Done=1'b0;
		number1=test[1][47:32];
		number2=test[1][31:16];
		expected_result=test[1][15:0];
		
		
		
	end
	
	floating_point_adder fpa(CLOCK_50,add,number1,number2,result,ready);
	
	always@(posedge CLOCK_50)
	begin
		case(state)
		RDY:
		begin
			//add=1'b1;
			state=issue;
		end
		
		issue:
		begin				
			number1=test[count][47:32];
			number2=test[count][31:16];
			expected_result=test[count][15:0];
			add=1'b1;
			count=count+1;
			state=waiting;
		end
				
		waiting:
		if(ready)
		begin
			if(result!=expected_result) 
			begin
				correct=1'b0;
				state=DONE;
			end
			else
			begin
				if(count==7) 
				begin
					state=DONE;
					correct=1'b1;
				end	
				else state=issue;
			end	
			add=1'b1;
		end
		else add=1'b0;
				
		
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