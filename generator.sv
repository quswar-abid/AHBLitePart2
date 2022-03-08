//Generates randomized transaction packets and put them in the mailbox to send the packets to driver 
// `include "transaction.sv"

class generator;
  int ok;
  //declare transaction class
  rand transaction t;
  int local_trans_count = 0, predef_sequence = 0;
  int trans_count;
      
  rand logic [3:0] undefined_random;
  
  //create mailbox handle
  static mailbox mb;
  int count;
  //declare an event
  event event1;

  logic [31:0] memory [1024];
  logic [2:0] t_size[1024];
  
  transaction buffer;
  
  //constructor
  function new(input mailbox mb, input int trans_count, predef_sequence=0);
    this.mb = mb;
  	this.trans_count = trans_count;
    this.predef_sequence = predef_sequence;
  endfunction
  
  
  //main methods
  task main();
    $display("g.main");
    for (local_trans_count=0; local_trans_count<trans_count; local_trans_count++) begin
      t = new();
      ok = t.randomize();
      
      if (predef_sequence == 0) begin
        ;//continue;//do nothing
      end
      if (predef_sequence == 1) begin
        t.write = 1'b1;
      end
      if (predef_sequence == 2) begin
        t.write = 1'b0;
      end
      if (predef_sequence == 3) begin
        t.trans = 2'b11;
      end
      
      if (t.trans == 2'b11) begin
        branch_to_burst(t.burst, t.size);
      end else begin
        mb.put(t);
        t.print_transaction("GENERATOR");
//         $display(local_trans_count);
      end

    end
    
    $display("%d transactions sent from GENERATOR.",local_trans_count);

    ->event1;
    $display("Event TRIGGERED in the GENERATOR.\t%m");
  endtask
  
  task branch_to_burst(input int HBURST, HSIZE);    
    t.trans = 2'b10;//Setting it to NON-SEQ for the first time only
    local_trans_count--;
    case(HBURST)
      3'b000: begin//Single Burst
        mb.put(t);
        local_trans_count++;
      end
      
      3'b001: begin//incrementing burst of undefined length
        ok = randomize(undefined_random);
//         $display("-----------> Ok = ",ok, " - Randomized# ", undefined_random);
        if(ok) begin
          case(HSIZE)
            3'b000: increment(undefined_random,1);
            3'b001: increment(undefined_random,2);
            3'b010: increment(undefined_random,4);
          endcase
        end else $display("randomization FAILED for underfined_random # of transactions!");
      end
      
      
      3'b010: begin//4-beat wrapping burst
        case(HSIZE)
          3'b000: wrap(4,1);
          3'b001: wrap(4,2);
          3'b010: wrap(4,4);
        endcase
      end
      
      3'b011: begin//4-beat incrementing burst
        case(HSIZE)
          3'b000: increment(4,1);
          3'b001: increment(4,2);
          3'b010: increment(4,4);
        endcase
      end
      
      
      3'b100: begin//8-beat wrapping burst
        case(HSIZE)
          3'b000: wrap(8,1);
          3'b001: wrap(8,2);
          3'b010: wrap(8,4);
        endcase
      end
      
      3'b101: begin//8-beat incrementing burst
        case(HSIZE)
          3'b000: increment(8,1);
          3'b001: increment(8,2);
          3'b010: increment(8,4);
        endcase
      end
      
      3'b110:begin//16-beat wrapping burst
        case(HSIZE)
          3'b000: wrap(16,1);
          3'b001: wrap(16,2);
          3'b010: wrap(16,4);
        endcase
      end
      
      3'b111: begin//16-beat incrementing burst
        case(HSIZE)
          3'b000: increment(16,1);
          3'b001: increment(16,2);
          3'b010: increment(16,4);
        endcase
      end
      
    endcase
  endtask
  
//   task wrap(input int number_of_beats, data_size);
//   endtask

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task increment(input int number_of_beats, data_size_in_bytes);
    int countdown = number_of_beats;
    
    buffer = new t;
    
    if ((local_trans_count + number_of_beats) < trans_count) begin
      $display("if((local_trans_count + number_of_beats) < trans_count)   ",local_trans_count);
      while (countdown>0) begin
        mb.put(t);
        t.print_transaction("GEN-INC");

        local_trans_count++;
        countdown--;
        
        buffer = new t;
        buffer.addr += data_size_in_bytes;
        
        t = new buffer;
        t.trans = 2'b11;
      end
    end else begin
      $display("before decrement = ", local_trans_count);
      local_trans_count--;
      $display("after decrement = ", local_trans_count);
    end
  endtask
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task wrap(input int number_of_beats, data_size_in_bytes);
    int countdown = number_of_beats;
    int num_beats = number_of_beats;
    int relevant_block_size = num_beats*data_size_in_bytes;
    
    int lower_boundry = t.addr - (t.addr % relevant_block_size);
    int upper_boundry = lower_boundry + (relevant_block_size) - 1;
    $display($time, t.addr, relevant_block_size, lower_boundry, upper_boundry);
    
    //making a shallow copy: https://verificationguide.com/systemverilog/systemverilog-shallow-copy/
    buffer = new t;
    
    if((local_trans_count + number_of_beats) < trans_count) begin
      $display("if((local_trans_count + number_of_beats) < trans_count)   ",local_trans_count);
      while(countdown>0)begin
        mb.put(t);
        t.print_transaction("GEN-WRAP");

        local_trans_count++;
        countdown--;
        
        buffer = new t;
        buffer.addr += data_size_in_bytes;        
        if (buffer.addr > upper_boundry)begin
          buffer.addr = lower_boundry;
        end
        
        t = new buffer;
        t.trans = 2'b11;
        
      end
    end else begin
      $display("before decrement = ", local_trans_count);
      local_trans_count--;
      $display("after decrement = ", local_trans_count);
    end
  endtask

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
  task sendTransactions(input int total_numbers, transaction T);
    for (int i=0; i<total_numbers; i++)begin
      t = new T;
      ok = t.randomize();
      mb.put(t);
      local_trans_count++;
    end
  endtask
  
endclass