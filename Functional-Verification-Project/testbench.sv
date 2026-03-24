`include "fsm_pkg.sv" 

`include "interface.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "env.sv"

module testbench;
  logic clk;
  
  // Instantiate the interface
  seq_if vif(clk);
  
  // Instantiate the DUT
  sd11011_mealy_pure DUT (
    .clk(vif.clk),
    .reset(vif.reset),
    .din(vif.din),
    .dout(vif.dout)
  );

  // write the internal DUT state to the interface wire for the Monitor
  assign vif.current_state = DUT.current_state;

  // Declare the environment handle
  env environment;

  // Clock Generation: 10 time units period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Main Simulation Execution Block
  initial begin
    environment = new(vif);
    
    // Initial reset sequence
    vif.reset = 1;
    vif.din = 0;
    #15;
    vif.reset = 0;

    environment.run();
    
    /*
    The term .run() in SystemVerilog generally refers to a task defined by the user (so if we open the env.sv, that's where run() is defined) within a testbench component, rather than a built-in SystemVerilog keyword or function. This task encapsulates the main execution logic for a specific part of the verification environment.
    */
    
    // Wait for the Scoreboard to finish checking all 100 transactions
    wait(environment.sb.trans_checked == 100);
    
    repeat(5) @(posedge clk); 
    
    $display("=================================================");
    $display("--- SIMULATION COMPLETE ---");
    $display("Total Functional Coverage:  %0.2f%%", environment.mon.cg_fsm_cov.get_coverage());
    $display("Cross Coverage (State x Din): %0.2f%%", environment.mon.cg_fsm_cov.cross_state_din.get_coverage());
    $display("Cross Coverage (State x Dout): %0.2f%%", environment.mon.cg_fsm_cov.cross_state_dout.get_coverage());
    $display("=================================================");
    
    $stop; 
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);
  end

endmodule