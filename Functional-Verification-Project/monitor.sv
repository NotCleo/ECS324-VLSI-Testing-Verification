import fsm_pkg::*; 

class monitor;
  virtual seq_if vif;
  mailbox #(transaction) mon2sb;

  covergroup cg_fsm_cov @(negedge vif.clk);
    cp_din:  coverpoint vif.din;
    cp_dout: coverpoint vif.dout;

    //Regarding STATE COVERAGE: Did the tb physically enter every single state?
    cp_state: coverpoint vif.current_state {
      bins all_states[] = {S0, S1, S2, S3, S4};
    }

    //Regarding CROSS COVERAGE: Did the tb test BOTH din=0 and din=1 while sitting inside EVERY state?
    cross_state_din: cross cp_state, cp_din;

    //Regarding CROSS COVERAGE: State vs Output
    // Proves that dout=1 ONLY happens when in S4.
    cross_state_dout: cross cp_state, cp_dout {
      // It is impossible for dout to be 1 in S0, S1, S2, or S3. 
      ignore_bins impossible_outs = binsof(cp_state) intersect {S0, S1, S2, S3} && 
                                    binsof(cp_dout) intersect {1};
    }

    cp_din_seq: coverpoint vif.din {
      bins seq_11011 = (1 => 1 => 0 => 1 => 1);
      bins overlap_test = (1 => 1 => 0 => 1 => 1 => 0 => 1 => 1);
    }
  endgroup

  function new(virtual seq_if vif, mailbox #(transaction) mon2sb);
    this.vif = vif;
    this.mon2sb = mon2sb;
    cg_fsm_cov = new(); 
  endfunction

  task run();
    forever begin
      transaction trans = new();
      
      @(negedge vif.clk); 
      trans.din = vif.din;
      trans.dout = vif.dout;
      mon2sb.put(trans);
    end
  endtask
endclass