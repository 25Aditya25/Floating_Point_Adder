module floating_point_adder(clk,add,number1,number2,result,ready);

input clk;
input add;
input [15:0] number1;
input [15:0] number2;
output reg [15:0] result;
output reg ready;

localparam RDY=3'b000,START=3'b001,NEGPOS=3'b010,OP=3'b011,SHIFT=3'b100,WRITE=3'b101,RSLT=3'b110;

reg [3:0] state = RDY;	//state variable
reg [41:0] bigreg;		//bigger value
reg [41:0] smallreg;	//smaller value
reg [41:0] resultreg;	
reg resultsign;
reg [4:0] resultshift;
reg [9:0] resultfrac;
reg [5:0] pos=0;

reg found;

integer bigshift;
integer smallshift;
reg [5:0] i;

always @ (posedge clk) 

case (state)
RDY:
	if (add) 
	begin
		bigreg <= {16'b0,1'b1,25'b0};		//initialize the big and small registers
		smallreg <= {16'b0,1'b1,25'b0};
		pos <= 6'b0;
		i <= 6'd41;							//initialize i to 41
		ready <= 0;
		state <= START;					//go to start state
		found<=1'b0;
	end
START:  
	begin
	if (number1[15] != number2[15]) //numbers with different sign
		if (number1[14:10] > number2[14:10]) //exponent num1 > num2 
		begin 
			bigreg[24:15] <= number1[9:0]; //store mantissa
			bigshift <= number1[14:10] - 4'b1111;
			resultsign <= number1[15];
			smallreg[24:15] <= number2[9:0];
			smallshift <= number2[14:10] - 4'b1111;
		end
		else if (number2[14:10] > number1[14:10])  //num2 > num1
		begin 
			bigreg[24:15] <= number2[9:0];
			bigshift <= number2[14:10] - 4'b1111;
			resultsign <= number2[15];
			smallreg[24:15] <= number1[9:0];
			smallshift <= number1[14:10] - 4'b1111;
		end
		else 											//same exponent		
		begin
			if (number1[9:0] > number2[9:0]) 				//number 1 mantissa bigger
			begin 
				bigreg[24:15] <= number1[9:0];
				bigshift <= number1[14:10] - 4'b1111;   //subtract the bias and get the real exponent
				resultsign <= number1[15];
				smallreg[24:15] <= number2[9:0];
				smallshift <= number2[14:10] - 4'b1111;
			end
			else if (number2[9:0] > number1[9:0])			//number 2 mantissa bigger
			begin 
				bigreg[24:15] <= number2[9:0];
				bigshift <= number2[14:10] - 4'b1111;
				resultsign <= number2[15];
				smallreg[24:15] <= number1[9:0];
				smallshift <= number1[14:10] - 4'b1111;
			end
			else result <= {2'b00,4'b1111,10'b0};  //mantissa and exponent both same & sign diff so 0
		end
	
	else 	//same sign
	begin 
		bigreg[24:15] <= number1[9:0];
		bigshift <= number1[14:10] - 4'b1111;
		resultsign <= number1[15];				//sign of result same as input
		smallreg[24:15] <= number2[9:0];
		smallshift <= number2[14:10] - 4'b1111;
	end
	state <= NEGPOS;
	end
NEGPOS: 
	begin
	if (bigshift > 0) 		//i.e there was initial shifting 
		bigreg <= bigreg << bigshift;  //shift the bigreg to get it back to the original value in decimal
	else bigreg <= bigreg >> ((~bigshift)+1);
	if (smallshift > 0) 				//shift the smallreg to get it back to the original value in decimal
		smallreg <= smallreg << smallshift;
	else smallreg <= smallreg >> ((~smallshift)+1);
	state <= OP;
	end
OP:     
	begin
	if (number1[15] != number2[15]) 
		resultreg = bigreg - smallreg;
	else 
		resultreg = bigreg + smallreg;
		state <= SHIFT;
	end
SHIFT:
	begin
		for(i=41;i>0;i=i-1)begin
			if(resultreg[i] == 1'b1 && found==1'b0)begin
				found=1'b1;
				pos=i;
			end
		end
		if(found==1'b0) pos=i;
		state = WRITE;
	end	
// 	if (resultreg[i] == 1'b1 || i == 0) begin 
//		pos = i;
//		state <= WRITE;
//	end
//	else i <= i - 1'b1; 
WRITE:  
	begin
		resultshift <= pos - 10;
		if (pos >= 11)
			resultfrac <= resultreg[pos-1 -: 10];   
		state <= RSLT; 
	end
RSLT:   
	begin
	result <= {resultsign,resultshift,resultfrac};
	ready <= 1'b1;
	state <= RDY;
	end
endcase

endmodule