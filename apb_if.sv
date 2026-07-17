`timescale 1ns/1ns

interface apb_if (input logic pclk);
  logic presetn;
  logic psel;
  logic penable;
  logic pwrite;
  logic [7:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic pready;
  logic pslverr;

  task automatic apply_reset(int cycles = 4);
    presetn = 1'b0;
    psel = 1'b0;
    penable = 1'b0;
    pwrite = 1'b0;
    paddr ='0;
    pwdata = '0;
    repeat(cycles) @(posedge pclk);
    presetn = 1'b1;
    @(posedge pclk);
  endtask
endinterface
