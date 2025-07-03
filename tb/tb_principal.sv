`timescale 1ns / 1ps

module tb_principal;

logic clk ;
logic nrst ;
logic [15:0] led ;

parameter CLOCK_PERIOD = 6 ;

principal DUT ( 
    .clk(clk),
    .nrst(nrst),
	.led(led)
) ;

initial begin
    clk =0 ;
	repeat (10000) begin
		#(CLOCK_PERIOD/2) clk = ~clk;
	end
end   

initial begin
    nrst = 1 ;
    #3 ;
    nrst = 0 ;
    #20 ;
    nrst = 1 ;
end

    
endmodule
