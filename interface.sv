//Interface groups the design signals, specifies the direction (Modport) and Synchronize the signals(Clocking Block)
// `include "amba_ahb_defines.v"

interface dut_if(input logic clk,resetn);
  // Add design signals here
  // AMBA AHB system signals
//   logic          hclk;     // Bus clock
//   logic          hresetn;  // Reset (active low)
  // AMBA AHB decoder signal
  logic          hsel;     // Slave select
  // AMBA AHB master signals
  logic[`AW-1:0] haddr;    // Address bus
  logic    [1:0] htrans;   // Transfer type
  logic          hwrite;   // Transfer direction
  logic    [2:0] hsize;    // Transfer size
  logic    [2:0] hburst;   // Burst type
  logic    [3:0] hprot;    // Protection control
  logic[`DW-1:0] hwdata;   // Write data bus
  // AMBA AHB slave signals
  logic[`DW-1:0] hrdata;   // Read data bus
  logic          hready;   // Transfer done
  logic[`RW-1:0] hresp;    // Transfer response
  // slave control signal
//   input  wor           error     // request an error response
  logic			 error;
  
  //Master Clocking block - used for Drivers
  clocking master_cb @(posedge clk);
    default input #1 output #1;
  	output hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, error;
    input hrdata, hresp, hready;
  endclocking
  
  //Monitor Clocking block - For sampling by monitor components
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input /*hclk, hresetn,*/ hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hrdata, hready, hresp, error;
  endclocking
  
  //Add modports here
  modport driver_mp(
    input resetn,
    clocking master_cb
  );
  modport monitor_mp(
    input resetn,
    clocking monitor_cb
//     input haddr, htrans, hwrite, hsize, hburst, hprot, hwdata,
//     input hrdata, hready, hresp,
//     input error		//keeping in separate line for remembering corresponding signals in design.sv
  );
  
  
endinterface
