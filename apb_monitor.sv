class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    virtual apb_if vif;
    uvm_analysis_port #(apb_transaction) ap;

    function new(string name, uvm_component parent);
      super.new(name,parent);
      ap = new("ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
      apb_agent_config cfg;
      super.build_phase(phase);
      if(!uvm_config_db#(apb_agent_config)::get(this,"","cfg",cfg))
        `uvm_fatal("MON","apb_agent_config not found")
      vif = cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
      forever begin
        @(posedge vif.pclk);
        if(vif.psel && vif.penable) begin
          apb_transaction tr = apb_transaction::type_id::create("tr");
          tr.addr    = vif.paddr;
          tr.write   = vif.pwrite;
          tr.pslverr = vif.pslverr;
          if(vif.pwrite)
            tr.wdata = vif.pwdata;
          else
            tr.rdata = vif.prdata;
          ap.write(tr);
        end
      end
    endtask
  endclass
