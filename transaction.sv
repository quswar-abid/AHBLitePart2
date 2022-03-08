//Fields required to generate the stimulus are declared in the transaction class
// `include "amba_ahb_defines.v"

class transaction;

  //declare transaction items
  // AMBA AHB system signals
//   input  wire          hclk,     // Bus clock
//   input  wire          hresetn,  // Reset (active low)
  // AMBA AHB decoder signal
  logic		            	sel = 1'b1;     // Slave select
  // AMBA AHB master signals
  rand logic	[`AW-1:0]	addr = 0;    	// Address bus
  rand logic    	[1:0] 	trans = 2'b10;	// Transfer type
  rand logic			 	write = 0;   	// Transfer direction
  rand logic   		[2:0]	size = 0;    	// Transfer size
  rand logic    	[2:0]	burst = 0;   	// Burst type
  rand logic    	[3:0] 	prot = 1;    	// Protection control
  rand logic 	[`DW-1:0]	wdata = 0;   	// Write data bus
  // AMBA AHB slave signals
  logic			[`DW-1:0]	rdata;   		// Read data bus
  logic						ready;   		// Transfer done
  logic			[`RW-1:0] 	resp;    		// Transfer response
  // slave control signal
  logic  				 	error = 0;		// request an error response
  
  
  //Add Constraints
    constraint a{
//       burst inside {3'b000};
      
//       burst inside {[3'b010:3'b111]};
      
//       burst inside {3'b011,3'b101,3'b111};
      
//       burst inside {3'b010,3'b100,3'b110};
      
//       trans dist {2'b00:=10, 2'b01:=10, 2'b10:=80};
      
      trans dist {2'b00:=10, 2'b01:=10, 2'b10:=70, 2'b11:=10};
      
//       trans inside {2'b10, 2'b11};
      
      size inside {[3'b000:3'b010]};
      
      size == 3'b001 -> addr[0:0] inside {1'b0};
      size == 3'b010 -> addr[1:0] inside {2'b00};
      
      solve size before addr;
      
      prot inside {4'b0001};
      
      //my own constraint:
      addr inside {[0:1023]};
//       trans == 2'b10 -> burst inside {3'b000};
      trans < 3 -> burst inside {3'b000};
      
    }

  function void set();
//     sel = 1'b1;     // Slave select
//     // AMBA AHB master signals
//     addr = 0;    	// Address bus
//     trans = 2'b10;	// Transfer type
//     write = 0;   	// Transfer direction
//     size = 0;    	// Transfer size
//     burst = 0;   	// Burst type
//     prot = 1;    	// Protection control
//     wdata = 0;   	// Write data bus
//     // AMBA AHB slave signals
//     rdata;   		// Read data bus
//     ready;   		// Transfer done
//     resp;
  endfunction
  
  //Add print transaction method(optional)
  function void print_transaction(input string from_where);
    $display("[%s:%4d] - HADDR:%8d - HTRANS:%2b - HWRITE:%1b - HSIZE:%3b - HBURST:%3b - HWDATA:%8h - HRDATA:%8h - HREADY:%1b - HRESP:%2b - ERROR:%1b", from_where, $time, addr, trans, write, size, burst, wdata, rdata, ready, resp, error);
//     $display(",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,");
//     $display("HADDR:	%b",addr);
//     $display("HTRANS:	%2b",trans);
//     $display("HWRITE:	%1b",write);
//     $display("HSIZE:	%3b",size);
//     $display("HBURST:	%3b",burst);
//     $display("HWDATA:	%8h",wdata);
//     $display("HRDATA:	%8h",rdata);
//     $display("HREADY:	%1b",ready);
//     $display("HRESP:	%2b",resp);
//     $display("Error:	%1b",error);
//     $display("''''''''''''''''''''''''''''''''''''''''''''''''''''''''");
  endfunction
   
endclass
