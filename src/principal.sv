`timescale 1ns / 1ps

module principal(
    input  logic clk,
    input  logic nrst,
    output logic led
    );

logic [7:0] counter ;

always_ff @(posedge clk) begin               // Circuits Logiques
    if ( !nrst )
        counter <= 0;
    else
        counter <= (counter == 8'hFF )? 0 : counter + 1 ;
end

always_comb begin
    led = counter[7];
end

endmodule
