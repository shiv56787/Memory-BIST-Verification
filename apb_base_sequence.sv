class apb_base_sequence extends uvm_sequence #(apb_transaction);
    `uvm_object_utils(apb_base_sequence)

    virtual apb_if vif;

    function new(string name = "apb_base_sequence");
      super.new(name);
    endfunction

    task wait_for_reset();
      if(!uvm_config_db#(virtual apb_if)::get(null, "", "vif", vif))
        `uvm_fatal("SEQ", "Could not get vif in wait_for_reset")
      @(posedge vif.presetn);
      @(posedge vif.pclk);
    endtask

    task write_reg(bit [7:0] addr, bit [31:0] data);
      apb_transaction tr;
      tr = apb_transaction::type_id::create("tr");
      start_item(tr);
      if(!tr.randomize() with { addr == local::addr; wdata == local::data; write == 1; })
        `uvm_error("SEQ", "randomize failed in write_reg")
      finish_item(tr);
    endtask

    task read_reg(bit [7:0] addr, output bit [31:0] data);
      apb_transaction tr;
      tr = apb_transaction::type_id::create("tr");
      start_item(tr);
      if(!tr.randomize() with { addr == local::addr; write == 0; })
        `uvm_error("SEQ", "randomize failed in read_reg")
      finish_item(tr);
      data = tr.rdata;
    endtask
  endclass
