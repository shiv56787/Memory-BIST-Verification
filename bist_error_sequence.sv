 class bist_error_sequence extends apb_base_sequence;
    `uvm_object_utils(bist_error_sequence)

    string sram_path = "top_tb.dut.u_sram.mem[2]";

    function new(string name = "bist_error_sequence");
      super.new(name);
    endfunction

    task body();
      bit [31:0] status;
      bit [31:0] err;
      int timeout;

      wait_for_reset();

      `uvm_info("SEQ","Starting BIST error injection",UVM_LOW)
      write_reg(CTRL_REG, 32'h1);

      repeat(20) @(posedge vif.pclk);

      if(!uvm_hdl_deposit(sram_path, 8'hAA))
        `uvm_error("SEQ", $sformatf("uvm_hdl_deposit failed for path %s", sram_path))
      else
        `uvm_info("SEQ", $sformatf("Injected fault: %s = 8'hAA", sram_path), UVM_LOW)

      timeout = 0;
      do begin
        read_reg(STAT_REG, status);
        timeout++;
        #10;
      end while(!status[0] && timeout < 200);

      if(status[2]) begin
        read_reg(ERR_REG, err);
        `uvm_info("SEQ", $sformatf("BIST correctly FAILED, error_addr=%0d", err[2:0]), UVM_LOW)
      end
      else begin
        `uvm_error("SEQ", "Expected BIST FAIL after fault injection but fail bit was not set")
      end
    endtask
  endclass

  //------
