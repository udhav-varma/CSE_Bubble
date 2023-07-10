//Udhav Varma (211120) and Shubham Anand (211020)
`timescale 1ns/1ps
`include "DataMem.v"
`include "InstructMem.v"
`include "Control Unit.v"
`include "ALU.v"
`include "mux.v"

module Top (rst , clk);
input wire rst,clk;

reg [31:0] PC;  //Program counter
wire [31:0] nextPC;    //next PC
wire [31:0] Instr; //Instruction
reg[31:0] Reg [31:0];   //Register Memory
wire[31:0] inp1,inp2;   //Inputs to ALU
wire[31:0] rs_data, rt_data;    //Reg[rs] and Reg[rt]
reg[31:0] WriteText = 0; //Not Used
reg w_enable = 0;   //Not used
reg start;  //Signal whether process started
wire[31:0] next_inst;   //Next Instruction
wire[31:0] ReadData;    //Data read from data memory
wire[31:0] ALUout , Result; //output of ALU, result
wire ALUzero;   //ALU's zero signal
wire [4:0] shamt;

/* control unit sigmals*/
wire[1:0] PCchoose;     //Signal choosing next PC
//0 - normal (PC = PC + 4)
//1 - branch statement (PC + imm)
//2 - from register (for jr statements)
//3 - jump (for j/jal)
wire[3:0] ALUctrl;  //Signal decides the type of operation in ALU
wire[4:0] WriteReg; //Register address in which the result is to be loaded
wire ALUsrc;    //R of I format
wire MemWrite;  //Signal to write data in memory
wire MemToReg;  //Flag to decide whether ALUOut or ReadData is the result
wire RegWrite_en; //Flag, if positive register memory at WriteReg is rewritten
wire Link; // If jal instr, then this signal is asserted
wire[31:0] Imm;   //Immediate part of the instruction (in I type)

/*Finding next PC*/
wire[31:0] PCplus1 , branch_addr , jr_addr , j_addr;
assign PCplus1 = PC + 1;  
assign branch_addr = PC + Imm;  //in the case of branch instr, Imm is the offset
assign jr_addr = rs_data;   //In case of jump register, PC address will be inside the register
assign j_addr = {PC[31:26] , Instr[25:0]}; 
PCSelector PC_next_decider(PCplus1 , branch_addr , jr_addr , j_addr , PCchoose , ALUzero , nextPC);

/*Register file interactions*/
assign rs_data = Reg[Instr[25:21]]; //Data in rs = Instr[25:21]
assign rt_data = Reg[Instr[20:16]]; //Similarly for rt
mux32bit Result_decider (ALUout , ReadData , MemToReg , Result);

/*ALU interactions*/
assign inp1 = rs_data;  
assign shamt = Instr[10:6];
mux32bit in2_decider (rt_data , Imm , ALUsrc , inp2);   //inp2 decided on basis of type of Instr
ALU alu (inp1 , inp2 , shamt, ALUctrl , ALUout , ALUzero); 

InstructMem instruction (rst , clk , PC , WriteText , w_enable , WriteText ,Instr);
DataMem var (rst , clk , ALUout ,ALUout ,MemWrite , rt_data , ReadData);

control_unit unit (Instr , PCchoose, ALUctrl, WriteReg, ALUsrc, MemWrite, MemToReg, RegWrite_en, Link, Imm);



always@(posedge rst) begin
PC =0;
Reg[4] = 0;   //$a0 = starting index = 0
Reg[5] = 5;   //$a1=5=size

Reg[0] = 0;   //$zero
Reg[29] = 32'd65535;  //$sp
start = 0;
end

always@(posedge clk) begin

if(start==0) begin
start = 1;  //one time sstep
end

else begin
if (RegWrite_en) Reg[WriteReg] = Result;
if (Link) Reg[31] = PCplus1;    //jal instr. 31 is $ra.
//fetch
PC = nextPC;
end
end


endmodule
