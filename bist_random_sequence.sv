 class bist_random_sequence extends apb_base_sequence;
    `uvm_object_utils(bist_random_sequence)
    int num_txns = 30;

    function new(string name = "bist_random_sequence");
      super.new(name);
    endfunction

    task body();
      apb_transaction tr;
      wait_for_reset();
      `uvm_info("SEQ", $sformatf("Starting BIST random sequence with %0d txns", num_txns), UVM_LOW)
      repeat(num_txns) begin
        tr = apb_transaction::type_id::create("tr");
        start_item(tr);
        if(!tr.randomize())
          `uvm_error("SEQ","Randomize failed in random sequence")
        finish_item(tr);
      end
    endtask
  endclass
