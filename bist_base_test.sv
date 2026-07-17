class bist_base_test extends uvm_test;
    `uvm_component_utils(bist_base_test)

    bist_env         env;
    apb_agent_config agt_cfg;

    function new(string name = "bist_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agt_cfg = apb_agent_config::type_id::create("agt_cfg");
      agt_cfg.is_active = 1;

      if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", agt_cfg.vif))
        `uvm_fatal("TEST", "virtual interface not found in config db")

      uvm_config_db#(apb_agent_config)::set(this, "env*", "cfg", agt_cfg);
      env = bist_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      uvm_top.print_topology();
    endfunction
  endclass

  //--------------------------------------------------------------------
  class bist_smoke_test extends bist_base_test;
    `uvm_component_utils(bist_smoke_test)

    function new(string name = "bist_smoke_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      bist_smoke_sequence seq;
      phase.raise_objection(this);
      seq = bist_smoke_sequence::type_id::create("seq");
      seq.start(env.agt.sqr);
      phase.drop_objection(this);
    endtask
  endclass

  //--------------------------------------------------------------------
  class bist_random_test extends bist_base_test;
    `uvm_component_utils(bist_random_test)

    function new(string name = "bist_random_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      bist_random_sequence seq;
      phase.raise_objection(this);
      seq = bist_random_sequence::type_id::create("seq");
      seq.num_txns = 40;
      seq.start(env.agt.sqr);
      phase.drop_objection(this);
    endtask
  endclass

  //--------------------------------------------------------------------
  class bist_reset_test extends bist_base_test;
    `uvm_component_utils(bist_reset_test)

    function new(string name = "bist_reset_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      bist_reset_sequence seq;
      phase.raise_objection(this);
      seq = bist_reset_sequence::type_id::create("seq");
      seq.start(env.agt.sqr);
      phase.drop_objection(this);
    endtask
  endclass

  //--------------------------------------------------------------------
  class bist_error_test extends bist_base_test;
    `uvm_component_utils(bist_error_test)

    function new(string name = "bist_error_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      bist_error_sequence seq;
      phase.raise_objection(this);
      seq = bist_error_sequence::type_id::create("seq");
      seq.start(env.agt.sqr);
      phase.drop_objection(this);
    endtask
  endclass

endpackage

//--------------------------
