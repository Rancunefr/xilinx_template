`timescale 1ns/1ps

module principal(
    input  logic clk,
    input  logic nrst,
    output logic [7:0] led
    );

logic impulse;

compteur cnt (
	.clk(clk),
	.nrst(nrst),
	.impulse(impulse),
	.led(led)
) ;

impulse pls( 
	.clk(clk),
	.nrst(nrst),
	.impulse(impulse)
) ;

endmodule
