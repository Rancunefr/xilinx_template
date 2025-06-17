`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2025 01:48:15 PM
// Design Name: 
// Module Name: tb_principal
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_principal;

logic clk ;
logic nrst ;

parameter CLOCK_PERIOD = 6 ;

principal DUT_principal ( 
    .clk(clk),
    .nrst(nrst)
) ;
        
        
initial begin
    clk <=0 ;
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
end   

initial begin
    nrst <= 1 ;
    #3 ;
    nrst <= 0 ;
    #6 ;
    nrst <= 1 ;
 end ;     
    
endmodule
