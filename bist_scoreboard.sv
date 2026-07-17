class bist_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(bist_scoreboard)
    uvm_analysis_imp #(apb_transaction, bist_scoreboard) item_collected_export;
    int pass_count;
    int fail_count;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      item_collected_export = new("item_collected_export", this);
    endfunction

    function void write(apb_transaction tr);
      if(!tr.write && tr.addr == STAT_REG) begin
        bit done, pass, fail, busy;
        done = tr.rdata[0];
        pass = tr.rdata[1];
        fail = tr.rdata[2];
        busy = tr.rdata[3];
        if(pass && fail)
          `uvm_error("SB", "Both pass and fail asserted simultaneously - illegal state")
        if(done && pass) begin
          pass_count++;
          `uvm_info("SB", $sformatf("BIST PASS observed, total pass=%0d", pass_count), UVM_LOW)
        end
        if(done && fail) begin
          fail_count++;
          `uvm_info("SB", $sformatf("BIST FAIL observed, total fail=%0d", fail_count), UVM_LOW)
        end
      end
    endfunction

    function void report_phase(uvm_phase phase);
      `uvm_info("SB", $sformatf("Final Scoreboard Summary: PASS=%0d FAIL=%0d", pass_count, fail_count), UVM_NONE)
    endfunction
  endclass

  //-------------
