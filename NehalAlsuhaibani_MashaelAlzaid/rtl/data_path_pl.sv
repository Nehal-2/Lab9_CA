`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2025 02:18:02 PM
// Design Name: 
// Module Name: data_path_pl
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


module data_path_pl(
    input logic clk,
    input logic reset_n,
    input logic reg_write,
    input logic alu_src,
    input logic [3:0] alu_ctrl,
    input logic jump,
    input logic mem_write,
    input logic [1:0] memtoreg,
    input logic pc_sel_branch,
    output logic [31:0] inst,
    output logic zero_mem,
    output logic less_mem
    );
    localparam WIDTH = 32;
    localparam INST_DEPTH = 256;
    localparam DATA_DEPTH = 1024;
    
    // PROGRAM COUNTER
    logic [WIDTH-1:0] next_pc, pc_plus_4_if; // removed current_pc declaration
    logic [WIDTH-1:0] current_pc_if;
    program_counter #(.n(WIDTH)) pc_inst(
        .clk(clk),
        .reset_n(reset_n),
        .data_in(next_pc),
        .data_o(current_pc_if) // changed from current_pc to current_pc_if
        );
    logic [31:0] inst_if;  
    assign pc_plus_4_if = current_pc_if + 4; // changed from current_pc to current_pc_if

    // INSTRUCTION MEMORY        
    inst_mem #(.ADDR_WIDTH(WIDTH),
        .INST_WIDTH(WIDTH),
        .DEPTH(INST_DEPTH)
    ) inst_mem_inst(
        .addr(current_pc_if), 
        .inst(inst_if)
    );
    
///////////////////// END OF FETCH STAGE
    logic [WIDTH*3-1:0] obus_if;
    logic [WIDTH*3-1:0] ibus_id;
    assign obus_if = {inst_if, current_pc_if, pc_plus_4_if}; // Pack the signals into a singal bus
    n_bit_reg #(.n(3*WIDTH)) if_id_reg (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(obus_if),
        .data_out(ibus_id)
    );
    logic [WIDTH-1:0] inst_id, current_pc_id, pc_plus_4_id;
    assign {inst_id, current_pc_id, pc_plus_4_id} = ibus_id; // At the ID stage, unpack the ibus_id bus to assign the individual signals:
    
///////////////////// START DECODE STAGE

    // REGISTER FILE
    logic [$clog2(WIDTH)-1:0] rs1, rs2, rd;
    logic [WIDTH-1:0] reg_rdata1_id, reg_rdata2_id, reg_wdata;
    
    assign rs1 = inst_id[19:15];
    assign rs2 = inst_id[24:20];
    assign rd = inst_id[11:7];
    
    reg_file #(.WIDTH(WIDTH)) reg_file_inst(
        .clk(clk),
        .reset_n(reset_n),
        .reg_write(reg_write),
        .raddr1(rs1),
        .raddr2(rs2),
        .waddr(rd),
        .wdata(reg_wdata),
        .rdata1(reg_rdata1_id), // _id
        .rdata2(reg_rdata2_id)
    );
    
    // IMMEDIATE GENERATOR
    logic [WIDTH-1:0] imm_id;//,imm_exe; //changed from imm;
    
    imm_gen imm_gen_inst(
    .inst(inst_id),
    .imm(imm_id)
    );
    
///////////////////// END DECODE STAGE
    logic [WIDTH*6-1:0] obus_id, ibus_exe;
    
    // NOTE: inst is passed only to be synchronized (will be used in mem stage (fun3 & inst[3]))
    assign obus_id = {pc_plus_4_id, current_pc_id, reg_rdata1_id, reg_rdata2_id, imm_id, inst_id};
    n_bit_reg #(.n(WIDTH*6)) id_exe_reg ( // SHOULD BE 96
        .clk(clk),
        .reset_n(reset_n),
        .data_in(obus_id),
        .data_out(ibus_exe)
    );
    logic [WIDTH-1:0] pc_plus_4_exe, current_pc_exe, reg_rdata1_exe, reg_rdata2_exe, imm_exe, inst_exe;
    assign {pc_plus_4_exe, current_pc_exe, reg_rdata1_exe, reg_rdata2_exe, imm_exe, inst_exe} = ibus_exe;
    
///////////////////// START EXECUTE STAGE
    
    // ALU
    logic [WIDTH-1:0] alu_op2, alu_result_exe;
    logic zero_exe, less_exe;
    assign alu_op2 = alu_src ? imm_exe : reg_rdata2_exe;
    
    alu #(.WIDTH(WIDTH)) alu_inst(
        .op1(reg_rdata1_exe),
        .op2(alu_op2),
        .alu_ctrl(alu_ctrl),
        .alu_result(alu_result_exe),
        .zero(zero_exe),
        .less(less_exe)
    );
    
    // JUMP LOGIC
    logic [WIDTH-1:0] pc_plus_imm_exe, pc_jalr_exe;
    assign pc_plus_imm_exe = current_pc_exe + imm_exe;
    assign pc_jalr_exe = imm_exe + reg_rdata1_exe;
 
///////////////////// END EXECUTE STAGE
//    logic [WIDTH-1:0] alu_result_mem, reg_rdata2_mem;
    logic [WIDTH*6+1:0] obus_exe, ibus_mem; // five 32-bit signals + two 1-bit signals

    assign obus_exe = {pc_plus_4_exe, pc_plus_imm_exe, pc_jalr_exe, alu_result_exe, reg_rdata2_exe, inst_exe, zero_exe, less_exe};
    n_bit_reg #(.n(6*WIDTH+2)) exe_mem_reg (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(obus_exe),
        .data_out(ibus_mem)
    );
    logic [WIDTH-1:0] pc_plus_4_mem, pc_plus_imm_mem, pc_jalr_mem, alu_result_mem, reg_rdata2_mem, inst_mem;
    assign {pc_plus_4_mem, pc_plus_imm_mem, pc_jalr_mem, alu_result_mem, reg_rdata2_mem, inst_mem, zero_mem, less_mem} = ibus_mem;

///////////////////// START MEMORY STAGE

    // DATA MEMORY
    logic [WIDTH-1:0] mem_rdata_mem;
    logic [2:0] fun3;
    assign fun3 = inst_mem[14:12]; // QUESTION WHAT "STAGE" INSTRUCTION SHOULD BE SLICED HERE?
    
    data_mem #(.WIDTH(WIDTH), 
        .DEPTH(DATA_DEPTH)
        ) data_mem_inst(
        .clk(clk),
        .reset_n(reset_n),
        .mem_write(mem_write),
        .addr(alu_result_mem),
        .wdata(reg_rdata2_mem),
        .fun3(fun3),
        .rdata(mem_rdata_mem)
    );
    
    // JUMP LOGIC
    logic [WIDTH-1:0] pc_jump_mem;
    logic pc_sel;
    // QUESTION WHAT STAGE OF IMM AND INST SHOULD BE USED HERE? ANSWER: inst was passed through pipe registers to be used here
    assign pc_jump_mem = (jump & ~inst_mem[3]) ? pc_jalr_mem : pc_plus_imm_mem;
    assign pc_sel = pc_sel_branch | jump;
    assign next_pc = pc_sel ? pc_jump_mem : pc_plus_4_mem;
   
   // QUESTION SHOULD THE FINAL REGISTER BE BEFORE OR AFTER JUMP? ANSWER: after. Jump logic is executed in mem stage
   
///////////////////// END MEMORY STAGE
    logic [WIDTH*4-1:0] obus_mem, ibus_wb;
    assign obus_mem = {alu_result_mem, mem_rdata_mem, pc_plus_4_mem, pc_jump_mem};
    n_bit_reg #(.n(WIDTH*4)) mem_wb_reg (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(obus_mem),
        .data_out(ibus_wb)
    );
    logic [WIDTH-1:0] mem_rdata_wb,alu_result_wb, pc_plus_4_wb, pc_jump_wb;
    assign {mem_rdata_wb, alu_result_wb, pc_plus_4_wb, pc_jump_wb} = ibus_wb;

///////////////////// START WRITE-BACK STAGE

    // WRITE DATA MUXES
    always_comb begin
        if (memtoreg == 2'b00)
            reg_wdata = alu_result_wb; // Write back alu_result (shifted imm - lui)
        else if (memtoreg == 2'b01)
            reg_wdata = mem_rdata_wb; // Write back memory data
        else if (memtoreg == 2'b10)
            reg_wdata = pc_plus_4_wb; // Write back pc_plus_4 (jal & jalr)
        else if (memtoreg == 2'b11)
            reg_wdata = pc_jump_wb; // Write back pc_jump (pc + shifted imm - auipc)
    end
    
endmodule
