//A program block that creates the environment and initiate the stimulus
`include "environment.sv"
program test(dut_if virtual_dut_if);
  
  //declare environment handle
  environment e;
  int total_transaction_count = 200;

  initial begin
    //create environment
    e = new(virtual_dut_if, total_transaction_count);
    //initiate the stimulus by calling run of env
    e.run();
  end
  

endprogram
