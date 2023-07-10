//Udhav Varma (211120) and Shubham Anand (211020)
`timescale 1ns/1ps

module mux32bit (inp1, inp2, select, out);
input wire[31:0] inp1, inp2;
output wire[31:0] out;
input select;
assign out = (select?inp2:inp1);
endmodule

module PCSelector (a,b,c,d,s,zero,out);
input wire[31:0] a,b,c,d;
input wire[1:0] s;
input wire zero;
output reg[31:0] out;

always @(*) begin
case(s)
2'b00: out<=a;
2'b01: begin
if (zero)
out<=b;
else
out<=a;
end
2'b10: out<=c;
2'b11: out<=d;
endcase
end
endmodule

