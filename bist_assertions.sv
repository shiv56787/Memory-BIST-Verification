module bist_assertions (
  input logic clk,
  input logic rst_n,
  input logic start,
  input logic busy,
  input logic done,
  input logic pass,
  input logic fail,
  input logic mem_we,
  input logic mem_re
);

  property p_pass_fail_mutex;
    @(posedge clk) disable iff(!rst_n)
    !(pass && fail);
  endproperty
  a_pass_fail_mutex: assert property(p_pass_fail_mutex)
    else $error("[ASSERT] pass and fail asserted simultaneously");

  property p_we_re_mutex;
    @(posedge clk) disable iff(!rst_n)
    !(mem_we && mem_re);
  endproperty
  a_we_re_mutex: assert property(p_we_re_mutex)
    else $error("[ASSERT] mem_we and mem_re asserted simultaneously");

  property p_done_implies_pass_or_fail;
    @(posedge clk) disable iff(!rst_n)
    done |-> (pass || fail);
  endproperty
  a_done_implies_pass_or_fail: assert property(p_done_implies_pass_or_fail)
    else $error("[ASSERT] done asserted without pass or fail");

  property p_no_start_while_busy;
    @(posedge clk) disable iff(!rst_n)
    busy |-> !start;
  endproperty
  c_no_start_while_busy: cover property(p_no_start_while_busy);

endmodule
