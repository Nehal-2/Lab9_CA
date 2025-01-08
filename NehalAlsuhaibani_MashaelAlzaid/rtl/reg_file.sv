`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2024 01:49:16 PM
// Design Name: 
// Module Name: reg_file
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


module reg_file #(
    parameter WIDTH = 32
)(
        input logic clk,
        input logic reset_n,
        input logic reg_write,
        input logic [$clog2(WIDTH)-1:0] raddr1,
        input logic [$clog2(WIDTH)-1:0] raddr2,
        input logic [$clog2(WIDTH)-1:0] waddr,
        input logic [WIDTH-1:0] wdata,
        output logic [WIDTH-1:0] rdata1,
        output logic [WIDTH-1:0] rdata2

    );
    
    logic [WIDTH-1:0] x [0:WIDTH-1];
    
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n)
            for (int i = 0; i < WIDTH; i++) begin
                x[i] <= 0;
            end
        else if (reg_write)
            x[waddr] <= wdata;
    end
    
    always_comb begin
        x[0] = 0;
        rdata1 = x[raddr1];
        rdata2 = x[raddr2];
    end
    
endmodule
