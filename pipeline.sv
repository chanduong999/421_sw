// PIPELINE STRUCTURE


module pipeline();


parameter  add_i=6'd0;
parameter  add_imm=6'd1;
parameter  sub_i=6'd2;
parameter  sub_imm=6'd3;
parameter  mul_i=6'd4;
parameter  mul_imm=6'd5;
parameter  or_i=6'd6;
parameter  or_imm=6'd7;
parameter  and_i=6'd8;
parameter  and_imm=6'd9;
parameter  xor_i=6'd10;
parameter  xor_imm=6'd11;
parameter  load_i=6'd12;
parameter  store_i=6'd13;
parameter  bz_i=6'd14;
parameter  beq_i=6'd15;
parameter  jr_i=6'd16;
parameter  halt_i=6'd17;


bit [31:0]registers[32];
bit [7:0]memory[4096];
bit [31:0]pc;
int fd;
int count;
int instruction_count;

struct             {

  bit [31:0]Ir;
  bit [5:0]opcode;
  bit [4:0]Rs_add;
  bit [4:0]Rt_add;
  bit [4:0]Rd_add;

  bit [31:0]Rs;
  bit [31:0]Rt;
  bit [31:0]Rd;
  bit [16:0]imm;
  bit [31:0]result;
  bit [31:0]ld_add;
  bit [31:0]st_add;
  bit [31:0]load_data;
  
  bit [31:0]x_inst; } instruction_line[5];


  bit [3:0] instrcution_stage[5];

int i=0;
int opcode;
int arithmatics;
//-------------------- Memory fill --------------------------------------------//


 initial begin : file_block

        fd = $fopen ("./sample_memory_image", "r");
  
  if(fd ==0)
    disable file_block;
  
  while (!($feof(fd))) begin
    $fscanf(fd, "%32h",{memory[i], memory[i+1], memory[i+2], memory[i+3]});
     i=i+4;
   begin

  end
    end
  #60000;
  $finish();
  $fclose(fd);

end : file_block



//------------------------------------ clock generation ---------------------------------------------------------//

bit clk=0;

always #10 clk=~clk;


//---------------------------------- Instrecution fetch stage ---------------------------------------------------//



always@(posedge clk)

 begin

   for(int i=0; i<5; i++)

          begin

            if(instrcution_stage[i]==0)

                       begin

                         instruction_count=instruction_count+1;
                         instruction_line[i].Ir ={memory[pc], memory[pc+1], memory[pc+2], memory[pc+3] }  ;
		                 pc=pc+4;
                         instrcution_stage[i]<=1;
                         break;
                       end
           end
 end


//----------------------------------- Instrecution decode stage ---------------------------------------------------------//



always@(posedge clk)

 begin
   @(negedge clk);
   for(int i=0; i<5; i++)

          begin
          //  $display($time, "The loop in decode and value of instruction array = %d ",instrcution_stage[i] );
            if(instrcution_stage[i]==4'd1)

                       begin
                          
                        instruction_line[i].opcode = instruction_line[i].Ir[31:26];
                        // $display($time, "The value of opcode  at deocde  stage is %d" , instruction_line[i].opcode ) ;

                         instrcution_stage[i]<=2;                         
                       
                         if ( (instruction_line[i].opcode==add_i) || (instruction_line[i].opcode==sub_i) ||   (instruction_line[i].opcode==mul_i) || (instruction_line[i].opcode==or_i) ||(instruction_line[i].opcode==and_i) ||(instruction_line[i].opcode==xor_i))
                         
                                    begin
                                      instruction_line[i].Rd         = registers[instruction_line[i].Ir[25:21]];
                                      instruction_line[i].Rs         = registers[instruction_line[i].Ir[20:16]];
                                      instruction_line[i].Rt         = registers[instruction_line[i].Ir[15:11]];
                                      instruction_line[i].Rd_add     = instruction_line[i].Ir[25:21];
                                      instruction_line[i].Rs_add     = instruction_line[i].Ir[20:16];
                                      instruction_line[i].Rt_add     = instruction_line[i].Ir[15:11];
                                      $display("The add in decode registers %p ", instruction_line[i]);
                               
                         	   end
                         
                         else if ((instruction_line[i].opcode==add_imm) ||(instruction_line[i].opcode==sub_imm) ||(instruction_line[i].opcode==mul_imm) ||(instruction_line[i].opcode==or_imm) ||(instruction_line[i].opcode==and_imm) ||(instruction_line[i].opcode==xor_imm) || (instruction_line[i].opcode==load_i) || (instruction_line[i].opcode==store_i))
                         
                                    begin
                         
                                      instruction_line[i].Rt         = registers[instruction_line[i].Ir[25:21]];
                                      instruction_line[i].Rs         = registers[instruction_line[i].Ir[20:16]];
                                      instruction_line[i].imm        = instruction_line[i].Ir[15:0];
                                      instruction_line[i].Rt_add     = instruction_line[i].Ir[25:21];
                                      instruction_line[i].Rs_add     = instruction_line[i].Ir[20:16];
                                      $display("The loadp in decode registers %p ", instruction_line[i]);

                         	   end
                         
                         else if ((instruction_line[i].opcode== bz_i))
                          
                                     begin
                         
                                     instruction_line[i].Rs         = registers[instruction_line[i].Ir[25:21]];
                                     instruction_line[i].Rs_add     = instruction_line[i].Ir[25:21];
                                     instruction_line[i].x_inst     = instruction_line[i].Ir[15:0];
                         	   
                                     end
                         
                         else if ((instruction_line[i].opcode== beq_i))
                          
                                     begin
                         
                                     instruction_line[i].Rs         = registers[instruction_line[i].Ir[25:21]];
                                     instruction_line[i].Rt         = registers[instruction_line[i].Ir[20:16]];
                                     instruction_line[i].Rs_add     = instruction_line[i].Ir[25:21];
                                     instruction_line[i].Rt_add     = instruction_line[i].Ir[20:16];
                                     instruction_line[i].x_inst     = instruction_line[i].Ir[15:0];
                         	   
                                    end
                         
                         else if ((instruction_line[i].opcode== jr_i))
                          
                                     begin
                         
                                     instruction_line[i].Rs         = registers[instruction_line[i].Ir[25:21]];
                                     instruction_line[i].Rs_add     = instruction_line[i].Ir[25:21];
                         	   
                                    end
                       break;

		       end
           end

 end


//-------------------------------------------------- Instrecution execute stage ------------------------------------------------------//


always@(posedge clk)

  begin

       for(i=0; i<5; i++)

          begin
            

            if(instrcution_stage[i]==4'd2)

                       begin

                         instrcution_stage[i]<=3;
                           
                         case(instruction_line[i].opcode)
                           
                           add_i : begin
                           
                                       ADD(instruction_line[i].Rs, instruction_line[i].Rt, instruction_line[i].result );
                           
                                      end
                           
                           add_imm: begin
                             
                           
                             ADDI(instruction_line[i].Rs, instruction_line[i].imm , instruction_line[i].result );
                           
                                      end
                           
                           sub_i: begin
                           
                                       SUB(instruction_line[i].Rs, instruction_line[i].Rt, instruction_line[i].result );
                           	     
                                      end
                           
                           sub_imm: begin
                           
                             SUBI(instruction_line[i].Rs, instruction_line[i].imm , instruction_line[i].result );
                           	      
                                      end
                           
                           mul_i: begin
                           
                                       MUL(instruction_line[i].Rs, instruction_line[i].Rt, instruction_line[i].result );
                           
                               	      end
                           
                           
                           mul_imm: begin
                           
                             MULI(instruction_line[i].Rs, instruction_line[i].imm , instruction_line[i].result );
                           
                                      end
                           
                           or_i: begin
                           
                                       OR(instruction_line[i].Rs, instruction_line[i].Rt, instruction_line[i].result );
                           	       
                                     end
                           
                           
                           or_imm: begin
                           
                             ORI(instruction_line[i].Rs, instruction_line[i].imm , instruction_line[i].result );
                           
                                     end
                           
                           and_i: begin
                           
                                       AND(instruction_line[i].Rs, instruction_line[i].Rt, instruction_line[i].result );
                           	   
				      end
                           
                           and_imm: begin
                           
                             ANDI(instruction_line[i].Rs, instruction_line[i].imm , instruction_line[i].result );
                           
                           	      end
                           
                           xor_i: begin
                           
                                       XOR(instruction_line[i].Rs, instruction_line[i].Rt, instruction_line[i].result );
                           
                           	      end
                           
                           xor_imm: begin
                           
                             XORI(instruction_line[i].Rs, instruction_line[i].imm , instruction_line[i].result );
                           	   
				      end
                           
                           load_i : begin
                           
                                       instruction_line[i].ld_add=instruction_line[i].Rt+instruction_line[i].imm;
                           
                           	   end
                           
                           store_i: begin
                           
                                       instruction_line[i].st_add= instruction_line[i].Rs+instruction_line[i].imm;
                           
                           	   end
                           
                           bz_i: begin
                           
                                       if(instruction_line[i].Rs==0)
                                       pc=pc+instruction_line[i].x_inst-4;
                           
                           	   end
                           
                           beq_i: begin
                           
                                       if(instruction_line[i].Rs==instruction_line[i].Rt)
                                       pc=pc+instruction_line[i].x_inst-4;
                           
                           
                           	   end
                           
                           jr_i: begin
                           
                                       pc=instruction_line[i].Rs;
                           
                           	   end
                           
                           
                           
                           endcase
                           
                           break;

               end // if loop
          
                 
                            
        end   // for loop
              
 



  end





//----------------------------------------- Instruction memory stage --------------------------------------------------------------//




always@(posedge clk)

  begin

 

      for(i=0; i<5; i++)

        
          begin

            if(instrcution_stage[i]==4'd3)

                       begin

                         instrcution_stage[i]<=4;

                        case(instruction_line[i].opcode)
                           
                                                   
                           load_i : begin
                           
                             instruction_line[i].load_data= {memory[instruction_line[i].ld_add+3],memory[instruction_line[i].ld_add+2], memory[instruction_line[i].ld_add+1], memory[instruction_line[i].ld_add]};
                           
                           	   end
                           
                           store_i: begin
                             {memory[instruction_line[i].st_add+3],memory[instruction_line[i].st_add+2], memory[instruction_line[i].st_add+1], memory[instruction_line[i].st_add]}=instruction_line[i].Rt;
                           
                           	   end
                        
                           endcase
                           
                           break;
                      
                       end
         end

  end



//------------------------------------------------- Instuction write back stage -------------------------------------------------------------//


always@(posedge clk)

  begin

 

      for(i=0; i<5; i++)

          begin

            if(instrcution_stage[i]==4'd4)

                       begin

                         instrcution_stage[i]<=0;
                         
                         case(instruction_line[i].opcode) 
                           
                           add_i : begin
                           
                                   registers[instruction_line[i].Rd_add] = instruction_line[i].result;
                              
                                   end
                           
                           add_imm: begin
                           
                                    registers[instruction_line[i].Rt_add] = instruction_line[i].result;
                           
                                    end
                           
                           sub_i: begin
                           
                                   registers[instruction_line[i].Rd_add] = instruction_line[i].result;
                           	     
                                      end
                           
                           sub_imm: begin
                           
                                    registers[instruction_line[i].Rt_add] = instruction_line[i].result;
                           	      
                                      end
                           
                           mul_i: begin
                           
                                   registers[instruction_line[i].Rd_add] = instruction_line[i].result;
                           
                               	      end
                           
                           
                           mul_imm: begin
                           
                                    registers[instruction_line[i].Rt_add] = instruction_line[i].result;
                           
                                      end
                           
                           or_i: begin
                           
                                   registers[instruction_line[i].Rd_add] = instruction_line[i].result;
                           	       
                                     end
                           
                           
                           or_imm: begin
                           
                                    registers[instruction_line[i].Rt_add] = instruction_line[i].result;
                           
                                     end
                           
                           and_i: begin
                           
                                   registers[instruction_line[i].Rd_add] = instruction_line[i].result;
                           	   
				      end
                           
                           and_imm: begin
                           
                           
                                    registers[instruction_line[i].Rt_add] = instruction_line[i].result;
                           	      end
                           
                           xor_i: begin
                           
                                   registers[instruction_line[i].Rd_add] = instruction_line[i].result;
                           
                           	      end
                           
                           xor_imm: begin
                           
                                    registers[instruction_line[i].Rt_add] = instruction_line[i].result;
                           	   
				      end
                           
                           load_i : begin
                           
                                    registers[instruction_line[i].Rt_add] = instruction_line[i].load_data;
                           
                           	    end
                           
                           
                                                     
                           halt_i: begin
                             $display("The value of Ir and pc is %h and %d", instruction_line[i].Ir , pc );
                           
                                      $finish();
                           
                           	   end
                           
                           
                           
                           endcase
                           
                           break;


                       
                       end

         end

  end




//------------------------------------------------------------ END OF STAGES ----------------------------------------------------------------------------//


always@(posedge clk)
begin

count=count+1;

end

final

begin

$display( "The number of clock cycles  : %d" , count );
$display( "The contents of Registers are : %p" , registers);
$display ( "The value of PC : %d" , pc );
$display( "The number of instrcutions : %h" , instruction_count );
  $display( "The number of arithmatics" , arithmatics);

end













//Arithmatic instruction set

function void ADD (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ;   // 000000

c=a+b;

endfunction



function void ADDI (input bit [31:0]a , input bit [15:0]b , output bit [31:0]c ) ;   // 000001

c=a+b;

endfunction




function void SUB (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ;   // 000010

c=a-b;

endfunction



function void SUBI (input bit [31:0]a , input bit [15:0]b , output bit [31:0]c ) ;   // 000011

c=a-b;

endfunction




function void MUL (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ;   // 000100

c=a*b;

endfunction




function void MULI (input bit [31:0]a , input bit [15:0]b , output bit [31:0]c ) ;   // 000101

c=a*b;

endfunction


function void OR (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ;   // 000110

c=a|b;

endfunction


function void ORI (input bit [31:0]a , input bit [15:0]b , output bit [31:0]c ) ;   // 000111

c=a|b;

endfunction


function void AND (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ;   // 001000

c=a&b;

endfunction


function void ANDI (input bit [31:0]a , input bit [15:0]b , output bit [31:0]c ) ;   // 001001

c=a&b;

endfunction


function void XOR (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ;   // 001010

c=a^b;

endfunction


function void XORI (input bit [31:0]a , input bit [15:0]b , output bit [31:0]c ) ;   // 001011

c=a~^b;

endfunction

initial
  begin
    $dumpfile("dump.vcd"); $dumpvars;
  end

endmodule








