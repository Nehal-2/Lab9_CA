`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2024 05:40:54 PM
// Design Name: 
// Module Name: data_mem
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


module data_mem #(
    parameter WIDTH = 32,
    parameter DEPTH = 1024
)(
        input logic clk,
        input logic reset_n,
        input logic mem_write,
        input logic [WIDTH-1:0] addr,
        input logic [WIDTH-1:0] wdata,
        input logic [2:0] fun3,
        output logic [WIDTH-1:0] rdata
    );
    
    logic [WIDTH-1:0] dmem [0:DEPTH-1];
    
    // ALIGNMENT UNIT
    logic [3:0] wsel;
    logic W, HW, unsign;
    
    alignment_unit align_unit_inst(
        .addr(addr),
        .funct3(fun3),
        .wsel(wsel),
        .W(W), 
        .HW(HW), 
        .unsign(unsign)   
     ); 
        
    always_ff @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            for (int i = 0; i < DEPTH; i++)
                dmem[i] <= {WIDTH{1'b0}};
        end else begin
            if (mem_write) begin
                if (wsel[0])
                    dmem[addr[WIDTH-1:2]][7:0] <= wdata[7:0]; // store byte 0
                if (wsel[1])
                    dmem[addr[WIDTH-1:2]][15:8] <= wdata[15:8]; // store byte 1
                if (wsel[2])
                    dmem[addr[WIDTH-1:2]][23:16] <= wdata[23:16]; // store byte 2
                if (wsel[3])
                    dmem[addr[WIDTH-1:2]][31:24] <= wdata[31:24]; // store byte 3
            end        
         end
    end
    
    logic [31:0] dmem_o;
    assign dmem_o = dmem[addr[31:2]];
    logic [7:0] selected_byte;
    logic [15:0] selected_halfword;
    
    always_comb begin
        case (addr[1:0])
            2'b00: selected_byte = dmem_o[7:0];
            2'b01: selected_byte = dmem_o[15:8];
            2'b10: selected_byte = dmem_o[23:16];
            2'b11: selected_byte = dmem_o[31:24];
            default: selected_byte = dmem_o[7:0];
        endcase
        
        selected_halfword = addr[1] ? dmem_o[31:16] : dmem_o[15:0];
        
        if (W)
            rdata = dmem_o; // Full word overide for W
        else begin
            case ({unsign, HW})
                2'b10: rdata = {24'b0, selected_byte}; // Unsigned byte
                2'b11: rdata = {16'b0, selected_halfword}; // Unsigned halfword
                2'b00: rdata = {{24{selected_byte[7]}}, selected_byte}; // Signed byte
                2'b01: rdata = {{16{selected_halfword[15]}}, selected_halfword}; // Signed halfword
                default: rdata = 32'b0; 
             endcase
        end
    end
endmodule
