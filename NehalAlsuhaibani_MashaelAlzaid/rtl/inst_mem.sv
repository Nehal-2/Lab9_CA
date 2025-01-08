`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2024 01:27:03 PM
// Design Name: 
// Module Name: inst_mem
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


module inst_mem #(
    parameter ADDR_WIDTH = 32,
    parameter INST_WIDTH = 32,
    parameter DEPTH = 256
)(
    input logic [ADDR_WIDTH-1:0] addr, 
    output logic [INST_WIDTH-1:0] inst
    );
    
    logic [INST_WIDTH-1:0] imem [0:DEPTH-1];
        
    assign inst = imem[addr[ADDR_WIDTH-1:2]]; // word-alligned
    
    initial $readmemh("/home/it/ComputerArchitecture/machine.hex", imem);
//    initial $readmemh("/home/it/ComputerArchitecture/datapath_test.hex", imem);
//    initial $readmemh("/home/it/ComputerArchitecture/test.hex", imem);
    
endmodule
