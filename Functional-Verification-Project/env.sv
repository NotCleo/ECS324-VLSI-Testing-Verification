class env;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sb;
  
  //make handles of all the core components and then just concurrently start via fork-join
  
  mailbox #(transaction) gen2driv;
  mailbox #(transaction) mon2sb;
  virtual seq_if vif;

  function new(virtual seq_if vif);
    this.vif = vif;
    gen2driv = new();
    mon2sb = new();
    
    gen = new(gen2driv);
    drv = new(vif, gen2driv);
    mon = new(vif, mon2sb);
    sb  = new(mon2sb);
  endfunction

  task run();
    fork
      gen.run();
      drv.run();
      mon.run();
      sb.run();
    join_none 
  endtask
endclass