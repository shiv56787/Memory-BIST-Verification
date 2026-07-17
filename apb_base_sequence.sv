class apb_base_sequence extends uvm_sequence #(apb_transaction);
    `uvm_object_utils(apb_base_sequence)

    virtual apb_if vif;

    function new(string name = "apb_base_sequence");
      super.new(name);
    endfunction
