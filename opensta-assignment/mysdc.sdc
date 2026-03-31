create_clock -name CLK -period 10.0 [get_ports CLK]

# 2. Clock uncertainty: setup = 0.2ns, hold = 0.1ns
set_clock_uncertainty -setup 0.2 [get_clocks CLK]
set_clock_uncertainty -hold 0.1 [get_clocks CLK]

# 3. Input delay: max = 2ns, min = 0.5ns
# Applying this to all inputs relative to the clock
set_input_delay -max 2.0 -clock CLK [get_ports {INP B C}]
set_input_delay -min 0.5 -clock CLK [get_ports {INP B C}]

# 4. Output delay: max = 3ns, min = 1ns
set_output_delay -max 3.0 -clock CLK [get_ports OUTB]
set_output_delay -min 1.0 -clock CLK [get_ports OUTB]

# 5. Path from FF1 to FF2 is multicycle = 2
# We target the registers directly. 
# Note: Setting setup multicycle to 2 usually requires setting hold multicycle to 1 
# to prevent the hold check from shifting forward by a cycle.
set_multicycle_path -setup 2 -from [get_cells ff1_out_reg] -to [get_cells OUTB_reg]
set_multicycle_path -hold 1 -from [get_cells ff1_out_reg] -to [get_cells OUTB_reg]
