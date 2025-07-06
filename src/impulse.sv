`timescale 1ns/1ps

module impulse(
    input  logic clk,
	input  logic rst,
    output logic impulse
    );

logic [15:0] cnt ;

always_ff @(posedge clk) begin         
    if ( rst )
        cnt <= 0;
    else
        cnt <= (cnt == 16'hFFFF )? 0 : cnt + 1 ;
end

always_ff @(posedge clk) begin
	if ( cnt == 8'h01 )
		impulse <= 1 ;
	else
		impulse <= 0 ;
end

endmodule
