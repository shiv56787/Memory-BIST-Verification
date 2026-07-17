class bist_reset_sequence extends apb_base_sequence;
    `uvm_object_utils(bist_reset_sequence)

    function new(string name = "bist_reset_sequence");
      super.new(name);
    endfunction

    task body();
      bit [31:0] status;
      int timeout;

      wait_for_reset();

      `uvm_info("SEQ","Starting BIST reset sequence",UVM_LOW)
      write_reg(CTRL_REG,32'h1);
      repeat(20) @(posedge vif.pclk);

      `uvm_info("SEQ","Asserting presetn mid_bist",UVM_LOW)
      vif.presetn <= 1'b0;
      repeat(4) @(posedge vif.pclk);
      vif.presetn <= 1'b1;
      repeat(2) @(posedge vif.pclk);

      write_reg(CTRL_REG,32'h1);
      timeout = 0;
      do begin
        read_reg(STAT_REG,status);
        timeout++;
        #10;
      end while(!status[0] && timeout < 200);

      if(!status[0])
        `uvm_error("SEQ", "BIST did not recover cleanly after mid-operation reset")
      else
        `uvm_info("SEQ", $sformatf("BIST completed after reset, pass=%0b fail=%0b", status[1], status[2]), UVM_LOW)
    endtask
  endclass
