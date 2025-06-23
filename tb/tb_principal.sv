`timescale 1ns / 1ps

module tb_principal;

logic simu_clk ;
logic simu_nrst ;
logic [7:0] simu_led ;

parameter CLOCK_PERIOD = 6 ;

principal DUT_principal ( 
    .clk(simu_clk),
    .nrst(simu_nrst),
	.led(simu_led)
) ;

initial begin
    simu_clk =0 ;
	repeat (10000) begin
		#(CLOCK_PERIOD/2) simu_clk = ~simu_clk;
	end
end   

initial begin
    simu_nrst = 1 ;
    #3 ;
    simu_nrst = 0 ;
    #20 ;
    simu_nrst = 1 ;
 end ;     
    
endmodule
