`timescale 1ns/1ps

module principal(
    input  logic clk,
    input  logic rst,
    output logic [15:0] led
    );

logic impulse;
logic clk_interne ;
logic locked ;

compteur cnt (
	.clk(clk_interne),
	.rst(rst),
	.impulse(impulse),
	.led(led)
) ;


clocky instance_name
   (
    .clk_out1(clk_interne), 
    .reset(rst),
    .locked(locked), 
    .clk_in1(clk)               
);


impulse pls( 
	.clk(clk_interne),
	.rst(rst),
	.impulse(impulse)
) ;

endmodule
