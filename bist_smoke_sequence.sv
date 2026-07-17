class bist_smoke_sequence extends apb_base_sequence;
    `uvm_object_utils(bist_smoke_sequence)

    function new(string name = "bist_smoke_sequence");
      super.new(name);
    endfunction

    task body();
      bit [31:0] status;
      int timeout;

      wait_for_reset();

      `uvm_info("SEQ", "Starting BIST smoke sequence", UVM_LOW)
      write_reg(CTRL_REG, 32'h1);

      timeout = 0;
      do begin
        read_reg(STAT_REG, status);
        timeout++;
        #10;
      end while(!status[0] && timeout < 200);

      if(!status[0])
        `uvm_error("SEQ", "BIST not complete - timeout waiting for done")
      else if(status[1])
        `uvm_info("SEQ", "BIST PASSED", UVM_LOW)
      else if(status[2])
        `uvm_error("SEQ", "BIST FAILED on a clean smoke run")
    endtask
  endclass
