//Udhav Varma (211120) and Shubham Anand (211020)
`timescale 1ns/1ps

module control_unit (Instr , PCchoose, ALUctrl, WriteReg, ALUsrc, MemWrite, MemToReg, RegWrite_en, Link, Imm);
input wire[31:0] Instr;
output reg[1:0] PCchoose;//Signal choosing next PC
//0 - normal (PC = PC + 4)
//1 - branch statement (PC + imm)
//2 - from register (for jr statements)
//3 - jump (for j/jal)
output reg[3:0] ALUctrl;//Signal decides the type of operation in ALU
output reg[4:0] WriteReg;
output reg ALUsrc, MemWrite, MemToReg, RegWrite_en, Link;
output reg[31:0] Imm;

wire[31:0] signed_im, unsigned_im;  
assign signed_im = { {16{Instr[15]}} , Instr[15:0]};    //extension for signed im 
assign unsigned_im = { 16'd0 , Instr[15:0]};    //extension for unsigned im

wire [4:0] rs,rt,rd;
assign rs = Instr[25:21];
assign rt = Instr[20:16];
assign rd = Instr[15:11];

parameter RFORMAT = 1'b0;
parameter IFORMAT = 1'b1;
//codes for each operation
localparam SIG_ADD =  {3'd4,3'd0};
localparam SIG_SUB = {3'd4,3'd2};
localparam SIG_ADDU = {3'd4,3'd1};
localparam SIG_SUBU ={3'd4,3'd3};
localparam SIG_AND ={3'd4,3'd4};
localparam SIG_OR ={3'd4,3'd5};
localparam SIG_SLL ={3'd0,3'd0};
localparam SIG_SRL ={3'd0,3'd2};
localparam SIG_SLT ={3'd5,3'd2};
/*ALU control signals
Add = 0;
Subtract = 1;
And = 2;
Or = 3;
SLL = 4;
SRL = 5;
SLT = 6;
*/

always@(Instr) begin
Link = 0;

if(Instr[31:26] == 6'b000000) begin //R-formats
PCchoose = 0;   //R format, so PC = PC + 4
WriteReg = rd;  //rd is the register to be written 
ALUsrc = RFORMAT;   //
MemWrite = 0;   //Not writing to the memory
MemToReg = 0;   //ALUOut is the result
RegWrite_en = 1;    //for writing in the Register memory
Imm = signed_im; //not used here

case(Instr[5:0])
SIG_ADD: ALUctrl = 0;
SIG_SUB: ALUctrl = 1;
SIG_ADDU : ALUctrl = 0;
SIG_SUBU: ALUctrl = 1;
SIG_AND: ALUctrl = 2;
SIG_OR: ALUctrl = 3;
SIG_SLL: ALUctrl = 4;
SIG_SRL: ALUctrl = 5;
SIG_SLT: ALUctrl = 6;
6'b001_000: begin   //jr instruction
PCchoose = 2;   //PC chosen from register for jr instruction
ALUctrl = 0;    
end
endcase

end

else if (Instr[31:29] == 3'b001) begin //I-formats
PCchoose = 0;   //PC = PC + 4
WriteReg = rt;  //rt is where result would be written
ALUsrc = IFORMAT;   //I format 
MemWrite = 0;   // No mem write in immediate operations
MemToReg = 0;   //result is ALUout
RegWrite_en = 1;    //to write the result in the register
case(Instr[28:26])
3'b000: begin //addi
Imm = signed_im;
ALUctrl = 0;    // add signal
end
3'b001:begin    //addiu
Imm = unsigned_im;
ALUctrl = 0;    //add signal
end
3'b010:begin    //slti
Imm = signed_im;
ALUctrl = 6;    //slt signal
end
3'b011:begin    //sltiu
Imm = unsigned_im;
ALUctrl = 6; // slt signal
end
3'b100:begin    //andi
Imm = unsigned_im;
ALUctrl = 2; // and signal
end
3'b101:begin    //ori
Imm = unsigned_im;
ALUctrl = 3; //or signal
end
endcase        
end

else if (Instr[31:29]==3'b011) begin  //branch
PCchoose = 1;   //PC choose from branch
WriteReg = rt;  
ALUsrc = RFORMAT;
ALUctrl = 0;
MemWrite = 0; //no mem writing here
MemToReg = 0;   //result is ALUout
RegWrite_en = 0;    //No reg writing here
Imm = signed_im;    //Signed immediate (default)
case(Instr[28:26])
3'b000: //beq
ALUctrl = 7;
3'b001: //bne
ALUctrl = 8;
3'b010: //bgt
ALUctrl = 9;
3'b011: //bgte
ALUctrl = 10;
3'b100: //ble
ALUctrl = 11;
3'b110: //bleq
ALUctrl = 12;
endcase

end

else if (Instr[31:26]==2) begin    //j
PCchoose = 3;   //PC chosen from jump address
WriteReg = rd;  //not used here
ALUsrc = IFORMAT;   //inp2 for ALU does nothing
ALUctrl = 15;  //ALU does nothing
MemWrite = 0;   //No mem writing
MemToReg = 0;   //does nothing
RegWrite_en = 0;    //does nothing
Imm = signed_im;    //default
end

else if (Instr[31:26]==3) begin    //jal
PCchoose = 3;//PC chosen from jump address
WriteReg = 31;  //not used here (directly 31 is used by topmodule)
ALUsrc = IFORMAT;  //inp2 for ALU does nothing
ALUctrl = 15;  //ALU does nothing
MemWrite = 0;   //No mem writing
MemToReg = 0;   //irrelevant
RegWrite_en = 0;    //no reg writing
Link = 1;   //Link is set to 1 so that PC gets loaded is $ra register (Reg[31] in topmodule)
Imm = signed_im;
end
else if (Instr[31:26]==6'b100011) begin  //lw
PCchoose = 0;   //PC = PC + 4
WriteReg = rt;  // destination register
ALUsrc = IFORMAT; 
ALUctrl = 0;    //add
MemWrite = 0;
MemToReg = 1;  //result is data read from memory
RegWrite_en = 1;  //written into register
Imm = signed_im;       
end

else if (Instr[31:26]==6'b101011) begin  //sw
PCchoose = 0;
WriteReg = rt;
ALUsrc = IFORMAT;
ALUctrl = 0;    //add
MemWrite = 1;   //written into the memory
MemToReg = 0;   //result from ALUout
RegWrite_en = 0;    //no reg write
Imm = signed_im;    
end

end
endmodule