`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2024 01:04:28 PM
// Design Name: 
// Module Name: program_counter
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


module program_counter #(
    parameter n = 32 // the default value of n
)(
    input logic clk,
    input logic reset_n,
    input logic [n-1:0] data_in,
    output logic [n-1:0] data_o
    );
    
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n)
            data_o <= 0;
        else
            data_o <= data_in;
    end

endmodule
