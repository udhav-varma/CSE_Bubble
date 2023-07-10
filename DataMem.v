//Udhav Varma (211120) and Shubham Anand (211020)
`timescale 1ns/1ps


module DataMem (rst , clk , read_addr , write_addr , write_en , data_in , data_out);
input wire rst, clk, write_en;
input wire[31:0] read_addr, write_addr, data_in;
output wire[31:0] data_out;

reg[31:0] store [65535:0];

assign data_out = store[read_addr[15:0]];

initial begin
store[0] = 100;
store[1] = 29;
store[2] = 18;
store[3] = 76;
store[4] = 9;
end

initial begin
$monitor("%d %d %d %d %d",store[0],store[1],store[2],store[3],store[4]);
end

always@(posedge clk) begin
if (write_en) begin
store[write_addr[15:0]] = data_in;
end
end
endmodule