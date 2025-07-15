`timescale 1ns/1ps

module principal(
    input  logic clk,
    input  logic rst,
    output logic [15:0] led
    );

logic impulse;
logic myclk;
logic locked;

compteur cnt (
	.clk(myclk),
	.rst(rst),
	.impulse(impulse),
	.led(led)
) ;

impulse pls( 
	.clk(myclk),
	.rst(rst),
	.impulse(impulse)
) ;

clocky marcel
   (
    // Clock out ports
    .clk_out1(myclk),     // output clk_out1
    // Status and control signals
    .reset(rst), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk)      // input clk_in1
);

endmodule
