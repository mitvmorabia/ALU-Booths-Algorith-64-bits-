// Code your testbench here
// or browse Examples
`timescale 1 ns/10 ps
`include "multiplier.v"
module testbench_multiplier();
reg [31:0] opera1;
reg [63:0] opera2;
reg start, clock, muordi, reset;
wire valid;
wire [63:0] result;
multiplier A1 (result, valid, opera1, opera2, muordi, clock, reset, start);

initial begin
// clock=0;
reset = 0;
muordi = 0 ;
#10 reset = 1;
#10 reset = 0;
#10 start = 0;
opera1 = -32'h524524;
opera2 = 64'h65653232;
#20 start = 1;
#20 start =0;
#1000 reset = 1;
#15 reset = 0;
opera1 = 32'h52146325;
opera2 = -64'h74127412;
#20 start = 1;
#20 start =0;
#1000 reset = 1;
#15 reset = 0;
opera1 = -32'h7fffffff;
opera2 = -64'h65413654;
#20 start = 1;
#20 start =0;
#1000 reset = 1;
#15 reset = 0;
opera1 = 32'h12123456;
opera2 = 64'h21542369;
#20 start = 1;
#20 start =0;

//opera1 = -32'h524524;
//opera2 = 64'h65653232;
//#500 opera1 = 32'h45454545; opera2 = 64'h1212121212121212;
//#5 start = 1'h1;
//#10 start = 1'h0;
#1000 $finish;
end


initial begin
$dumpfile("multiplier.vcd");
$dumpvars(0, testbench_multiplier);
end


//clock assigned 
initial begin
clock =0;
forever begin
#10 clock=~clock;
end
end
endmodule
