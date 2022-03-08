//Gets the packet from monitor, generates the expected result and compares with the actual result received from the Monitor
// `include "transaction.sv"
// `include "amba_ahb_defines.v"

class scoreboard;
   
  //create mailbox handle
  mailbox mb1;
  transaction t1;
  int total_errors = 0;
  int total_successes = 0;
  int total_memory_not_exists = 0;
  int local_trans_count = 0;  
  int trans_count;
  
  int total_reads = 0;
  int total_writes = 0;
  
  logic [7:0] read_byte;
  logic [15:0]read_halfword;
  logic [31:0]read_fullword;
  
  logic [7:0] mem [int];//see line#33 of design.sv
  
  bit endianness = 0;//0 for little, 1 for BIG
  
  //constructor
  function new(input mailbox mb1, input int trans_count, endianness = 0);
    this.mb1 = mb1;
    this.endianness = endianness;
    this.trans_count = trans_count;
    for (int i=0;i<1024;i++) mem[i] = i;//'x;//i;
  endfunction
  
  //main method
  task main();
    $display("s.main");

    while(local_trans_count < trans_count) begin
      mb1.get(t1);
//       t1.print_transaction("Scoreboard");
//       $display("Transaction printed from Scoreboard @ time = ",$time);
      if(t1.trans > 1) begin 
      //WRITE CASE
      if(t1.write == 1) //HTRANS c
      begin
        total_writes++;
        //byte-sized
        if(t1.size == 3'b000) 
        begin
          case(endianness)
            0: begin
              if (t1.addr%4 == 0)            mem[t1.addr] = t1.wdata[07:00];
              if (t1.addr%4 == 1)            mem[t1.addr] = t1.wdata[15:08];
              if (t1.addr%4 == 2)            mem[t1.addr] = t1.wdata[23:16];
              if (t1.addr%4 == 3)            mem[t1.addr] = t1.wdata[31:24];
            end
            1: begin
              if (t1.addr%4 == 0)            mem[t1.addr] = t1.wdata[31:24];
              if (t1.addr%4 == 1)            mem[t1.addr] = t1.wdata[23:16];
              if (t1.addr%4 == 2)            mem[t1.addr] = t1.wdata[15:08];
              if (t1.addr%4 == 3)            mem[t1.addr] = t1.wdata[07:00];
            end
          endcase
        end
        
        //half-word sized
        else if (t1.size == 3'b001) 
        begin
          case (endianness)
            0: begin
              if (t1.addr%4 == 0) begin
                mem[t1.addr] = t1.wdata[07:00];
                mem[t1.addr+1] = t1.wdata[15:08];
              end else if (t1.addr%4 == 2) begin
                mem[t1.addr] = t1.wdata[23:16];
                mem[t1.addr+1] = t1.wdata[31:24];
              end
            end
            1: begin
              if (t1.addr%4 == 0) begin
                mem[t1.addr] = t1.wdata[15:08];
                mem[t1.addr+1] = t1.wdata[07:00];
              end else if (t1.addr%4 == 2) begin
                mem[t1.addr] = t1.wdata[31:24];
                mem[t1.addr+1] = t1.wdata[23:16];
              end
            end
          endcase
        end 
          //full word sized
        else if (t1.size == 3'b010) begin
          case(endianness)
            0: begin
              mem[t1.addr] = t1.wdata[07:00];
              mem[t1.addr+1] = t1.wdata[15:08];
              mem[t1.addr+2] = t1.wdata[23:16];
              mem[t1.addr+3] = t1.wdata[31:24];
            end
            1: begin
              mem[t1.addr] = t1.wdata[31:24];
              mem[t1.addr+1] = t1.wdata[23:16];
              mem[t1.addr+2] = t1.wdata[15:08];
              mem[t1.addr+3] = t1.wdata[07:00];
            end
          endcase
        end
      end  
        
      //READ CASE
      else if (t1.write == 0) begin
        total_reads++;
        
        if (t1.size == 3'b000) begin
          case (endianness)
            0: begin
              if (t1.addr%4 == 0) begin
                read_byte = t1.rdata[07:00];
              end
              if (t1.addr%4 == 1) begin
                read_byte = t1.rdata[15:08];
              end
              if (t1.addr%4 == 2) begin
                read_byte = t1.rdata[23:16];
              end
              if (t1.addr%4 == 3) begin
                read_byte = t1.rdata[31:24];
              end
            end
            1: begin
              if (t1.addr%4 == 0) begin
                read_byte = t1.rdata[31:24];
              end
              if (t1.addr%4 == 1) begin
                read_byte = t1.rdata[23:16];
              end
              if (t1.addr%4 == 2) begin
                read_byte = t1.rdata[15:08];
              end
              if (t1.addr%4 == 3) begin
                read_byte = t1.rdata[07:00];
              end
            end
          endcase

          if(mem.exists(t1.addr)) begin
            if (read_byte === mem[t1.addr]) mem_read_passed(read_byte,t1.addr);
            else mem_exists_comp_failed(t1.addr,read_byte,t1.rdata);
          end 
          else 
            mem_doesnt_exist(t1.addr);
        end

        else if (t1.size == 3'b001) begin
          case (endianness)
            0: begin
              if (t1.addr%4 == 0) begin
                read_halfword = t1.rdata[15:00];
              end else if (t1.addr%4 == 2) begin
                read_halfword = t1.rdata[31:16];
              end
            end
            1: begin
              if (t1.addr%4 == 0) begin
                read_halfword = t1.rdata[31:16];
              end else if (t1.addr%4 == 2) begin
                read_halfword = t1.rdata[15:00];
              end
            end
          endcase
          if(mem.exists(t1.addr)) begin
            if (read_halfword[07:00] === mem[t1.addr] &&
                read_halfword[15:08] === mem[t1.addr+1]) begin
              mem_read_passed(read_halfword,t1.addr);
            end 
            else begin
              mem_exists_comp_failed(t1.addr,read_halfword,t1.rdata);
            end
          end 
          else begin
            mem_doesnt_exist(t1.addr);
          end
        end 

        
        if (t1.size == 3'b010) begin
          case (endianness)
            0: begin
              read_fullword[07:00] = t1.rdata[07:00];
              read_fullword[15:08] = t1.rdata[15:08];
              read_fullword[23:16] = t1.rdata[23:16];
              read_fullword[31:24] = t1.rdata[31:24];
            end
            1: begin
              read_fullword[07:00] = t1.rdata[31:24];
              read_fullword[15:08] = t1.rdata[23:16];
              read_fullword[23:16] = t1.rdata[15:08];
              read_fullword[31:24] = t1.rdata[07:00];
            end
          endcase
//           read_fullword = t1.rdata;
          if(mem.exists(t1.addr)) begin
            if (read_fullword[07:00] === mem[t1.addr] &&
                read_fullword[15:08] === mem[t1.addr+1] &&
                read_fullword[23:16] === mem[t1.addr+2] &&
                read_fullword[31:24] === mem[t1.addr+3]) begin
              mem_read_passed(read_fullword,t1.addr);
            end 
            else begin
                mem_exists_comp_failed(t1.addr,read_fullword,t1.rdata);
            end
          end 
          else begin
            mem_doesnt_exist(t1.addr);
            end
          end
        end
      end
      local_trans_count++;
    end
    scoreboard_report();
  endtask
  
  task mem_read_passed(input int rdata,addr);
//     $display("Data READ == Data WRITTEN | COMPARISON SUCCESSFUL");
//     $display("Data = %4h",rdata);
//     $display("Address = %4h",addr);
    total_successes++;
  endtask
  
  task mem_read_failed(input int rdata,addr);
    $display("Data READ != Data WRITTEN | COMPARISON FAILED");
    $display("Data = %2h in memory, & %2h in DUT",mem[addr], rdata);
  endtask
  
  task mem_exists_comp_failed(input int addr,read_data, t1DotRDATA);
    $display("Data READ != Data WRITTEN | COMPARISON FAILED");
    $display("memory exists but comparison failed @ addr = %h",addr);
    $display("Data = %h%h%h%h in memory, & %h in DUT, while T1.RDATA = %h", mem[addr+3],mem[addr+2],mem[addr+1],mem[addr], read_data,t1DotRDATA);
    total_errors++;
  endtask
  
  task mem_doesnt_exist(input int addr);
    $display("Data READ != Data WRITTEN | COMPARISON FAILED");
    $display("memory DOESN'T exist @ addr = %h",addr);
    total_memory_not_exists++;
  endtask
  
  task scoreboard_report();
    $display("-----------------------SCOREBOARD REPORT------------------------------");
    $display("Total READS = %5d, Total WRITES = %5d", total_reads, total_writes);
    $display("Total Successful READS = %5d",total_successes);
    $display("Total failed READS = %5d",total_errors);
    $display("Total Memory DOESN'T Exists = %5d",total_memory_not_exists);
    $display("----------------------------------------------------------------------");
  endtask
endclass
