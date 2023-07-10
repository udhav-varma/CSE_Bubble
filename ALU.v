//Udhav Varma (211120) and Shubham Anand (211020)
`timescale 1ns/1ps

module ALU (inp1 , inp2 , shamt, ALUctrl , ALUOut , ALUzero);

input wire [31:0] inp1,inp2;
input wire[4:0] shamt;
input wire[3:0] ALUctrl;
output reg[31:0] ALUOut;
output wire ALUzero;

assign ALUzero = (ALUOut==32'd0); 
/* ALU Control signals
ADD = 0;
SUB = 1;
AND = 2;
OR = 3;
SLL = 4;
SRL = 5;
SLT = 6;
BEQ = 7;
BNE = 8;
BGT = 9;
BGTE = 10;
BLE = 11;
BLEQ = 12;
*/
always @(*) begin
    case(ALUctrl)

    0: ALUOut = inp1 + inp2;
    1: ALUOut = inp1 - inp2;
    2: ALUOut = inp1 & inp2;
    3: ALUOut = inp1 | inp2;
    4: ALUOut = inp1 << shamt;
    5: ALUOut = inp1 >> shamt;
    6: ALUOut = (inp1<inp2)? 1:0;
    7: ALUOut = (inp1==inp2)?0:1;
    8: ALUOut = (inp1!=inp2)?0:1;
    9: ALUOut = (inp1>inp2)?0:1;
    10: ALUOut = (inp1>=inp2)?0:1;
    11: ALUOut = (inp1<inp2)?0:1;
    12: ALUOut = (inp1<=inp2)?0:1;

    endcase
end
endmodule