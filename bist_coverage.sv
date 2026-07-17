class bist_coverage extends uvm_subscriber #(apb_transaction);
    `uvm_component_utils(bist_coverage)

    covergroup cg with function sample(apb_transaction t);
      option.per_instance = 1;
      ADDR_CP: coverpoint t.addr {
        bins ctrl = {8'h00};
        bins stat = {8'h04};
        bins err  = {8'h08};
        bins others = default;
      }
      RW_CP: coverpoint t.write {
        bins wr = {1};
        bins rd = {0};
      }
      ADDR_X_RW: cross ADDR_CP,RW_CP;
    endgroup

    function new(string name, uvm_component parent);
      super.new(name,parent);
      cg = new();
    endfunction

    function void write(apb_transaction t);
      cg.sample(t);
    endfunction

    function void report_phase(uvm_phase phase);
      integer fp;

      super.report_phase(phase);

      fp = $fopen("coverage_report.txt","w");

      $fdisplay(fp,"==================================");
      $fdisplay(fp," Functional Coverage Report");
      $fdisplay(fp,"==================================");
      $fdisplay(fp,"Functional Coverage = %0.2f%%",
                cg.get_coverage());
      $fdisplay(fp,"==================================");

      $fclose(fp);

      `uvm_info("COVERAGE",
        $sformatf("Functional Coverage = %0.2f%%",
                  cg.get_coverage()),
        UVM_NONE)
    endfunction
  endclass
