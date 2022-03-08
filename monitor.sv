//Samples the interface signals, captures into transaction packet and sends the packet to scoreboard.
// `include "transaction.sv"
// `include "interface.sv"
`define v_m_d_i virtual_dut_if.monitor_mp.monitor_cb 

class monitor;
  
  //virtual interface handle
  virtual interface dut_if virtual_dut_if;
  int local_trans_count = 0;
  int trans_count;

  //create mailbox handle
    mailbox mb1;
    transaction t1;

  //constructor
  function new(virtual interface dut_if virtual_dut_if, input mailbox mb1, input int trans_count);
    this.virtual_dut_if = virtual_dut_if;
    this.mb1 = mb1;
  	this.trans_count = trans_count;
  endfunction
  
  //main method
    task main();
      $display("m.main");
      @(`v_m_d_i);
      while (local_trans_count < trans_count) begin
        t1 = new();
        t1.sel = `v_m_d_i.hsel;       // Slave select
        t1.addr = `v_m_d_i.haddr;    // Address bus
        t1.trans = `v_m_d_i.htrans;   // Transfer type
        t1.write = `v_m_d_i.hwrite;   // Transfer direction
        t1.size = `v_m_d_i.hsize;    // Transfer size
        t1.burst = `v_m_d_i.hburst;   // Burst type
        t1.prot = `v_m_d_i.hprot;    // Protection control
//         t1.wdata = `v_m_d_i.hwdata;   // Write data bus
        t1.error = `v_m_d_i.error;	   // What to do with it?
        @(`v_m_d_i);
        t1.wdata = `v_m_d_i.hwdata;   // Write data bus
        t1.rdata = `v_m_d_i.hrdata;
        t1.ready = `v_m_d_i.hready;
        t1.resp = `v_m_d_i.hresp;
		mb1.put(t1);
        local_trans_count++;
      end
    endtask

endclass
