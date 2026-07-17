class apb_driver extends uvm_driver #(apb_transaction);
    `uvm_component_utils(apb_driver)
    virtual apb_if vif;

    function new (string name = "apb_driver", uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      apb_agent_config cfg;
      super.build_phase(phase);

      if(!uvm_config_db#(apb_agent_config)::get(this,"","cfg",cfg))
        `uvm_fatal("DRV","apb_agent_config not found")
      vif = cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
      vif.psel <= 1'b0;
      vif.penable <= 1'b0;
      vif.pwrite <= 1'b0;
      vif.paddr <= '0;
      vif.pwdata <= '0;

      forever begin
        apb_transaction tr;
        seq_item_port.get_next_item(tr);
        drive_transaction(tr);
        seq_item_port.item_done();
      end
    endtask

    task drive_transaction(apb_transaction tr);
      @(posedge vif.pclk);
      vif.paddr <= tr.addr;
      vif.pwdata <= tr.write ? tr.wdata : 32'h0;
      vif.pwrite <= tr.write;
      vif.psel <= 1'b1;
      vif.penable <= 1'b0;

      @(posedge vif.pclk);
      vif.penable <= 1'b1;

      @(posedge vif.pclk);
      if(!tr.write) begin
        tr.rdata = vif.prdata;
        tr.pslverr = vif.pslverr;
      end

      vif.psel <= 1'b0;
      vif.penable <= 1'b0;
    endtask
  endclass
