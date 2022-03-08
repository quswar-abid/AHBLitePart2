// `define v_d_d_i virtual_dut_if.driver_mp.master_cb

class coverage;

  virtual interface dut_if virtual_dut_if;
    
//     covergroup cg @ (`v_d_d_i);
    covergroup cg;
    option.per_instance = 1;
      c1: coverpoint virtual_dut_if.haddr{
        bins address_space[] = {[0:1023]};
      }
      c2: coverpoint virtual_dut_if.hwdata {
        bins data_in_upperCase[] = {[8'h41:8'h5a]};//upperCase
        bins data_in_lowerCase[] = {[8'h61:8'h7a]};//lowerCase
        bins bd = default;
      }
      c3: coverpoint virtual_dut_if.hrdata {
        bins data_out_upperCase[] = {[8'h41:8'h5a]};//upperCase
        bins data_out_lowerCase[] = {[8'h61:8'h7a]};//lowerCase
        bins bd = default;
      }
      c4: coverpoint virtual_dut_if.hburst {
        bins SINGLE = {3'b000};
        bins INCR = {3'b001};
        bins WRAP4 = {3'b010};
        bins INCR4 = {3'b011};
        bins WRAP8 = {3'b100};
        bins INCR8 = {3'b101};
        bins WRAP16 = {3'b110};
        bins INCR16 = {3'b111};
      }
      c5: coverpoint virtual_dut_if.htrans {
        bins IDLE = {2'b00};
        bins BUSY = {2'b01};
        bins NONSEQ = {2'b10};
        bins SEQ = {2'b11};
      }
      c6: coverpoint virtual_dut_if.hwrite {
        bins READ = {0};
        bins WRITE = {1};
      }
      c7: coverpoint virtual_dut_if.hsize {
        bins BYTE = {3'b000};
        bins HALFWORD = {3'b001};
        bins WORD = {3'b010};
      }
      c8: coverpoint virtual_dut_if.hready {
        bins HIGH = {1'b1};
        bins LOW = {1'b0};
      }
      c9: coverpoint virtual_dut_if.hresp {
        bins OKAY = {1'b0};
        bins ERROR = {1'b1};
      }
  endgroup
//   cg coverGroup = new;
  
  function new(virtual interface dut_if virtual_dut_if);
    cg = new;
    this.virtual_dut_if = virtual_dut_if;
  endfunction
endclass