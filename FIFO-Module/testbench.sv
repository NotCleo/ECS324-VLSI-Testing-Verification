// INTERFACE
interface fifo_intf(input logic clk, input logic reset);
  logic wr_en;
  logic rd_en;
  logic [7:0] wdata;
  logic [7:0] rdata;
  logic full;
  logic empty;

  always @(posedge clk) begin
    if (reset == 0) begin
      if (wr_en == 1 && full == 1) 
        $error("PROTOCOL VIOLATION: Write attempted when FIFO full!");
      
      if (rd_en == 1 && empty == 1) 
        $error("PROTOCOL VIOLATION: Read attempted when FIFO empty!");
    end
  end
endinterface

// TRANSACTION
class transaction;
  rand bit wr_en;
  rand bit rd_en;
  rand bit [7:0] wdata;
  bit [7:0] rdata;
  bit full;
  bit empty;

  constraint wr_rd_c { wr_en != rd_en; } 

  function transaction do_copy();
    transaction trans = new();
    trans.wr_en = this.wr_en;
    trans.rd_en = this.rd_en;
    trans.wdata = this.wdata;
    trans.rdata = this.rdata;
    trans.full  = this.full;
    trans.empty = this.empty;
    return trans;
  endfunction
endclass

// GENERATOR
class generator;
  rand transaction trans;
  int repeat_count;
  mailbox gen2driv;
  event ended;

  function new(mailbox gen2driv, event ended);
    this.gen2driv = gen2driv;
    this.ended = ended;
    trans = new();
  endfunction

  task main();
    transaction tr;
    repeat(repeat_count) begin
      trans.randomize();      
      tr = trans.do_copy();
      gen2driv.put(tr);
    end
    -> ended; 
  endtask
endclass

// DRIVER
class driver;
  int no_transactions;
  virtual fifo_intf fifo_vif;
  mailbox gen2driv;

  function new(virtual fifo_intf fifo_vif, mailbox gen2driv);
    this.fifo_vif = fifo_vif;
    this.gen2driv = gen2driv;
  endfunction

  task reset;
    wait(fifo_vif.reset == 1);
    $display("Reset Started");
    fifo_vif.wr_en <= 0;
    fifo_vif.rd_en <= 0;
    fifo_vif.wdata <= 0;        
    wait(fifo_vif.reset == 0);
    $display("Reset Ended");
  endtask

  task drive;
    transaction trans;
    gen2driv.get(trans);
    
    @(posedge fifo_vif.clk);
    
    // Write Operation
    if (trans.wr_en == 1 && fifo_vif.full == 0) begin
      fifo_vif.wr_en <= 1;
      fifo_vif.wdata <= trans.wdata;
      @(posedge fifo_vif.clk); 
      fifo_vif.wr_en <= 0;
      $display("Write wdata = %0h", trans.wdata);
    end
    
    // Read Operation
    if (trans.rd_en == 1 && fifo_vif.empty == 0) begin
      fifo_vif.rd_en <= 1;
      @(posedge fifo_vif.clk); // Send command
      fifo_vif.rd_en <= 0;
      @(posedge fifo_vif.clk); 
      trans.rdata = fifo_vif.rdata;
      $display("[DRIVER] Read rdata = %0h", trans.rdata);
    end
    
    no_transactions++;
  endtask

  task main;
    forever begin
      fork
        begin wait(fifo_vif.reset == 1); end
        begin forever drive(); end
      join_any
      disable fork;
    end
  endtask
endclass

// MONITOR
class monitor;
  virtual fifo_intf fifo_vif;
  mailbox mon2scb;

  covergroup fifo_cg;
    option.per_instance = 1; 
    c_full:  coverpoint fifo_vif.full;
    c_empty: coverpoint fifo_vif.empty;
    c_write: coverpoint fifo_vif.wr_en;
    c_read:  coverpoint fifo_vif.rd_en;
    
    c_wdata: coverpoint fifo_vif.wdata {
      bins low = {[0:85]};
      bins mid = {[86:170]};
      bins high = {[171:255]};
    }
    c_rdata: coverpoint fifo_vif.rdata {
      bins low = {[0:85]};
      bins mid = {[86:170]};
      bins high = {[171:255]};
    }
  endgroup

  function new(virtual fifo_intf fifo_vif, mailbox mon2scb);
    this.fifo_vif = fifo_vif;
    this.mon2scb = mon2scb;
    fifo_cg = new(); 
  endfunction

  task main;
    forever begin
      transaction trans = new();
      @(posedge fifo_vif.clk);
      
      fifo_cg.sample();

      if (fifo_vif.wr_en == 1 || fifo_vif.rd_en == 1) begin
        trans.wr_en = fifo_vif.wr_en;
        trans.wdata = fifo_vif.wdata;
        trans.rd_en = fifo_vif.rd_en;
        trans.full  = fifo_vif.full;
        trans.empty = fifo_vif.empty;
        
        if (fifo_vif.rd_en == 1) begin
           @(posedge fifo_vif.clk); 
           trans.rdata = fifo_vif.rdata;
        end      
        mon2scb.put(trans);
      end
    end
  endtask
endclass

// SCOREBOARD
class scoreboard;
  mailbox mon2scb;
  int no_transactions;
  
  bit [7:0] ref_fifo [$];

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task main;
    transaction trans;
    bit [7:0] expected_data;

    forever begin
      mon2scb.get(trans);
      
      if (trans.wr_en == 1 && trans.full == 0) begin
        ref_fifo.push_back(trans.wdata);
        $display("Pushed expected data: %0h", trans.wdata);
      end
      
      if (trans.rd_en == 1 && trans.empty == 0) begin
        if (ref_fifo.size() > 0) begin
          expected_data = ref_fifo.pop_front();
          
          if (expected_data != trans.rdata) begin
            $error("[SCB-FAIL] Expected = %0h Actual = %0h", expected_data, trans.rdata);
          end else begin
            $display("[SCB-PASS] Expected = %0h Actual = %0h", expected_data, trans.rdata);
          end
        end
      end
      no_transactions++;
    end
  endtask
endclass

// ENVIRONMENT
class environment;
  generator  gen;
  driver     driv;
  monitor    mon;
  scoreboard scb;
  
  mailbox gen2driv;
  mailbox mon2scb;
  event gen_ended;
  virtual fifo_intf fifo_vif;

  function new(virtual fifo_intf fifo_vif);
    this.fifo_vif = fifo_vif;
    gen2driv = new();
    mon2scb  = new();
    
    gen  = new(gen2driv, gen_ended);
    driv = new(fifo_vif, gen2driv);
    mon  = new(fifo_vif, mon2scb);
    scb  = new(mon2scb);
  endfunction

  task test();
    fork 
      gen.main();
      driv.main();
      mon.main();
      scb.main();      
    join_any
  endtask

  task run;
    driv.reset();
    test();
    
    wait(gen_ended.triggered);
    wait(gen.repeat_count == driv.no_transactions);
    
    $display("Functional Coverage: %0.2f%%", mon.fifo_cg.get_inst_coverage());
    $finish;
  endtask
endclass

// TEST PROGRAM
program test(fifo_intf intf);
  environment env;
  initial begin
    env = new(intf);
    env.gen.repeat_count = 50; 
    env.run();
  end
endprogram

// TOP MODULE
module tbench_top;
  bit clk;
  bit reset;

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    reset = 1;
    #15 reset = 0;
  end

  fifo_intf intf(clk, reset);
  test t1(intf);

  fifo DUT (
    .clk(intf.clk),
    .reset(intf.reset),
    .wr_en(intf.wr_en),
    .rd_en(intf.rd_en),
    .wdata(intf.wdata),
    .rdata(intf.rdata),
    .full(intf.full),
    .empty(intf.empty)
   );

  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule
