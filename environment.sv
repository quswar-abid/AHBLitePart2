//A container class that contains Mailbox, Generator, Driver, Monitor and Scoreboard
//Connects all the components of the verification environment
`include "transaction.sv"
`include "driver.sv"
`include "generator.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;
  
  int trans_count;
  
  //handles of all components
  generator g;
  driver d;
  monitor m;
  scoreboard s;
  
  //mailbox handles
  mailbox mb,mb1;
  
  //declare an event
  
  
  //virtual interface handle
  virtual interface dut_if virtual_dut_if;
    
  //constructor
    function new(virtual interface dut_if virtual_dut_if, input int trans_count);
      this.virtual_dut_if = virtual_dut_if;
  	  this.trans_count = trans_count;
      mb = new(trans_count);
      mb1 = new(trans_count);
      g = new(mb, trans_count, 0);
      d = new(virtual_dut_if, mb, trans_count);
      m = new(virtual_dut_if, mb1, trans_count);
      s = new(mb1, trans_count, 0);
    endfunction
      
      
  //pre_test methods
    task pre_test();
      $display("pre_test from environment");
      $display("driver reset() initiated!");
      d.reset();
      $display("driver reset() completed!");

    endtask
    
  //test methods
    task test();
      $display("test() from environment");
      fork
      	g.main();
        d.main();
        m.main();
        s.main();
      join_any
    endtask
  
  //post_test methods
    task post_test();
      $display("post_test() from environment");
      wait(g.event1.triggered);
      $display("event in the environment triggered @ time = ",$time);
      fork
//         while (s.local_trans_count != trans_count) $display(d.local_trans_count, m.local_trans_count, s.local_trans_count);
        wait(d.local_trans_count == trans_count);
        wait(m.local_trans_count == trans_count);
        wait(s.local_trans_count == trans_count);
      join
      $display(d.local_trans_count, m.local_trans_count, s.local_trans_count);
      $display("FORK in the post_test() JOINED @ time = ",$time);

    endtask
    
  //run methods
    task run();
      pre_test();
      test();
      post_test();
      $display("Simulation FINISHED @ time = ",$time);
      $finish;
    endtask
  
endclass


