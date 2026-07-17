class bist_env extends uvm_env;
    `uvm_component_utils(bist_env)
    apb_agent_config agt_cfg;
    apb_agent        agt;
    bist_scoreboard  sb;
    bist_coverage    cov;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(apb_agent_config)::get(this, "", "cfg", agt_cfg))
        `uvm_fatal("ENV", "apb_agent_config not found")
      uvm_config_db#(apb_agent_config)::set(this, "agt*", "cfg", agt_cfg);
      agt = apb_agent::type_id::create("agt", this);
      sb  = bist_scoreboard::type_id::create("sb", this);
      cov = bist_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agt.mon.ap.connect(sb.item_collected_export);
      agt.mon.ap.connect(cov.analysis_export);
    endfunction
  endclass
