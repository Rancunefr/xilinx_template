`timescale 1ns / 1ps

module tb_principal;

logic clk ;
logic nrst ;

parameter CLOCK_PERIOD = 6 ;

principal DUT_principal ( 
    .clk(clk),
    .nrst(nrst)
) ;
        
        
initial begin
    clk <=0 ;
	repeat (100) begin
		#(CLOCK_PERIOD/2) clk <= ~clk;
	end
end   

initial begin
    nrst <= 1 ;
    #3 ;
    nrst <= 0 ;
    #6 ;
    nrst <= 1 ;
 end ;     
    
endmodule
