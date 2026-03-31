Note : Refer Report analysis text file where I have run the tool for different constraint files and compiled it in a table

### 1. Significance of the SDC Commands

The SDC (Synopsys Design Constraints) file is the bridge between the design intent and the physical reality of the chip

* **`clock period = 10ns` (`create_clock`)**
  This establishes the fundamental heartbeat of your design. It tells the tool that a new clock edge arrives every 10ns (100 MHz frequency). All default setup and hold checks are mathematically derived from this 10ns window.

* **`input delay : max = 2ns, min = 0.5ns` (`set_input_delay`)**
  This accounts for the time it takes for a signal to travel from an external chip through the PCB and into our INP pin.
  * The **max** value (2ns) is used for Setup Analysis (worst-case late arrival).
  * The **min** value (0.5ns) is used for Hold Analysis (worst-case early arrival).

* **`output delay : max = 3ns, min = 1ns` (`set_output_delay`)**
  This tells the tool how much time the external world needs to capture the signal leaving your OUTB pin. If the clock period is 10ns, and the external world needs 3ns (max), the internal logic only has 7ns to get the data to the output pin.

* **`clock uncertainty : setup = 0.2ns, hold = 0.1ns` (`set_clock_uncertainty`)**
  In the real world, clock edges are never perfectly sharp or perfectly on time (due to jitter and skew). This command adds a pessimistic "safety margin." The tool will artificially subtract 0.2ns from your setup required time and add 0.1ns to the hold required time to ensure the chip works even with imperfect clocks.

* **`path from FF1 to FF2 is multicycle = 2` (`set_multicycle_path`)**
  By default, data launched by FF1 on clock edge 1 must be captured by FF2 on clock edge 2 (a 1-cycle window). This command relaxes that rule. It tells the tool: "The combinational logic Y=(A&B)|C is complex. Give it 2 full clock cycles (20ns) to resolve before checking setup timing."


  ### Effect of Increasing Input Delay on Slack

If we increase the input delay constraints, the tool will set that the external signal arrives at the chip later. 

Here is how it alters the slack on the `INP -> FF1` path:

**For Setup Slack (Max Delay):**
Setup slack calculates if the data arrives fast enough.

$$\text{Setup Slack} = \text{Data Required Time} - \text{Data Arrival Time}$$

* If we increase the max input delay, the $\text{Data Arrival Time}$ becomes larger (the data arrives later).
* **Result:** The Setup Slack will **decrease** (worsen). If we increase it too much, the slack will become negative, causing a setup violation.

**For Hold Slack (Min Delay):**
Hold slack calculates if the data stays stable long enough after the clock edge so it doesn't accidentally overwrite the previous data.

$$\text{Hold Slack} = \text{Data Arrival Time} - \text{Data Required Time}$$

* If we increase the min input delay, the $\text{Data Arrival Time}$ increases (the new data takes longer to arrive, keeping the old data stable longer).
* **Result:** The Hold Slack will **increase** (improve).


### Effect of Removing Timing Relaxation (Multicycle Path)

If we remove the `multicycle = 2` constraint on the path from FF1 to FF2, we are forcing the STA tool to revert to its default behavior: checking the setup timing at **1 clock cycle (10ns)** instead of **2 clock cycles (20ns)**.

* **Before (Multicycle = 2):** The logic had roughly $\approx 19.8\text{ns}$ to complete ($20\text{ns} - 0.2\text{ns uncertainty}$).
* **After (Removed):** The logic now only has roughly $\approx 9.8\text{ns}$ to complete ($10\text{ns} - 0.2\text{ns uncertainty}$).

**Result:** The Setup Slack on the `FF1 -> FF2` path will **decrease drastically by exactly one clock period (10ns)**. If the combinational logic $Y$ actually takes, for example, 12ns to compute, removing this relaxation will immediately cause a severe **negative setup slack violation (-2.2ns)**, and the design will fail timing verification.


