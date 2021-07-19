`timescale 10ns/1ns
module testbench();


reg clk=1'b0;
wire correct,Done;

checker2 c(clk,correct,Done);



initial
begin
#1160 $finish; 
end

always
begin
	clk=#10 !clk;
end


endmodule