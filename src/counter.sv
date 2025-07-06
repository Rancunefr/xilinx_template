`timescale 1ns/1ps

module compteur(
    input  logic clk,
    input  logic rst,
	input  logic impulse,
    output logic [15:0] led
    );

logic [15:0] counter ;

always_ff @(posedge clk) begin               // Circuits Logiques
    if ( rst )
        counter <= 16'hFF00;
    else
		if ( impulse == 1 )
        	counter <= (counter == 16'hFFFF )? 0 : counter + 1 ;
end

always_comb begin
    led = counter;
end

endmodule
