`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2024 06:39:07 PM
// Design Name: 
// Module Name: main_control
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


module main_control(
    input logic [6:0] opcode,
    output logic branch,
    output logic jump,
    output logic mem_write,
    output logic [1:0] memtoreg,
    output logic reg_write,
    output logic alu_src,
    output logic [2:0] alu_op

    );
    
    always_comb begin
        case (opcode)
            7'b0110011 : begin // R-type instructions
                reg_write = 1;
                mem_write = 0;
                memtoreg = 2'b00;
                alu_op = 3'b010; // R-type instructions
                alu_src = 0;
                branch = 0;
                jump = 0;
            end
            7'b0010011: begin // I-type instructions
                reg_write = 1;
                mem_write = 0;
                memtoreg = 2'b00;
                alu_op = 3'b000; // I-type instructions
                alu_src = 1;
                branch = 0;
                jump = 0;
            end
            7'b0000011: begin // I*-type instructions (load)
                reg_write = 1;
                mem_write = 0;
                memtoreg = 2'b01;
                alu_op = 3'b100; // Load/store instructions
                alu_src = 1;
                branch = 0;
                jump = 0;
            end
            7'b1100111: begin // I*-type instructions (jump "jalr")
                reg_write = 1;
                mem_write = 0;
                memtoreg = 2'b10;
                alu_op = 3'b100;
                alu_src = 1;
                branch = 0;
                jump = 1;
            end
            7'b1100011: begin // B-type instructions (beq)
                reg_write = 0;
                mem_write = 0;
                memtoreg = 2'b00; // X for now
                alu_op = 3'b001; // Branch instruction
                alu_src = 0;
                branch = 1;
                jump = 0;
            end 
            7'b0100011: begin // S-type instructions
                reg_write = 0;
                mem_write = 1;
                memtoreg = 2'b00; // X for now
                alu_op = 3'b100;
                alu_src = 1;
                branch = 0;
                jump = 0;
            end
            7'b1101111: begin // J-type instructions
                reg_write = 1;
                mem_write = 0;
                memtoreg = 2'b10;
                alu_op = 3'b100;
                alu_src = 1;
                branch = 0;
                jump = 1;
            end
            // U-type instructions
            7'b0010111: begin // auipc
                reg_write = 1;
                mem_write = 0;
                memtoreg = 2'b11;
                alu_op = 3'b100;
                alu_src = 1;
                branch = 0;
                jump = 0;
            end
            7'b0110111: begin // lui
                reg_write = 1;
                mem_write = 0;
                memtoreg = 2'b00; // Pass ALU result
                alu_op = 3'b011;
                alu_src = 1;
                branch = 0;
                jump = 0;
            end
            default: begin
                reg_write = 0;
                mem_write = 0;
                memtoreg = 2'b00;
                alu_op = 3'b000;
                alu_src = 0;
                branch = 0;
                jump = 0;
            end
        endcase
    end
endmodule
