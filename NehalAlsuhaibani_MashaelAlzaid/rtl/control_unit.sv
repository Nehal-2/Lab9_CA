`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2024 01:46:46 PM
// Design Name: 
// Module Name: control_unit
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


module control_unit(
    input logic [6:0] opcode,
    input logic fun7, // fun7[5] = instruction[30]
    input logic [2:0] fun3, // instruction[14:12]
    input logic zero,
    input logic less,
    output logic pc_sel,
    output logic branch,
    output logic jump,
    output logic mem_write,
    output logic [2:0] memtoreg,
    output logic reg_write,
    output logic alu_src,
    output logic [2:0] alu_op,
    output logic [3:0] alu_ctrl
    );
    
    main_control main_control_inst(
        .opcode(opcode),
        .branch(branch),
        .jump(jump),
        .mem_write(mem_write),
        .memtoreg(memtoreg),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_op(alu_op)
    );
    
    alu_control alu_control_inst(
        .alu_op(alu_op),
        .fun3(fun3),
        .fun7(fun7),
        .alu_ctrl
    );
    
    branch_controller branch_controller_inst(
        .branch(branch),
        .fun3(fun3),
        .zero(zero),
        .less(less),
        .pc_sel(pc_sel)
    );
    
endmodule
