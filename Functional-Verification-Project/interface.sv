import fsm_pkg::*; 

interface seq_if(input logic clk);
  logic reset;
  logic din;
  logic dout;
  
  state_t current_state; //this looks into the DUT

  
  //assertion 1 : On every rising edge of the clock, if reset is high, then dout MUST be strictly 0
  property p_reset;
    @(posedge clk) reset |-> (dout == 1'b0);
  endproperty
  assert_reset: assert property(p_reset) else $error("Reset failed!");

    
    
  //assertion 2 : As long as we aren't resetting, check on every clock edge that din is a clean 1 or 0 (not X or Z) 
  property p_no_x_din;
    @(posedge clk) disable iff (reset) !$isunknown(din);
  endproperty
  assert_no_x_din: assert property(p_no_x_din) else $error("din is X/Z!");

    
  //assertion 3 : If the output ever spikes to 1, it implies that the input din MUST currently be a 1 on this exact same clock cycle
  property p_mealy_dout;
    @(posedge clk) disable iff (reset) (dout == 1'b1) |-> (din == 1'b1);
  endproperty
  assert_mealy_dout: assert property(p_mealy_dout) else $error("Mealy violation!");
endinterface
    
    
   /*
   what are our assertions and why them? refer report   
   */
    
    /* Difference between |-> and |=>??
    
    regarding <expr1> |-> <expr2> , 
    If the left side is true right now, the right side must also be true on this exact same clock cycle
    
    regarding <expr1> |=> <expr2> , 
   If the left side is true right now, the right side must be true on the very next clock cycle
*/
    
    /*Another trick is to do delay operations as follows : 
    
    These two lines of code do the exact same thing:

    req |=> ack;

    req |-> ##1 ack;
    */