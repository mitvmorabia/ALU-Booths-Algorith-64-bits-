// Code your design here
`timescale 10ns/1ns
module multiplier (result, valid, opera1, opera2, muordi, clock, reset, start);
//define inputs
input opera1, 
opera2, 
muordi, 
reset, 
start;
input clock;
wire clock;
// define output
output [63:0] result;
output valid;
// input size and type
wire [31:0] opera1;
wire [63:0] opera2;
reg ope_flag;

// output size and type
reg [63:0] result; 
reg valid, valid_dummy;

//define extra wires and registers required
wire c_out, cout;
wire [63:0] res_store;
wire [63:0] st_op2;
wire [31:0] z1, op1_not_wire, op2_not_wire, op1_store_not, op2_store_not;
wire [63:0] res_store_not, res_not_wire;
reg [63:0] res_not; 
wire c_inop1, c_inop2, c_inres;
reg [31:0] op1_not, op2_not;
reg [63:0] result1;
reg sign1,sign2, sign, idle;
reg [31:0] op1_store, op2_store;
wire [31:0] op1_store_aswire;
integer i;
// For states
reg [2:0] cst, nst;
parameter S0 = 3'b000, //all state
          S1 = 3'b001,
          S2 = 3'b010,
          S3 = 3'b011,
          S4 = 3'b100,
     S5 = 3'b101;




//assign start = 1'b0;
assign op1_not_wire = op1_not;
assign op2_not_wire = op2_not;
assign c_in =1'b0;
assign st_op2 = result;
assign op1_store_aswire = op1_store_not;
assign res_not_wire = res_not;


initial begin
valid = 0;        
end


// Multiplier instantiation
Add_rca M1 (res_store[63:32], , op1_store_aswire[31:0], st_op2[63:32], c_in);



always@(posedge clock or posedge reset)
begin
    if (reset)
    begin 
        cst = S0;
    end
    else
    begin
        if (start)
        begin 
               cst = S1;
        end
        else
        begin
            cst = nst;
        end
    end
end

always @(posedge clock)
case (cst)
S0 :    // reset state
        if (reset)
        begin
        valid = 0;    
        valid_dummy= 0;
        res_not = 64'h0;
//         result1 = 64'h0;
result = 64'h0;
i = 40;
        nst = cst;
        end        
    
S1:       // start state
        if (muordi == 1'b0)
        begin
            sign = sign1^sign2;
            result [31:0] = op2_store_not;
            //result [31] = 1'b0;
            result [63:32] = 32'h0;
            ope_flag = 1'b0;
            valid = 1'b0;
            valid_dummy = 1'b0;
            res_not = 64'h0;
            i = 0;
            nst = S2;
        end
        else 
        begin
            /// Division logic
            nst = S3;
        end
    

S2:     // Multiplication State
    
    if (i<32)
    begin
        nst = cst;
        i =i+1;
        if (i>=0)
        begin
            ope_flag = result[0];
            if (ope_flag == 1'b1)
            begin
                result [63:32] = res_store[63:32];
                result = result>>1;
            end
            else
            begin
                result = result>>1;
            end
        end
    end
    else if (i==32)
    begin
        nst = S4; 
        i =i+1;
        valid = 1'b1;
        nst = S4; /// valid state
        if (sign)
        begin
            res_not = (~result);
        end
        else
        begin
            res_not = result;
        end
                    
    end

S3 : if (muordi==1)         /// division state
begin
end


S4 : if (valid) 
begin
// valid state
result = res_store_not;
nst = S5; //idle state 
idle = 1;
end

S5 : if (idle) 
begin
end // idle state



default: nst = S0;
endcase

// 2ss complememt

/// instantiate for 2s complement

Add_rca C1 (op1_store_not, , op1_not_wire, z1, c_inop1);
Add_rca C2 (op2_store_not, , op2_not_wire, z1, c_inop2);
Add_rca C3 (res_store_not[31:0], cout , res_not_wire[31:0], z1, c_inres);
Add_rca C4 (res_store_not[63:32], , res_not_wire[63:32], z1, cout);


assign z1 = 32'h0;
notif1 A1(c_inop1, c_in,sign1); 
bufif0 A2(c_inop1, c_in,sign1); 
notif1 A3(c_inop2, c_in,sign2); 
bufif0 A4(c_inop2, c_in,sign2); 
notif1 A5(c_inres, c_in,sign); 
bufif0 A6(c_inres, c_in,sign); 

always@(opera1)
begin
sign1 = opera1[31];
if (sign1)
begin
op1_not = (~opera1);
end
else
begin
op1_not = opera1;
end
end

always @(opera2)
begin
sign2 = opera2[63];
if (sign2) 
begin
op2_not = (~opera2[31:0]);
end
else
begin
op2_not = opera2[31:0];
end
end
    
endmodule

module Add_rca(sum, c_out, a, b, c_in);
output [31:0] sum;
output c_out;
input [31:0] a, b;
input c_in;
wire c_in8, c_out;
Add_rca_16 Z1 (sum[15:0], c_in8, a[15:0], b[15:0], c_in);
Add_rca_16 Z2 (sum[31:16], c_out, a[31:16], b[31:16], c_in8);
endmodule


module Add_rca_16 (sum, c_out, a, b, c_in);
output [15:0] sum;
output c_out;
input [15:0] a, b;
input c_in;
wire c_in4, c_in8, c_in12, c_out;
Add_rca_4 M1 (sum[3:0], c_in4, a[3:0], b[3:0], c_in);
Add_rca_4 M2 (sum[7:4], c_in8, a[7:4], b[7:4], c_in4);
Add_rca_4 M3 (sum[11:8], c_in12, a[11:8], b[11:8], c_in8);
Add_rca_4 M4 (sum[15:12], c_out, a[15:12], b[15:12], c_in12);
endmodule

module Add_rca_4 (sum, c_out, a, b, c_in);
output [3: 0] sum;
output c_out;
input [3: 0] a, b;
input c_in;
wire c_in2, c_in3, c_in4;
Add_full M1 (sum[0], c_in2, a[0], b[0], c_in);
Add_full M2 (sum[1], c_in3, a[1], b[1], c_in2);
Add_full M3 (sum[2], c_in4, a[2], b[2], c_in3);
Add_full M4 (sum[3], c_out, a[3], b[3], c_in4);
endmodule

module Add_full (sum, c_out, a, b, c_in);
output sum, c_out;
input a, b, c_in;
wire w1, w2, w3;
Add_half M1 (w1, w2, a, b);
Add_half M2 (sum, w3, w1, c_in);
or M3 (c_out, w2, w3);
endmodule

module Add_half (sum, c_out, a, b);
output sum, c_out;
input a, b;
xor M1 (sum, a, b);
and M2 (c_out, a, b);
endmodule





