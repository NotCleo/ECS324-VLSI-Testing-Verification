class transaction;
  rand bit din;
  bit dout;

  
  // Regarding "dist", 
  //Constraint provides control on randomization, from which the user can control the values on randomization. 
  //it would be good if it’s possible to control the occurrence or repetition of the same value on randomization. 
  
  
  constraint din_dist {
    din dist {1 := 85, 0 := 15}; // so here's the weights are 50-50 meaning 1 and 0 in the constraint occurs with equal chance (this has a direct effect on the coverage and cross coverage values)
  }
endclass


//transaction class is only about setting up constraints on the generator's stimuli generation, like how it makes the 1 and 0 and with how much randomization