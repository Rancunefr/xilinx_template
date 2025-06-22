`timescale 1ns/1ps

module compteur(
    input  logic clk,
    input  logic nrst,
	input  logic impulse,
    output logic [7:0] led
    );

logic [7:0] counter ;

always_ff @(posedge clk) begin               // Circuits Logiques
    if ( !nrst )
        counter <= 0;
    else
		if ( impulse == 1 )
        	counter <= (counter == 8'hFF )? 0 : counter + 1 ;
end

always_comb begin
    led = counter;
end

endmodule
