`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2024 05:27:45 PM
// Design Name: 
// Module Name: SIGN_EXTEND
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


module SIGN_EXTEND(
input [31:0]instruction,

output reg [31:0]sign_ext_imm
    );
    
    always @(*)
    begin
        case(instruction[6:0])
            7'b0010011           :begin
            case(instruction[14:12])
            3'b011               :sign_ext_imm={20'b0,instruction[31:20]};//unsigned 
            default              :sign_ext_imm={{20{instruction[31]}},instruction[31:20]};
            endcase
            end
            7'b0000011           :sign_ext_imm={20'b0,instruction[31:20]};//load
            7'b0100011           :sign_ext_imm={20'b0,instruction[31:25],instruction[11:7]};// S type
            7'b1100011           :
            begin
            case(instruction[14:12])
            6,7:sign_ext_imm={{19'b0},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
            default:sign_ext_imm={{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};//Branch
            endcase
            end
            7'b0110111,7'b0010111:sign_ext_imm={instruction[31:12],12'b0};// U type
            default              :sign_ext_imm=0;
        endcase

    end
endmodule
