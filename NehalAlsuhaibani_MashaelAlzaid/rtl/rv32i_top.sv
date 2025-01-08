`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2024 10:45:58 AM
// Design Name: 
// Module Name: rv32i_top
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


module rv32i_top(
    input logic clk,  
    input logic reset_n
    );
    logic [31:0] inst;     // Fetched instruction from data_path
    logic [6:0] opcode;          
    logic [2:0] fun3;          
    logic fun7;                 // 5th bit of the Func7 field
    logic branch;
    logic zero;
    logic less;
    logic pc_sel;
    logic jump;
    logic mem_write;
    logic [2:0] memtoreg;
    logic reg_write;
    logic alu_src;
    logic [1:0] alu_op;
    logic [3:0] alu_ctrl; 
    
    assign opcode = inst[6:0];
    assign fun3 = inst[14:12];
    assign fun7 = inst[30];

    control_unit cu(
        .opcode(opcode),
        .fun7(fun7), // fun7[5] = instruction[30]
        .fun3(fun3), // instruction[14:12]
        .zero(zero),
        .less(less),
        .pc_sel(pc_sel),
        .branch(branch),
        .jump(jump),
        .mem_write(mem_write),
        .memtoreg(memtoreg),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .alu_ctrl(alu_ctrl)
        );
        
    data_path dp(
        .clk(clk),
        .reset_n(reset_n),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_ctrl(alu_ctrl),
        .pc_sel_branch(pc_sel),
        .mem_write(mem_write),
        .memtoreg(memtoreg),
        .jump(jump),
        .zero(zero),
        .less(less),
        .inst(inst) 
    );

    endmodule