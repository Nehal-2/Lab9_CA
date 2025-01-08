`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2025 02:12:49 PM
// Design Name: 
// Module Name: n_bit_reg
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


module n_bit_reg #(parameter n = 64)
(

input logic clk, 
input logic reset_n, 
input logic [n -1:0] data_in, 
output logic [n -1:0] data_out

    );
 
always @(posedge clk, negedge reset_n)
begin
    if (!reset_n) 
        data_out<=0;
    else 
        data_out <= data_in;
    end    
    
endmodule