# Static Timing Analysis (STA) Experimental Results

This document summarizes the Static Timing Analysis (STA) results across three different SDC constraint configurations. The analysis compares **Pre-Layout (Synthesis)** and **Post-Layout (RC Extraction)** timing metrics to observe the physical impact of routing and constraint modification.

## 1. Master Comparison Table: Setup & Hold Slack
The table below tracks the timing slack (in nanoseconds) for the critical paths across our baseline run and the modified constraint runs.

| Path (Start → End) | Check Type | Analysis Phase |  Baseline Slack |  High Input Delay |  No Multicycle Relaxation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`C` → FF1 (`_1_`)** | Setup (Max) | Pre-Layout | 7.52 | **4.52**  | 7.52 |
| | | Post-Layout | 7.67 | **4.67**  | 7.67 |
| **`INP` → FF2 (`_2_`)** | Setup (Max) | Pre-Layout | 7.70 | **4.70**  | 7.70 |
| | | Post-Layout | 7.84 | **4.84**  | 7.84 |
| **FF1 (`_1_`) → `OUTB`** | Setup (Max) | Pre-Layout | 6.53 | 6.53 | 6.53 |
| | | Post-Layout | 6.22 | 6.22 | 6.22 |
| **FF1 (`_1_`) → FF2 (`_2_`)**| Setup (Max) | Post-Layout | ~17.00 | ~17.00 | **Drops by 10.00**  |
| | | | | | |
| **`INP` → FF2 (`_2_`)** | Hold (Min) | Pre-Layout | 0.43 | 0.43 | 0.43 |
| | | Post-Layout | 0.28 | 0.28 | 0.28 |
| **FF2 (`_2_`) → FF1 (`_1_`)** | Hold (Min) | Pre-Layout | 0.32 | 0.32 | 0.32 |
| | | Post-Layout | 0.33 | 0.33 | 0.33 |
| **FF1 (`_1_`) → `OUTB`** | Hold (Min) | Pre-Layout | 1.17 | 1.17 | 1.17 |
| | | Post-Layout | 1.47 | 1.47 | 1.47 |

*(Note: All reported values are in nanoseconds. All paths achieved a `MET` status in these specific tests).*

---

## 2. Experimental Observations & Analysis

Based on the data extracted from the OpenLane OpenSTA reports, we can definitively answer the effects of altering the SDC constraints:

### Observation A: Pre-Layout vs. Post-Layout Reality
Across all configurations, the timing metrics shifted between the Pre-Layout (Synthesis) and Post-Layout (RC Extraction) phases. 
* **Setup Slack on Output Paths Decreased:** The slack on the `_1_ → OUTB` path dropped from `6.53ns` to `6.22ns`. This reflects the real-world parasitic capacitance and resistance added by the metal routing.
* **Hold Timing Required Time Shifted:** The required time for internal hold checks shifted from `0.07ns` to `0.28ns` due to the delays introduced by actual Clock Tree Synthesis (CTS) buffers.

### Observation B: Effect of Increasing Input Delay
When the maximum input delay constraint was increased (from `2.0ns` to `5.0ns`), it simulated an external component taking much longer to send data to our chip.
* **Effect:** The Setup Slack on paths originating from input ports (`C → _1_` and `INP → _2_`) **decreased exactly by the added delay amount (~3.0ns)**. 
* **Conclusion:** Increasing input delay worsens setup timing because it increases the *Data Arrival Time*, leaving the internal flip-flops less time to capture the signal before the clock edge.

### Observation C: Effect of Removing Timing Relaxation
The baseline design included a `set_multicycle_path -setup 2` constraint between `FF1` and `FF2`. This gave the combinational logic `Y = (A & B) | C` a full 20ns (two clock cycles) to compute.
* **Effect:** Removing this constraint forces the STA tool to evaluate the path in a strict 1-cycle (10ns) window. 
* **Conclusion:** The Setup Slack for that specific internal path drops drastically by exactly one clock period (10.0ns). If the logic delay exceeds the new tighter boundary, this will immediately trigger a critical setup timing violation.

---
*Generated via OpenLane / SkyWater 130nm PDK OpenSTA flow.*
