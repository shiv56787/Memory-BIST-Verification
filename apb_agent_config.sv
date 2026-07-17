class apb_agent_config extends uvm_object;
    virtual apb_if vif;
    bit is_active = 1;

    `uvm_object_utils(apb_agent_config)

    function new(string name = "apb_agent_config");
      super.new(name);
    endfunction
  endclass
