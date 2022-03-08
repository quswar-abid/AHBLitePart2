//Top most file which connets DUT, interface and the test

//-------------------------[NOTE]---------------------------------
//Particular testcase can be run by uncommenting, and commenting the rest
//`include "test1.sv"
//`include "test2.sv"
//`include "test3.sv"
//----------------------------------------------------------------
`define PERIOD 10	
`include "test.sv"
`include "interface.sv"
`include "coverage.sv"

module testbench_top;
  timeunit 1ns;
  timeprecision 1ns;
  
  bit clk = 1, resetn = 1;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  //declare clock and reset signal
  initial begin
    #1 resetn = 0;
    #10 resetn = 1;
  end
  //clock generation
   always #(`PERIOD/2) clk = ~clk;
  
  dut_if intf(clk,resetn);
  
  //testcase instance, interface handle is passed to test as an argument
  test test1(intf);
  
  //DUT instance, interface signals are connected to the DUT ports
  amba_ahb_slave DUT(.hclk(clk),
                     .hresetn(resetn),
                     .hsel(intf.hsel),
                     .haddr(intf.haddr),
                     .htrans(intf.htrans),
                     .hwrite(intf.hwrite),
                     .hsize(intf.hsize),
                     .hburst(intf.hburst),
                     .hprot(intf.hprot),
                     .hwdata(intf.hwdata),
                     .hrdata(intf.hrdata),
                     .hready(intf.hready),
                     .hresp(intf.hresp),
                     .error(intf.error)
                    );
  
  
  coverage coverClass = new(intf);
    
  always @ (posedge clk) begin
    coverClass.cg.sample();
  end
  


endmodule
