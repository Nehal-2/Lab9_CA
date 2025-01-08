`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2024 11:50:28 AM
// Design Name: 
// Module Name: imm_gen
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


module imm_gen (
    input logic [31:0] inst,
    output logic [31:0] imm
    
    );
    
    logic [6:0] opcode;
    assign opcode = inst[6:0];
    
    // Bit 0 of imm
    always_comb begin
        case (opcode)
            7'b0010011: imm[0] = inst[20]; // I-type instructions
            7'b0000011: imm[0] = inst[20]; // I*-type instructions (load)
            7'b1100111: imm[0] = inst[20]; // I*-type instructions (jump "jalr")
            7'b0100011: imm[0] = inst[7]; // S-type instructions
            default: imm[0] = 1'b0;
        endcase
    end
    
    // Bits 4-1 of imm
    always_comb begin
        case (opcode)
            7'b0010011: imm[4:1] = inst[24:21]; // I-type instructions
            7'b0000011: imm[4:1] = inst[24:21]; // I*-type instructions (load)
            7'b1100111: imm[4:1] = inst[24:21]; // I*-type instructions (jump "jalr")
            7'b0100011: imm[4:1] = inst[11:8]; // S-type instructions
            7'b1100011: imm[4:1] = inst[11:8]; // B-type instructions (beq)
            7'b1101111: imm[4:1] = inst[24:21]; // J-type instructions
            default: imm[4:1] = 4'b0000;
        endcase
    end
    
    // Bits 10-5 of imm
    always_comb begin
        case (opcode)
            7'b0010011: imm[10:5] = inst[30:25]; // I-type instructions
            7'b0000011: imm[10:5] = inst[30:25]; // I*-type instructions (load)
            7'b1100111: imm[10:5] = inst[30:25]; // I*-type instructions (jump "jalr")
            7'b0100011: imm[10:5] = inst[30:25]; // S-type instructions
            7'b1100011: imm[10:5] = inst[30:25]; // B-type instructions (beq)
            7'b1101111: imm[10:5] = inst[30:25]; // J-type instructions
            default: imm[10:5] = 6'b000000;
        endcase
    end
    
    // Bit 31 of imm (MSB)
    always_comb begin
        imm[31] = inst[31];
    end
    
    // Bits 30-21 & 19-12 of imm
    always_comb begin
        case (opcode)
            // U-type instructions
            7'b0010111: begin // auipc
                imm[30:21] = inst[30:21];
                imm[19:12] = inst[19:12];
            end
            7'b0110111: begin // lui
                imm[30:21] = inst[30:21];
                imm[19:12] = inst[19:12];
            end
            7'b1101111: begin // J-type instructions
                imm[19:12] = inst[19:12];
                imm[30:21] = {10{inst[31]}}; // Sign-extend ???
            end
            default: begin
                imm[30:21] = {10{inst[31]}}; // Sign-extend 
                imm[19:12] = {8{inst[31]}}; // Sign-extend  
            end
        endcase
    end
    
    // Bits 20 & 11 of imm
    always_comb begin
        case (opcode)
            7'b0010011: begin // I-type instructions
                imm[11] = inst[31]; // Sign-extend
                imm[20] = inst[31]; // Sign-extend
            end
            7'b0000011: begin // I*-type instructions (load)
                imm[11] = inst[31]; // Sign-extend
                imm[20] = inst[31]; // Sign-extend
            end
            7'b1100111: begin // I*-type instructions (jump "jalr")
                imm[11] = inst[31]; // Sign-extend
                imm[20] = inst[31]; // Sign-extend
            end
            7'b1100011: begin // B-type instructions (beq)
                imm[11] = inst[7];
                imm[20] = inst[31]; // Sign-extend
            end 
            7'b0100011: begin // S-type instructions
                imm[11] = inst[31]; // Sign-extend
                imm[20] = inst[31]; // Sign-extend
            end
            // U-type instructions
            7'b0010111: begin // auipc
                imm[20] = inst[20];
            end
            7'b0110111: begin // lui
                imm[20] = inst[20];
            end
            7'b1101111: begin // J-type instructions
                imm[11] = inst[20];
                imm[20] = inst[31];
            end
            default: begin
                imm[11] = 1'b0;
                imm[20] = inst[31]; // Sign-extend
            end
        endcase
    end
    
endmodule
