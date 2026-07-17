module shiv_top(
    input logic  pclk,
    input logic  presetn,
    input logic psel,
    input logic penable,
    input logic pwrite,
    input logic [7:0]  paddr,
    input logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic  pready,
    output logic  pslverr

);
  // internal signals
    logic start;
    logic   busy;
    logic   done;
    logic   pass;
    logic    fail;
    logic [2:0]  error_addr;
    logic [2:0]  mem_addr;
    logic [7:0]  mem_wdata;
    logic [7:0]  mem_rdata;
    logic  mem_we;
    logic   mem_re;
    
  // apb_slave
      shiv_apb_slave u_apb (
        .pclk   (pclk),
        .presetn  (presetn),
        .psel  (psel),
        .penable  (penable),
        .pwrite (pwrite),
        .paddr  (paddr),
        .pwdata  (pwdata),
        .prdata  (prdata),
        .pready  (pready),
        .pslverr (pslverr),
        .start (start),
        .busy  (busy),
        .done  (done),
        .pass   (pass),
        .fail  (fail),
        .error_addr (error_addr)
    );

  // BIST controller
  shiv_memory_bist_controller u_bist (
        .clk   (pclk),
        .rst_n  (presetn),
        .start  (start),
        .mem_rdata (mem_rdata),
        .mem_addr    (mem_addr),
        .mem_wdata   (mem_wdata),
        .mem_we   (mem_we),
        .mem_re    (mem_re),
        .busy   (busy),
        .done    (done),
        .pass    (pass),
        .fail   (fail),
        .error_addr  (error_addr)
    );

  // SRAM
    shiv_sram u_sram (
        .clk (pclk),
        .we  (mem_we),
        .re  (mem_re),
        .addr (mem_addr),
        .wdata (mem_wdata),
        .rdata (mem_rdata)
    );

endmodule
  

module shiv_apb_slave(
  input logic pclk,
  input logic presetn,
  input logic psel,
  input logic penable,
  input logic pwrite,
  input logic [7:0] paddr,
  input logic [31:0] pwdata,
  output logic [31:0] prdata,
  output logic pready,
  output logic pslverr,
  output logic start,
  input logic busy,
  input logic done,
  input logic pass,
  input logic fail,
  input logic [2:0] error_addr
);
  
  localparam control_reg = 8'h00;
  localparam status_reg = 8'h04;
  localparam error_reg = 8'h08;
  logic start_reg;
  
  assign start = start_reg;
  assign pready = 1'b1;  
  assign pslverr = 1'b0;

  always_ff @(posedge pclk or negedge presetn) begin
    if(!presetn) begin
      start_reg <= 1'b0;
    end
    else begin
      start_reg <= 1'b0;
      if(psel && penable && pwrite) begin
        case(paddr) 
          control_reg: begin
            start_reg <= pwdata[0];
          end
          default: begin
            start_reg <= 1'b0;
          end  
        endcase
      end
    end
  end
  
  always_comb begin
    prdata = 32'd0;
    if(psel && penable && !pwrite) begin
      case(paddr)
        control_reg: begin
          prdata[0] = start_reg;
        end
        status_reg: begin
          prdata[0] = done;
          prdata[1] = pass;
          prdata[2] = fail;
          prdata[3] = busy;
        end
        error_reg: begin
          prdata[2:0] = error_addr;
        end
        default: begin
          prdata = 32'd0;
        end
      endcase
    end
  end
endmodule
  
module shiv_memory_bist_controller (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic [7:0] mem_rdata,

    output logic [2:0] mem_addr,
    output logic [7:0] mem_wdata,
    output logic       mem_we,
    output logic       mem_re,
    output logic       busy,
    output logic       done,
    output logic       pass,
    output logic       fail,
    output logic [2:0] error_addr
);

typedef enum logic [2:0] {
    idle,
    write_zero,
    read_zero,
    write_one,
    read_one,
    pass_state,
    fail_state
} state_t;

state_t current_state, next_state;

logic [3:0] addr_count;
logic compare_fail;

//======================
// State Register
//======================
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        current_state <= idle;
    else
        current_state <= next_state;
end

//======================
// Next State Logic
//======================
always_comb begin
    next_state = current_state;

    case(current_state)

        idle:
            if(start)
                next_state = write_zero;

        write_zero:
            if(addr_count == 4'd7)
                next_state = read_zero;

        read_zero:
            if(compare_fail)
                next_state = fail_state;
            else if(addr_count == 4'd9) begin
                if(mem_rdata != 8'h00)
                    next_state = fail_state;
                else
                    next_state = write_one;
            end

        write_one:
            if(addr_count == 4'd7)
                next_state = read_one;

        read_one:
            if(compare_fail)
                next_state = fail_state;
            else if(addr_count == 4'd9) begin
                if(mem_rdata != 8'hFF)
                    next_state = fail_state;
                else
                    next_state = pass_state;
            end

        pass_state:
            next_state = idle;

        fail_state:
            next_state = idle;

        default:
            next_state = idle;

    endcase
end

//======================
// Output Logic
//======================
always_ff @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin

        busy         <= 0;
        done         <= 0;
        pass         <= 0;
        fail         <= 0;

        mem_we       <= 0;
        mem_re       <= 0;

        mem_addr     <= 3'd0;
        mem_wdata    <= 8'd0;

        addr_count   <= 4'd0;
        compare_fail <= 0;
        error_addr   <= 3'd0;

    end

    else begin

        case(current_state)

            idle: begin

                busy         <= 0;

                if (start) begin
                    done         <= 0;
                    pass         <= 0;
                    fail         <= 0;
                    busy         <= 1;
                end

                mem_we       <= 0;
                mem_re       <= 0;

                mem_addr     <= 3'd0;
                mem_wdata    <= 8'd0;

                compare_fail <= 0;
                addr_count   <= 4'd0;

            end

            //--------------------------------

            write_zero: begin

                busy      <= 1;

                mem_we    <= 1;
                mem_re    <= 0;

                mem_addr  <= addr_count[2:0];
                mem_wdata <= 8'h00;

                if(addr_count < 4'd7)
                    addr_count <= addr_count + 1'b1;
                else
                    addr_count <= 4'd0;

            end

            //--------------------------------

            read_zero: begin

                busy     <= 1;

                mem_we   <= 0;

                if (addr_count < 4'd8) begin
                    mem_re   <= 1;
                    mem_addr <= addr_count[2:0];
                end else begin
                    mem_re   <= 0;
                    mem_addr <= 3'd0;
                end

                if (addr_count >= 4'd2) begin
                    if (mem_rdata != 8'h00) begin
                        compare_fail <= 1;
                        error_addr   <= addr_count - 4'd2;
                    end
                end

                if (addr_count < 4'd9)
                    addr_count <= addr_count + 1'b1;
                else
                    addr_count <= 4'd0;

            end

            //--------------------------------

            write_one: begin

                busy      <= 1;

                mem_we    <= 1;
                mem_re    <= 0;

                mem_addr  <= addr_count[2:0];
                mem_wdata <= 8'hFF;

                if(addr_count < 4'd7)
                    addr_count <= addr_count + 1'b1;
                else
                    addr_count <= 4'd0;

            end

            //--------------------------------

            read_one: begin

                busy     <= 1;

                mem_we   <= 0;

                if (addr_count < 4'd8) begin
                    mem_re   <= 1;
                    mem_addr <= addr_count[2:0];
                end else begin
                    mem_re   <= 0;
                    mem_addr <= 3'd0;
                end

                if (addr_count >= 4'd2) begin
                    if (mem_rdata != 8'hFF) begin
                        compare_fail <= 1;
                        error_addr   <= addr_count - 4'd2;
                    end
                end

                if (addr_count < 4'd9)
                    addr_count <= addr_count + 1'b1;
                else
                    addr_count <= 4'd0;

            end

            //--------------------------------

            pass_state: begin

                busy      <= 0;
                done      <= 1;
                pass      <= 1;
                fail      <= 0;

                mem_we    <= 0;
                mem_re    <= 0;

                mem_addr  <= 3'd0;
                mem_wdata <= 8'd0;

            end

            //--------------------------------

            fail_state: begin

                busy      <= 0;
                done      <= 1;
                pass      <= 0;
                fail      <= 1;

                mem_we    <= 0;
                mem_re    <= 0;

                mem_addr  <= 3'd0;
                mem_wdata <= 8'd0;

            end

            //--------------------------------

            default: begin

                busy         <= 0;
                done         <= 0;
                pass         <= 0;
                fail         <= 0;

                mem_we       <= 0;
                mem_re       <= 0;

                mem_addr     <= 3'd0;
                mem_wdata    <= 8'd0;

                compare_fail <= 0;
                error_addr   <= 3'd0;

            end

        endcase

    end

end

endmodule

module shiv_sram (
    input  logic       clk,
    input  logic       we,
    input  logic       re,
    input  logic [2:0] addr,
    input  logic [7:0] wdata,
    output logic [7:0] rdata
);

logic [7:0] mem [0:7];

always_ff @(posedge clk) begin
    if (we)
        mem[addr] <= wdata;
    else if (re)
        rdata <= mem[addr];
end

endmodule
