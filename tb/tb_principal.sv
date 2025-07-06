`timescale 1ns / 1ps

module tb_principal;

logic clk ;
logic rst ;
logic [15:0] led ;

parameter CLOCK_PERIOD = 10 ;

principal DUT ( 
    .clk(clk),
    .rst(rst),
	.led(led)
) ;

initial begin
    clk =0 ;
	repeat (10000) begin
		#(CLOCK_PERIOD/2) clk = ~clk;
	end
end   

initial begin
    rst = 0 ;
    #3 ;
    rst = 1 ;
    #20 ;
    rst = 0 ;
end

    
endmodule
