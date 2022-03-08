`define v_d_d_i virtual_dut_if.driver_mp.master_cb



class driver;
  
  //virtual interface handle
  virtual interface dut_if virtual_dut_if;

    //create mailbox handle
    rand transaction t;
    mailbox mb;
	int local_trans_count = 0;
      int trans_count;
    
    logic clk, resetn;
    
  //constructor
  function new(virtual interface dut_if virtual_dut_if, input mailbox mb, input int trans_count);
    this.virtual_dut_if = virtual_dut_if;
    this.mb = mb;
  	this.trans_count = trans_count;
  endfunction
    
    task reset();
      wait(virtual_dut_if.resetn == 0);
      @(`v_d_d_i);
      `v_d_d_i.hsel <= 1'b0;       // Slave select
      `v_d_d_i.haddr <= 0;   		 // Address bus
      `v_d_d_i.htrans <= 2'b00;   // Transfer type
      `v_d_d_i.hwrite <= 1'b0; // Transfer direction
      `v_d_d_i.hsize <= 3'b000;    // Transfer size
      `v_d_d_i.hburst <= 3'b000;   // Burst type
      `v_d_d_i.hprot <= 4'b0000;    // Protection control
      `v_d_d_i.hwdata <= 0;   	// Write data bus
      `v_d_d_i.error <= 'b0;	   	// What to do with it?
      repeat(2) @(`v_d_d_i);
      wait(virtual_dut_if.resetn == 1);

    endtask


  //drive methods
    task drive();
//       @(`v_d_d_i);
      while(local_trans_count < trans_count) begin
        mb.get(t);
//         t.print_transaction("DRIVER");
          `v_d_d_i.hsel <= t.sel;
          `v_d_d_i.haddr <= t.addr;
          `v_d_d_i.htrans <= t.trans;
          `v_d_d_i.hwrite <= t.write;
          `v_d_d_i.hsize <= t.size;
          `v_d_d_i.hburst <= t.burst;
          `v_d_d_i.hprot <= t.prot;
          `v_d_d_i.error <= t.error;
          @(`v_d_d_i);
          `v_d_d_i.hwdata <= t.wdata;
		local_trans_count++;
      end
    endtask

  //main methods
    task main();
      $display("d.main");
      drive();
    endtask
endclass
