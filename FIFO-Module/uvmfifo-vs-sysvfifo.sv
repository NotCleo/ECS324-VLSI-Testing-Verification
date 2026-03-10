/*Implement a FIFO using 
1) sysv generator-driver using mailbox
2) uvm sequencer-driver using tlm ports

questions;

a) create analogy between both
  
  in sysv tb, you have generator-driver and a mailbox and remaining everything remains same
  in uvm tb, you have sequence-sequencer-driver and tlm ports and remaining everything remains same


b) difference b/w mailbox and tlm ports

in UVM (Universal Verification Methodology), the full form of TLM is Transaction-Level Modeling. It is a high-level approach to modeling communication between components (such as producers and consumers) using function calls (API) rather than signal-level toggling, typically implemented using ports, exports, and imps to pass transaction objects

A TLM fifo is a mailbox implemented using standard TLM ports and exports as an API to the mailbox. The TLM API gives you a separation of concerns which in turn promotes re-usability and maintainability.

Let’s say you have two components: A and B. Component A has a thread doing puts and component B has a thread doing gets. They are both connected through a common mailbox which means they both must declare handles to a matching mailbox type. This creates an unwanted dependency. At some point, I might want some other component other than a mailbox to connect to, like some kind of arbitrator. So I would have to modify the handles types in the components.

TLM gets rid of that dependency. Component A can have a put_port and just requires that what it is connected to implements a put method. Component B can have a get_port and just requires that what it is connected to implements a get method.



using a mailbox forces a connection between components to use a mailbox protocol where there is one thread calling a mailbox.put(t), and another thread calling a mailbox.get(t).

When you use a TLM port, you just call put(t) and have no knowledge of how the put is implemented. You just know that a put() blocks until the transfer of t completes. In the case of a TLM fifo, the TLM put()happens to be implemented as a mailbox.put(), but the calling process does not know that. It is possible that the implementation of put does everything and there is no need for another process to do a get().





c) role of sequencer in uvm

https://vlsiverify.com/uvm/uvm-sequencer/

The sequencer is a mediator who establishes a connection between sequence and driver. Ultimately, it passes transactions or sequence items to the driver so that they can be driven to the DUT.




d) in uvm, user defined class extends base class, whats the syntax and also give it in context for a driver*/


// Syntax: class <child_class> extends <base_class> #(<parameter_type>);
class my_fifo_driver extends uvm_driver #(fifo_transaction);
  `uvm_component_utils(my_fifo_driver) // Factory registration
  
  // Standard UVM constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  // ...
endclass


//--------------------------------------------------------------------------------------------------------------------------------------------------------------


//Generator - Driver using Mailbox implementation for FIFO

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







        

//uvm equivalent

        import uvm_pkg::*;
`include "uvm_macros.svh"

// 1. Transaction (Sequence Item)
class fifo_seq_item extends uvm_sequence_item;
  rand bit wr_en;
  rand bit rd_en;
  rand bit [7:0] wdata;
  bit [7:0] rdata;

  `uvm_object_utils_begin(fifo_seq_item)
    `uvm_field_int(wr_en, UVM_ALL_ON)
    `uvm_field_int(rd_en, UVM_ALL_ON)
    `uvm_field_int(wdata, UVM_ALL_ON)
    `uvm_field_int(rdata, UVM_ALL_ON)
  `uvm_object_utils_end

  constraint c_op { wr_en != rd_en; }

  function new(string name = "fifo_seq_item");
    super.new(name);
  endfunction
endclass

// 2. Sequence (Replaces the Generator)
class fifo_sequence extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(fifo_sequence)
  
  int no_transactions = 10;

  function new(string name = "fifo_sequence");
    super.new(name);
  endfunction

  task body();
    repeat(no_transactions) begin
      req = fifo_seq_item::type_id::create("req");
      start_item(req);         // Wait for sequencer grant
      assert(req.randomize()); // Randomize transaction
      finish_item(req);        // Send to driver
    end
  endtask
endclass

// 3. Sequencer (The Mediator)
typedef uvm_sequencer #(fifo_seq_item) fifo_sequencer; 
// Note: In modern UVM, you rarely need to write a custom sequencer class unless adding specific arbitration logic. A typedef is sufficient.

// 4. Driver
class fifo_driver extends uvm_driver #(fifo_seq_item);
  `uvm_component_utils(fifo_driver)

  virtual fifo_intf fifo_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual fifo_intf)::get(this, "", "fifo_vif", fifo_vif))
      `uvm_fatal("NO_VIF", "Virtual interface not found!")
  endfunction

  task run_phase(uvm_phase phase);
    // Reset sequence
    wait(fifo_vif.reset == 1);
    `uvm_info("DRV", "Reset Started", UVM_LOW)
    fifo_vif.wr_en <= 0;
    fifo_vif.rd_en <= 0;
    fifo_vif.wdata <= 0;        
    wait(fifo_vif.reset == 0);
    `uvm_info("DRV", "Reset Ended", UVM_LOW)

    forever begin
      // TLM Port gets the item from the sequencer
      seq_item_port.get_next_item(req); 
      
      @(posedge fifo_vif.clk);
      
      if (req.wr_en == 1 && fifo_vif.full == 0) begin
        fifo_vif.wr_en <= 1;
        fifo_vif.wdata <= req.wdata;
        @(posedge fifo_vif.clk); 
        fifo_vif.wr_en <= 0;
        `uvm_info("DRV", $sformatf("Write wdata = %0h", req.wdata), UVM_LOW)
      end
      
      if (req.rd_en == 1 && fifo_vif.empty == 0) begin
        fifo_vif.rd_en <= 1;
        @(posedge fifo_vif.clk);
        fifo_vif.rd_en <= 0;
        @(posedge fifo_vif.clk); 
        req.rdata = fifo_vif.rdata; // Pass data back to sequence if needed
        `uvm_info("DRV", $sformatf("Read rdata = %0h", req.rdata), UVM_LOW)
      end
      
      // Tell the sequencer we are done with this item
      seq_item_port.item_done();
    end
  endtask
endclass
  
