vlib work                                     
vlog fsm_pkg.sv design.sv testbench.sv        
vsim -coverage -voptargs=+acc work.testbench  
run -all                                      
coverage report -details                     
quit                                         