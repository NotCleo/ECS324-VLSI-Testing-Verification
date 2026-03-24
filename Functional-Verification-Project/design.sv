`include "fsm_pkg.sv" 
import fsm_pkg::*;    

module sd11011_mealy_pure (
  input  logic clk,
  input  logic reset,
  input  logic din,
  output logic dout
);
  
  state_t current_state, next_state;

  always_ff @(posedge clk or posedge reset) 
    begin
    if (reset) current_state <= S0;
    else       current_state <= next_state;
  end

  always_comb 
    begin
    next_state = current_state;
    dout = 1'b0;                

    case (current_state)
      S0: if (din)  next_state = S1; else next_state = S0;
      S1: if (din)  next_state = S2; else next_state = S0;
      //11011
      S2: if (~din) next_state = S3; else next_state = S2; // we will push this aspect using the constrained randomization by forcing the generation to be 1 with 90% chance and 0 with 10% chance and we will observe the coverage drop significantly, although 90:10 would run faster (faster in terms of state exploration) as well as almost all states progress further with din == 1
      
      S3: if (din)  next_state = S4; else next_state = S0; 
      S4: if (din) begin
            next_state = S0; 
            dout = 1'b1;     
          end else begin
            next_state = S0; 
          end
      default: next_state = S0;
    endcase
  end
endmodule