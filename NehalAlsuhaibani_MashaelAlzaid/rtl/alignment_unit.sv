`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2024 11:18:46 AM
// Design Name: 
// Module Name: alignment_unit
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


module alignment_unit(
    input logic [31:0] addr,
    input logic [2:0] funct3,
    output logic [3:0] wsel,
    output logic W, 
    output logic HW, 
    output logic unsign   
     );
     
     always_comb begin
        HW = funct3[0]; 
        W = funct3[1];
        unsign = ~funct3[2]; // Used for LHU & LBU
       
        if(funct3[1])
            wsel = 4'b1111;
        else if(funct3[0]) // halfword
            wsel =(addr[1])? 4'b1100:4'b0011;
        else if (~funct3[0]) begin // byte
            case(addr[1:0])
                2'b00: begin
                    wsel = 4'b0001;
                end 
                2'b01: begin
                    wsel = 4'b0010;
                end 
                2'b10: begin
                    wsel = 4'b0100;
                end
                2'b11: begin
                    wsel = 4'b1000;
                end 
            default: 
                wsel = 4'b0000;
            endcase
        end
    end 

endmodule