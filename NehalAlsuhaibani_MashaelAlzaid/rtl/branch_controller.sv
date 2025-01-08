`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2024 12:40:26 PM
// Design Name: 
// Module Name: branch_controller
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


module branch_controller(
    input logic branch,
    input logic [2:0] fun3,
    input logic zero,
    input logic less,
    output logic pc_sel

    );
    
    always @(*) begin
        if (branch) begin
            case (fun3)
                3'b000: pc_sel = zero; // BEQ: Branch if equal
                3'b001: pc_sel = ~zero; // BNE: Branch if not equal
                3'b100: pc_sel = less;  // BLT: Branch if less than
                3'b101: pc_sel = ~less; // BGE: Branch if greater or equal
                3'b110: pc_sel = less;  // BLTU: Branch if less than (unsigned)
                3'b111: pc_sel = ~less; // BGEU: Branch if greater or equal (unsigned)
                default: pc_sel = 1'b0; // Invalid fun3: Do not branch
            endcase
        end else begin
            pc_sel = 1'b0; // Not a branch instruction
        end
    end
endmodule
