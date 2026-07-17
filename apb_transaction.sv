class apb_transaction extends uvm_sequence_item;
    rand bit [7:0]  addr;
    rand bit [31:0] wdata;
         bit [31:0] rdata;
    rand bit        write;   // 1 = write, 0 = read
         bit        pslverr;

    constraint addr_c { addr inside {8'h00, 8'h04, 8'h08}; }

    `uvm_object_utils_begin(apb_transaction)
      `uvm_field_int(addr,    UVM_ALL_ON)
      `uvm_field_int(wdata,   UVM_ALL_ON)
      `uvm_field_int(rdata,   UVM_ALL_ON)
      `uvm_field_int(write,   UVM_ALL_ON)
      `uvm_field_int(pslverr, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "apb_transaction");
      super.new(name);
    endfunction
  endclass
