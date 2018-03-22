// Code your de sign here
`timescale 10ns/1ns
module division_revB(result, valid, opera1, opera2, muordi, clock, reset, start);
  input [31:0] opera1;
  input [63:0] opera2;
  output [63:0] result;
output valid;
  input start, muordi, reset;
input clock;
  wire [31:0] opera1;
  wire [63:0] opera2;  
  reg [63:0] result;
  reg[63:0] res_store, //  used in 32nd cycle to store the values of result ... extra reg.. should try and delete  
op1_sub;  	 // used for storing subtract value
  wire start, muordi, c_in, reset, cout1, cout, c_inop1s;
  reg [31:0] op1_store, op2_store;   // stores the 2 complements of opera1 and 2
  reg sign, sign1, sign2, ope_flag;  // flags for storing 2s complement
  reg valid, valid_dummy;
wire clock;   // output specs
  integer i;  //  for counter
  wire [31:0] res_sub, res_add;  // store the subtracted value and addition value
  wire [63:0] st_op2;  // used since we cant use a reg in instantiation
  reg res_msb, idle;  // flag to check the result to be negative or positive for algorithm

// values for 2s complement

wire [31:0] z1, op1_not_wire, op1_not_sub_wire, op1_store_not, op1_sub_store_not;
wire [63:0] res_store_not, res_not_wire, op2_not_wire, op2_store_not;
reg [63:0] res_not; 
wire c_inop1, c_inop2, c_inres;
reg [31:0] op1_not, op1_not_sub;
reg [63:0] op2_not;
assign op1_not_wire = op1_not;
assign op2_not_wire = op2_not;
assign op1_not_sub_wire = op1_not_sub;
assign res_not_wire = res_not;
assign z1 = 32'h0;
/////////////// reset logic
  //assign start = 1'b0;  //start input as per specs 
  assign st_op2 = result;  //store the changed value of result for next addition/ subtraction
  assign c_in = 0;   // assign cin  
 
//////////////////////////////////////////
reg [2:0] cst, nst;
parameter S0 = 3'b000, //all state
          S1 = 3'b001,
          S2 = 3'b010,
          S3 = 3'b011,
          S4 = 3'b100,
	 S5 = 3'b101;


always@(posedge clock or posedge reset)
begin
	if (reset)
	begin 
		cst <= S0;
	end
	else
	begin
		if (start)
		begin 
	       	cst <= S1;
		end
		else
		begin
			cst <= nst;
		end
	end
end

always @(posedge clock)
case (cst)
S0 :	  // reset state
		if (reset)
		begin
		valid = 0;	
		valid_dummy= 0;
		//sign = 0;
		//sign1=0;
		//sign2 = 0;
		//op1_store =32'h0;
		//op2_store = 64'h0;
		//op1_not = 32'h0;
		//op2_not = 64'h0;
		//op1_not_sub =32'h0; 
		res_not = 64'h0;
		result = 64'h0;
		i = 35;
		nst = cst;
		end		
	
S1: 	  // start state
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
if (muordi==1'b1)
			begin
				sign = sign1^sign2;

				ope_flag = 1'b1;
				result = op2_store_not;
i = 0;
		 		valid_dummy = 1'b0;
				valid = 1'b0;
				nst = S3;
			end
		end	

S2: 	
/// Multiplication State
	
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
		//valid = 1'b1;
		nst = S4; 
		i =i+1;
		valid = 1'b1;
		nst = S4; /// valid state
		/*if (sign)
		begin
			res_not = (~result);
		end
		else
		begin
			res_not = result;
		end*/
					
	end





//////////////////////////////

S3 : if (muordi==1) 		/// division state
begin
if (muordi == 1)
        begin
          if (i<32)
            begin
              nst = cst;
i = i+1;
              if (ope_flag == 1'b1)
                begin
                  result [63:32] = res_sub[31:0];
                  //res_store = result;
                  res_msb = result[63];	
                  if (res_msb == 1'b0)
                    begin
                      result[63:0] = result[63:0] <<1;
                      result[0] = 1'b1;
                      ope_flag = 1'b1;	
                    end
                  else if (res_msb == 1'b1)
                    begin
                      result = result<<1;
                      result[0] = 1'b0;
                      ope_flag = 1'b0;	
                    end
                end
              else if(ope_flag == 1'b0)
                begin
                  result [63:32] = res_add[31:0];
                  res_msb = result[63];	
                  if (res_msb == 1'b0)
                    begin
                      result = result<<1;
                      result[0] = 1'b1;
                      ope_flag = 1'b1;                  
                    end
                  else if (res_msb == 1'b1)
                    begin
                      result = result<<1;
                      result[0] = 1'b0;
                      ope_flag = 1'b0;
                    end
                end		
            end         
          
          else if (i==32)
            begin
              i = i+1;
	nst = S4;
	      valid = 1'b1;
              if (ope_flag == 1'b1)
                begin
                  result [63:32] = res_sub[31:0];
                  res_store = result[31:0];
                  res_msb = result[63];	
                  if	 (res_msb == 1'b0)
                    begin                      
                      result[31:0] = res_store <<1;
                      result[0] = 1'b1;
                      ope_flag = 1'b1;
                      result[63:32] = res_sub[31:0];
                      
                    end
                  else if (res_msb == 1'b1)
                    begin
                      result[31:0] = res_store <<1;
                      result[0] = 1'b0;
                      ope_flag = 1'b0;
                      result[63:32] = res_sub[31:0];
                    end
                end
              else if(ope_flag == 1'b0)
                begin
                  result [63:32] = res_add[31:0];   //checking the code . uncomment once done
                  res_store = result[31:0];
                  res_msb = result[63];	
                  if (res_msb == 1'b0)
                    begin
                      result[31:0] = res_store <<1;
                      result[0] = 1'b1;   
                      ope_flag = 1'b1;
                      //result [63:32] = res_add[31:0];
                    end
                  else if (res_msb == 1'b1)
                    begin
                      result[31:0] = res_store <<1;  
                      result[0] = 1'b0;   //CHANGED THE VALUE TO 1 FROM 0 MENTIONED IN THE CODE
                      ope_flag = 1'b0;
            	          //result [63:32] = res_add[31:0];
                    end
                end
            end     
        end

end
///////////////////////////////

S4 : if (valid) 
begin
// valid state
if (sign)
begin
res_not = (~result);
end
else
begin
res_not = result;
end
valid = 1'b1;
result = res_store_not;
nst = S5; //idle state 
idle = 1;
end

S5 : if (idle) 
begin
end // idle state



default: nst = S0;
endcase






  //// cases end
///// Division Instantiation
///Subtract instantiation
  Add_rca_1 D1 (res_sub[31:0], , op1_sub_store_not, st_op2[63:32],c_in) ;

////add instantiation 
  Add_rca_1 D2 (res_add[31:0], ,op1_store_not, st_op2[63:32],c_in);


///////2s complement


/// instantiate for 2s complement
Add_rca_1 C1 (op1_store_not, , op1_not_wire, z1, c_inop1);

Add_rca_1 C2 (op2_store_not[31:0],cout1, op2_not_wire[31:0], z1, c_inop2);
Add_rca_1 C3 (op2_store_not[63:32], , op2_not_wire[63:32], z1, cout1);

Add_rca_1 C4 (res_store_not[31:0], cout , res_not_wire[31:0], z1, c_inres);
Add_rca_1 C5 (res_store_not[63:32], , res_not_wire[63:32], z1, cout);

/// for sub opera1 
Add_rca_1 C6 (op1_sub_store_not, , op1_not_sub_wire, z1, c_inop1s);



notif1 A1(c_inop1, c_in,sign1); 
bufif0 A2(c_inop1, c_in,sign1); 
notif1 A3(c_inop2, c_in,sign2); 
bufif0 A4(c_inop2, c_in,sign2); 
notif1 A5(c_inres, c_in,sign); 
bufif0 A6(c_inres, c_in,sign); 

//for sub value of opera1
notif0 A7(c_inop1s, c_in,sign1); 
bufif1 A8(c_inop1s, c_in,sign1); 
 
/// for opera1 - 2s complement if negative
always@(opera1)
begin
sign1 = opera1[31];
if(sign1)
begin
op1_not = (~opera1);
op1_not_sub = opera1;
end
else
begin
op1_not = opera1;
op1_not_sub = (~opera1);
end
end



/////////////// FOR result - 2s complement if negative /// 2s complement the ouput if negative. based on valid bit
/*
always@(posedge valid_dummy)
begin
sign = sign1 ^ sign2;
valid = 1'b1;
end
*/

always@(posedge valid)
begin
result = result;
end
 
/// for opera 2 - 2s complement if negative
always @(opera2)
begin
sign2 = opera2[63];

if (sign2) 
begin
op2_not = (~opera2);
end
else
begin
op2_not = opera2;
end
end

endmodule




module Add_rca_1 (sum, c_out, a, b, c_in);
output [31:0] sum;
output c_out;
input [31:0] a, b;
input c_in;
wire c_in8, c_out;
Add_rca_16_1 Z1 (sum[15:0], c_in8, a[15:0], b[15:0], c_in);
Add_rca_16_1 Z2 (sum[31:16], c_out, a[31:16], b[31:16], c_in8);
endmodule


module Add_rca_16_1 (sum, c_out, a, b, c_in);
output [15:0] sum;
output c_out;
input [15:0] a, b;
input c_in;
wire c_in4, c_in8, c_in12, c_out;
Add_rca_4_1 M1 (sum[3:0], c_in4, a[3:0], b[3:0], c_in);
Add_rca_4_1 M2 (sum[7:4], c_in8, a[7:4], b[7:4], c_in4);
Add_rca_4_1 M3 (sum[11:8], c_in12, a[11:8], b[11:8], c_in8);
Add_rca_4_1 M4 (sum[15:12], c_out, a[15:12], b[15:12], c_in12);
endmodule

module Add_rca_4_1 (sum, c_out, a, b, c_in);
output [3: 0] sum;
output c_out;
input [3: 0] a, b;
input c_in;
wire c_in2, c_in3, c_in4;
Add_full_1 M1 (sum[0], c_in2, a[0], b[0], c_in);
Add_full_1 M2 (sum[1], c_in3, a[1], b[1], c_in2);
Add_full_1 M3 (sum[2], c_in4, a[2], b[2], c_in3);
Add_full_1 M4 (sum[3], c_out, a[3], b[3], c_in4);
endmodule

module Add_full_1 (sum, c_out, a, b, c_in);
output sum, c_out;
input a, b, c_in;
wire w1, w2, w3;
Add_half_1 M1 (w1, w2, a, b);
Add_half_1 M2 (sum, w3, w1, c_in);
or M3 (c_out, w2, w3);
endmodule

module Add_half_1 (sum, c_out, a, b);
output sum, c_out;
input a, b;
xor M1 (sum, a, b);
and M2 (c_out, a, b);
endmodule



