`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_pkg::*;

module top_tb;
  logic pclk;
  initial pclk = 0;
  always #5 pclk = ~pclk; // 100 MHz

  apb_if vif(.pclk(pclk));

  shiv_top dut (
    .pclk    (pclk),
    .presetn (vif.presetn),
    .psel    (vif.psel),
    .penable (vif.penable),
    .pwrite  (vif.pwrite),
    .paddr   (vif.paddr),
    .pwdata  (vif.pwdata),
    .prdata  (vif.prdata),
    .pready  (vif.pready),
    .pslverr (vif.pslverr)
  );

  bind shiv_top bist_assertions u_bist_assertions (
    .clk     (pclk),
    .rst_n   (presetn),
    .start   (start),
    .busy    (busy),
    .done    (done),
    .pass    (pass),
    .fail    (fail),
    .mem_we  (mem_we),
    .mem_re  (mem_re)
  );

  initial begin
    vif.apply_reset(4);
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top_tb);
  end

  initial begin
    uvm_config_db#(virtual apb_if)::set(null, "*", "vif", vif);
    run_test();
  end
endmodule
