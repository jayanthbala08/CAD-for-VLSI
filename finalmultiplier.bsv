
import DReg :: *;
import Vector :: * ;
import Randomizable ::*;

//======================interface for wallace mul======================================
 interface Ifc_wallace;
   (*always_ready*)
       method Action send(Bit#(64) in1, Bit#(64) in2, Bit#(3) funct3);
                                                               
       method Tuple2#(Bit#(1),Bit#(130)) receive;
 endinterface
 
 //===========================wallace multiplier module================================
   
   (*synthesize*)
   module mk_wallace(Ifc_wallace);
   
   //Declaring necessary registers 
   
   Reg#(Bit#(130)) rg_out   <- mkReg(0);
   Reg#(Bit#(130)) rg_out_1 <- mkReg(0);
   Reg#(Bit#(130)) rg_out_2 <- mkReg(0);
   
   Reg#(Bit#(3)) rg_funct3_0 <- mkReg(0);
   Reg#(Bit#(3)) rg_funct3_1 <- mkReg(0);
   Reg#(Bit#(3)) rg_funct3_2 <- mkReg(0);
   Reg#(Bit#(3)) rg_fn3 <- mkReg(0);
   
   Reg#(Bool) rg_word <- mkReg(False);
   Reg#(Bool) rg_word_1 <- mkReg(False);
   Reg#(Bool) rg_word_2 <- mkReg(False);
   Reg#(Bool) rg_word_3 <- mkReg(False);
   
   Reg#(Bit#(1)) rg_valid <- mkReg(0);
   Reg#(Bit#(1)) rg_valid_1 <- mkReg(0);
   Reg#(Bit#(1)) rg_valid_2 <- mkReg(0);
   Reg#(Bit#(1)) rg_valid_3 <- mkReg(0);
   
   Reg#(Bit#(1)) rg_sign <- mkReg(0);
   Reg#(Bit#(1)) rg_sign_1 <- mkReg(0);
   Reg#(Bit#(1)) rg_sign_2 <- mkReg(0);
   Reg#(Bit#(1)) rg_sign_3 <- mkReg(0);
   
   Vector#(4, Reg#(Bit#(65))) rg_operands1 <- replicateM(mkReg(0));
   Vector#(4, Reg#(Bit#(65))) rg_operands2 <- replicateM(mkReg(0));
   
   //Registers for storing CSA outputs 
     Reg#(Bit#(93)) carrysaveadd_l5_1[2], carrysaveadd_l5_2[2];                              
     Reg#(Bit#(119)) carrysaveadd_l5_3[2];
     Reg#(Bit#(128)) carrysaveadd_l5_4[2];
   
   for (Integer i=0; i<2; i=i+1) begin
     carrysaveadd_l5_1[i] <- mkReg(0);
     carrysaveadd_l5_2[i] <- mkReg(0);
     carrysaveadd_l5_3[i] <- mkReg(0);
     carrysaveadd_l5_4[i] <- mkReg(0);
     end
     
   Reg#(Bit#(76)) rg_carrysaveadd_l3_5_0 <- mkReg(0); 
   Reg#(Bit#(76)) rg_carrysaveadd_l3_5_1 <- mkReg(0);
   
   Reg#(Bit#(130)) carrysaveadd_l10[2];        
   carrysaveadd_l10[0] <- mkReg(0);
   carrysaveadd_l10[1] <- mkReg(0);
   
   
     //Carry sum addition of x bit operands seperated by y bits
     
     function Vector#(2, Bit#(67)) carrysaveadd_65_1 (Bit#(65) a,Bit#(65) b,Bit#(65) c);  // CSA for 65 bit inputs seperated by 1 bit
       Bit#(67) a1,b1,c1;
       Vector#(2, Bit#(67)) out;
       
       a1 = {a,2'd0};
       b1 = {1'd0,b,1'd0};
       c1 = {2'd0,c};
       
       out[0] = a1^b1^c1;
       out[1] = ((a1&b1)|(b1&c1)|(c1&a1))<<1;
       
       return out;
   endfunction
   
   function Vector#(2, Bit#(73)) carrysaveadd_67_3 (Bit#(67) a,Bit#(67) b,Bit#(67) c);  // CSA for 67 bit inputs seperated by 3 bits
       Bit#(73) a1,b1,c1;
       Vector#(2, Bit#(73)) out;
       
       a1 = {a,6'd0};
       b1 = {3'd0,b,3'd0};
       c1 = {6'd0,c};
       
       out[0] = a1^b1^c1;
       out[1] = ((a1&b1)|(b1&c1)|(c1&a1))<<1;
       
       return out;
   endfunction
   
   function Vector#(2, Bit#(74)) carrysaveadd_73_0 (Bit#(73) a,Bit#(73) b,Bit#(73) c);  // CSA for 73 bit inputs seperated by 0 bits
     Vector#(2, Bit#(74)) out;
     out[0]={1'b0,a^b^c};
     out[1]={a&b|b&c|c&a,1'b0};
     return out;
   endfunction
   
   function Vector#(2, Bit#(91)) carrysaveadd_73_9 (Bit#(73) a,Bit#(73) b,Bit#(73) c);  // CSA for 73 bit inputs seperated by 9 bits
       Bit#(91) a1,b1,c1;
       Vector#(2, Bit#(91)) out;
       
       a1 = {a,18'd0};
       b1 = {9'd0,b,9'd0};
       c1 = {18'd0,c};
       
       out[0] = a1^b1^c1;
       out[1] = ((a1&b1)|(b1&c1)|(c1&a1))<<1;
       
       return out;
   endfunction
   
   function Vector#(2, Bit#(92)) carrysaveadd_74_9 (Bit#(74) a,Bit#(74) b,Bit#(74) c);  // CSA for 74 bit inputs seperated by 9 bits
       Bit#(92) a1,b1,c1;
       Vector#(2, Bit#(92)) out;
       
       a1 = {a,18'd0};
       b1 = {9'd0,b,9'd0};
       c1 = {18'd0,c};
       
       out[0] = a1^b1^c1;
       out[1] = ((a1&b1)|(b1&c1)|(c1&a1))<<1;
       
       return out;
   endfunction
   

     rule rl_partial_production_reduction_tree_1;
     
       Bit#(67) carrysaveadd_l1_1[21],carrysaveadd_l1_2[21];    
     
     //stage 1
       for (Integer i=0; i<21; i=i+1) begin
       Bit#(65) a = signExtend(rg_operands2[0][3*i+2]);
       Bit#(65) a1 = signExtend(rg_operands2[0][3*i+1]);
       Bit#(65) a2 = signExtend(rg_operands2[0][3*i]);
       Bit#(65) b = signExtend(rg_operands2[0][3*i+2]);
         carrysaveadd_l1_1[i] = carrysaveadd_65_1((rg_operands1[0]&a),(rg_operands1[0]&a1),(rg_operands1[0]&a2))[0];
         carrysaveadd_l1_2[i] = carrysaveadd_65_1((rg_operands1[0]&b),(rg_operands1[0]&signExtend(rg_operands2[0][3*i+1])),(rg_operands1[0]&signExtend(a2)))[1];
         end
     
       //stage 2
       
       Bit#(73) carrysaveadd_l2_1[7],carrysaveadd_l2_2[7],carrysaveadd_l2_3[7],carrysaveadd_l2_4[7];      
       
       for (Integer i=0; i<7; i=i+1) begin
         carrysaveadd_l2_1[i] = carrysaveadd_67_3 (carrysaveadd_l1_1[3*i+2],carrysaveadd_l1_1[3*i+1],carrysaveadd_l1_1[3*i])[0];
         Bit#(73) x = carrysaveadd_l2_1[i];
         carrysaveadd_l2_2[i] = carrysaveadd_67_3 (carrysaveadd_l1_2[3*i+2],carrysaveadd_l1_2[3*i+1],carrysaveadd_l1_2[3*i])[0];
         carrysaveadd_l2_3[i] = carrysaveadd_67_3 (carrysaveadd_l1_1[3*i+2],carrysaveadd_l1_1[3*i+1],carrysaveadd_l1_1[3*i])[1];
         carrysaveadd_l2_4[i] = carrysaveadd_67_3 (carrysaveadd_l1_2[3*i+2],carrysaveadd_l1_2[3*i+1],carrysaveadd_l1_2[3*i])[1];
         end
       
       Bit#(74) carrysaveadd_l3_1[7],carrysaveadd_l3_2[7];                               
       Bit#(91) carrysaveadd_l3_3[2],carrysaveadd_l3_4[2];
       Bit#(76) carrysaveadd_l3_5[2];
       
       for (Integer i=0; i<7; i=i+1) begin
         carrysaveadd_l3_1[i] = carrysaveadd_73_0 (carrysaveadd_l2_1[i],carrysaveadd_l2_2[i],carrysaveadd_l2_3[i])[0];
         carrysaveadd_l3_2[i] = carrysaveadd_73_0 (carrysaveadd_l2_1[i],carrysaveadd_l2_2[i],carrysaveadd_l2_3[i])[1];
         end
       carrysaveadd_l3_3[0] = carrysaveadd_73_9 (carrysaveadd_l2_4[2],carrysaveadd_l2_4[1],carrysaveadd_l2_4[0])[0];
       carrysaveadd_l3_4[0] = carrysaveadd_73_9 (carrysaveadd_l2_4[2],carrysaveadd_l2_4[1],carrysaveadd_l2_4[0])[1];
       carrysaveadd_l3_3[1] = carrysaveadd_73_9 (carrysaveadd_l2_4[5],carrysaveadd_l2_4[4],carrysaveadd_l2_4[3])[0];
       carrysaveadd_l3_4[1] = carrysaveadd_73_9 (carrysaveadd_l2_4[5],carrysaveadd_l2_4[4],carrysaveadd_l2_4[3])[1];
       

       carrysaveadd_l3_5[0] = {3'b0,carrysaveadd_l2_4[6]}^{2'b0,(rg_operands1[0]&signExtend(rg_operands2[0][63])),9'd0}^{1'b0,(rg_operands1[0]&signExtend(rg_operands2[0][64])),10'd0};
       carrysaveadd_l3_5[1] = ({3'b0,carrysaveadd_l2_4[6]}&{2'b0,(rg_operands1[0]&signExtend(rg_operands2[0][63])),9'd0}|{2'b0,(rg_operands1[0]&signExtend(rg_operands2[0][63])),9'd0}&{1'b0,(rg_operands1[0]&signExtend(rg_operands2[0][64])),10'd0}|{3'b0,carrysaveadd_l2_4[6]}&{1'b0,(rg_operands1[0]&signExtend(rg_operands2[0][64])),10'd0})<<1;
       
       rg_carrysaveadd_l3_5_1 <= carrysaveadd_l3_5[1];
       rg_carrysaveadd_l3_5_0 <= carrysaveadd_l3_5[0];
       Bit#(92) carrysaveadd_l4_1[2],carrysaveadd_l4_2[2],carrysaveadd_l4_3[2],carrysaveadd_l4_4[2];      
       Bit#(91) carrysaveadd_l4_5[2];
       Bit#(119) carrysaveadd_l4_6[2];
       
       carrysaveadd_l4_1[0] = carrysaveadd_74_9 (carrysaveadd_l3_1[3],carrysaveadd_l3_1[2],carrysaveadd_l3_1[1])[0];
       carrysaveadd_l4_2[0] = carrysaveadd_74_9 (carrysaveadd_l3_1[3],carrysaveadd_l3_1[2],carrysaveadd_l3_1[1])[1];
       carrysaveadd_l4_3[0] = carrysaveadd_74_9 (carrysaveadd_l3_2[3],carrysaveadd_l3_2[2],carrysaveadd_l3_2[1])[0];
       carrysaveadd_l4_4[0] = carrysaveadd_74_9 (carrysaveadd_l3_2[3],carrysaveadd_l3_2[2],carrysaveadd_l3_2[1])[1];
       
       carrysaveadd_l4_1[1] = carrysaveadd_74_9 (carrysaveadd_l3_1[6],carrysaveadd_l3_1[5],carrysaveadd_l3_1[4])[0];
       carrysaveadd_l4_2[1] = carrysaveadd_74_9 (carrysaveadd_l3_1[6],carrysaveadd_l3_1[5],carrysaveadd_l3_1[4])[1];
       carrysaveadd_l4_3[1] = carrysaveadd_74_9 (carrysaveadd_l3_2[6],carrysaveadd_l3_2[5],carrysaveadd_l3_2[4])[0];
       carrysaveadd_l4_4[1] = carrysaveadd_74_9 (carrysaveadd_l3_2[6],carrysaveadd_l3_2[5],carrysaveadd_l3_2[4])[1];
       
       
       carrysaveadd_l4_5[0] = {17'b0,carrysaveadd_l3_1[0]}^{17'b0,carrysaveadd_l3_2[0]}^carrysaveadd_l3_3[0];
       carrysaveadd_l4_5[1] = ({17'b0,carrysaveadd_l3_1[0]}&{17'b0,carrysaveadd_l3_2[0]}|{17'b0,carrysaveadd_l3_2[0]}&carrysaveadd_l3_3[0]|{17'b0,carrysaveadd_l3_1[0]}&carrysaveadd_l3_3[0])<<1;
       
       carrysaveadd_l4_6[0] = {1'b0,carrysaveadd_l3_3[1],27'd0}^{1'b0,carrysaveadd_l3_4[1],27'd0}^{28'b0,carrysaveadd_l3_4[0]};
       carrysaveadd_l4_6[1] = {{carrysaveadd_l3_3[1],27'd0}&{carrysaveadd_l3_4[1],27'd0}|{carrysaveadd_l3_4[1],27'd0}&{27'b0,carrysaveadd_l3_4[0]}|{carrysaveadd_l3_3[1],27'd0}&{27'b0,carrysaveadd_l3_4[0]},1'b0};
       
       //stage five
       
       carrysaveadd_l5_1[0] <= {1'b0,carrysaveadd_l4_1[0]^carrysaveadd_l4_2[0]^carrysaveadd_l4_3[0]}; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l5_2[0] <= {(carrysaveadd_l4_1[0]&carrysaveadd_l4_2[0])|(carrysaveadd_l4_2[0]&carrysaveadd_l4_3[0])|(carrysaveadd_l4_1[0]&carrysaveadd_l4_3[0]),1'b0};
       
       carrysaveadd_l5_1[1] <= {1'b0,carrysaveadd_l4_1[1]^carrysaveadd_l4_2[1]^carrysaveadd_l4_3[1]}; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l5_2[1] <= {(carrysaveadd_l4_1[1]&carrysaveadd_l4_2[1])|(carrysaveadd_l4_2[1]&carrysaveadd_l4_3[1])|(carrysaveadd_l4_1[1]&carrysaveadd_l4_3[1]),1'b0};
       
       carrysaveadd_l5_3[0] <= carrysaveadd_l4_6[0]^{28'b0,carrysaveadd_l4_5[0]}^{28'b0,carrysaveadd_l4_5[1]}; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l5_3[1] <= (carrysaveadd_l4_6[0]&{28'b0,carrysaveadd_l4_5[0]}|{28'b0,carrysaveadd_l4_5[0]}&{28'b0,carrysaveadd_l4_5[1]}|carrysaveadd_l4_6[0]&{28'b0,carrysaveadd_l4_5[1]})<<1;
       
       carrysaveadd_l5_4[0] <= {27'b0,carrysaveadd_l4_4[0],9'b0}^{carrysaveadd_l4_4[1],36'b0}^{9'b0,carrysaveadd_l4_6[1]}; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l5_4[1] <= ({27'b0,carrysaveadd_l4_4[0],9'b0}&{carrysaveadd_l4_4[1],36'b0}|{carrysaveadd_l4_4[1],36'b0}&{9'b0,carrysaveadd_l4_6[1]}|{27'b0,carrysaveadd_l4_4[0],9'b0}&{9'b0,carrysaveadd_l4_6[1]})<<1;
     
     endrule
     
     rule rl_partial_production_reduction_tree_2;
     
       //stage six
     Bit#(120) carrysaveadd_l6_1[2];
     Bit#(129) carrysaveadd_l6_2[2];
     Bit#(130) carrysaveadd_l6_3[2];
       
       carrysaveadd_l6_1[0] = {carrysaveadd_l5_1[1],27'b0}^{27'b0,carrysaveadd_l5_1[0]}^{27'b0,carrysaveadd_l5_2[0]}; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l6_1[1] = ({carrysaveadd_l5_1[1],27'b0}&{27'b0,carrysaveadd_l5_1[0]}|{27'b0,carrysaveadd_l5_1[0]}&{27'b0,carrysaveadd_l5_2[0]}|{carrysaveadd_l5_1[1],27'b0}&{27'b0,carrysaveadd_l5_2[0]})<<1;
       
       carrysaveadd_l6_2[0] = {carrysaveadd_l5_2[1],36'b0}^{10'b0,carrysaveadd_l5_3[0]}^{10'b0,carrysaveadd_l5_3[1]}; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l6_2[1] = ({carrysaveadd_l5_2[1],36'b0}&{10'b0,carrysaveadd_l5_3[0]}|{10'b0,carrysaveadd_l5_3[0]}&{10'b0,carrysaveadd_l5_3[1]}|{carrysaveadd_l5_2[1],36'b0}&{10'b0,carrysaveadd_l5_3[1]})<<1;
       
       carrysaveadd_l6_3[0] = {2'b0,carrysaveadd_l5_4[0]}^{2'b0,carrysaveadd_l5_4[1]}^{rg_carrysaveadd_l3_5_0,54'd0}; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l6_3[1] = ({2'b0,carrysaveadd_l5_4[0]}&{2'b0,carrysaveadd_l5_4[1]}|{2'b0,carrysaveadd_l5_4[1]}&{rg_carrysaveadd_l3_5_0,54'd0}|{2'b0,carrysaveadd_l5_4[0]}&{rg_carrysaveadd_l3_5_0,54'd0})<<1;
       
       rg_funct3_1 <= rg_funct3_0 ;
     rg_word_1 <= rg_word ;
     rg_valid_1 <= rg_valid ;
     rg_sign_1 <= rg_sign;
       
       Bit#(130) carrysaveadd_l7_1[2],carrysaveadd_l7_2[2];                               //variables for storing CSA outputs from seventh reduction stage
       
       carrysaveadd_l7_1[0] = {1'b0,carrysaveadd_l6_1[0],9'b0}^{1'b0,carrysaveadd_l6_1[1],9'b0}^{1'b0,carrysaveadd_l6_2[0]}; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l7_1[1] = ({1'b0,carrysaveadd_l6_1[0],9'b0}&{1'b0,carrysaveadd_l6_1[1],9'b0}|{1'b0,carrysaveadd_l6_1[1],9'b0}&{1'b0,carrysaveadd_l6_2[0]}|{1'b0,carrysaveadd_l6_1[0],9'b0}&{1'b0,carrysaveadd_l6_2[0]})<<1;
       
       carrysaveadd_l7_2[0] = {1'b0,carrysaveadd_l6_2[1]}^carrysaveadd_l6_3[0]^carrysaveadd_l6_3[1]; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l7_2[1] = ({1'b0,carrysaveadd_l6_2[1]}&carrysaveadd_l6_3[0]|carrysaveadd_l6_3[0]&carrysaveadd_l6_3[1]|{1'b0,carrysaveadd_l6_2[1]}&carrysaveadd_l6_3[1])<<1;
       
       Bit#(130) carrysaveadd_l8[2];                                             //variables for storing CSA outputs from eigth reduction stage
       
       carrysaveadd_l8[0] = carrysaveadd_l7_1[0]^carrysaveadd_l7_1[1]^carrysaveadd_l7_2[0]; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l8[1] = (carrysaveadd_l7_1[0]&carrysaveadd_l7_1[1]|carrysaveadd_l7_1[1]&carrysaveadd_l7_2[0]|carrysaveadd_l7_1[0]&carrysaveadd_l7_2[0])<<1;
       
       Bit#(130) carrysaveadd_l9[2];                                             //variables for storing CSA outputs from ninth reduction stage
       
       carrysaveadd_l9[0] = carrysaveadd_l8[0]^carrysaveadd_l8[1]^carrysaveadd_l7_2[1]; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l9[1] = (carrysaveadd_l8[0]&carrysaveadd_l8[1]|carrysaveadd_l8[1]&carrysaveadd_l7_2[1]|carrysaveadd_l8[0]&carrysaveadd_l7_2[1])<<1;
       
   
       
       carrysaveadd_l10[0] <= carrysaveadd_l9[0]^carrysaveadd_l9[1]^{rg_carrysaveadd_l3_5_1,54'b0}; //Carry Save Addition (producing sum & carry)
       carrysaveadd_l10[1] <= (carrysaveadd_l9[0]&carrysaveadd_l9[1]|carrysaveadd_l9[1]&{rg_carrysaveadd_l3_5_1,54'b0}|carrysaveadd_l9[0]&{rg_carrysaveadd_l3_5_1,54'b0})<<1;
       
       rg_funct3_2 <= rg_funct3_1 ;
     rg_word_2 <= rg_word_1 ;
     rg_valid_2 <= rg_valid_1 ;
     rg_sign_2 <= rg_sign_1;
     endrule
     
     rule rl_partial_production_reduction_tree_3;
       
       rg_out <= carrysaveadd_l10[0]+carrysaveadd_l10[1];                 
       rg_fn3 <= rg_funct3_2 ;
     rg_word_3 <= rg_word_2 ;
     rg_valid_3 <= rg_valid_2 ;
     rg_sign_3 <= rg_sign_2;
     endrule
     
     
   method Action send(Bit#(64) in1, Bit#(64) in2, Bit#(3) funct3);
     Bit#(1) sign1 = funct3[1]^funct3[0];
     Bit#(1) sign2 = pack(funct3[1 : 0] == 1);
     let op1 = unpack({sign1 & in1[63], in1});
     let op2 = unpack({sign2 & in2[63], in2});
     
     Bit#(65) opp1 =0;
     Bit#(65) opp2 =0;
     
     
     if ((sign1 & in1[63])==0) begin opp1 = op1; end
     else begin opp1 = (~op1)+65'd1; end
     if ((sign2 & in2[63])==0) begin opp2 = op2; end
     else begin opp2 = (~op2)+65'd1; end
     
     rg_funct3_0 <= funct3;
     
     //Determining the sign of the final product 
     rg_sign <= (sign2 & in2[63])^(sign1 & in1[63]);

    rg_valid<=1;
    
    rg_operands1[0] <= opp1;
    rg_operands2[0] <= opp2;
   
   endmethod
   
   //Assigning sign to the product
   method Tuple2#(Bit#(1),Bit#(130)) receive;
   
     Bit#(130) out;
     
     if (rg_sign_3==1)
       out = ~rg_out+1;
     else
       out = rg_out;
     
 

     return tuple2(rg_valid_3,out);
   endmethod
   
 endmodule


//===========================module for testbench================================================

(*synthesize*)

module mktb();
   Reg#(Bit#(32)) cycle <- mkReg(0);        //declaring necessary registers
   Reg#(Bit#(32)) count <- mkReg(0);
   Reg#(Bit#(32)) cycle_stage <- mkReg(0);
   Reg#(Bit#(64)) rand1 <- mkReg(0);
   Reg#(Bit#(64)) rand2 <- mkReg(0);
   Reg#(Bit#(1)) valid <- mkReg(0);
       
   Ifc_wallace ifc <- mk_wallace(); //instance of an interface for an wallance multiplier 
   
   Randomize#(Bit#(64)) rand_in1 <- mkConstrainedRandomizer(64'd0,64'hffffffffffffffff);    
   Randomize#(Bit#(64)) rand_in2 <- mkConstrainedRandomizer(64'd0,64'hffffffffffffffff);
   
   
   rule init(cycle_stage == 0);            //initializing the 2 random values
     rand_in1.cntrl.init();
     rand_in2.cntrl.init();
     cycle_stage <= 1;
   endrule
   

   rule rl_stage2(cycle_stage==1);              //cycle staging random inputs 
   let a <- rand_in1.next();
     let b <- rand_in2.next();
     rand1 <= a;
     rand2 <= b;
     
     ifc.send(rand1,rand2,3'b000);
     cycle_stage<=0	;
   endrule
   

   rule receive;   //get outputs
     match {.valid,.out} = ifc.receive();
     
     if (cycle_stage == 0) $display("Cycle %d : Input 1 %d : Input 2 %d",cycle,rand1,rand2);  
     if (cycle_stage==1) $display("Cycle %d : Valid %d : Out %d ",cycle,valid,out);
   endrule
   
   rule cycling;          //10 cycles
     cycle <= cycle +1;
     if(cycle>10)
         $finish(0);
   endrule
   
 endmodule

