`timescale 1ns/1ps

module impulse(
    input  logic clk,
	input  logic nrst,
    output logic impulse
    );

logic [7:0] counter ;

always_ff @(posedge clk) begin               // Circuits Logiques
    if ( !nrst )
        counter <= 0;
    else
        counter <= (counter == 8'hFF )? 0 : counter + 1 ;
end

always_ff @(posedge clk) begin
	if ( counter == 8'h01 )
		impulse <= 1 ;
	else
		impulse <= 0 ;
end

endmodule
