# 4-Way Traffic Light Controller 

## 📁 Design Files & Input Assets
- `traffic.v` - Core behavioral Verilog RTL code for the FSM controller.
- `traffic_tb.v` - Structural testbench supplying simulation stimuli.

---

## 📁 Implementation Flow Stages

### 1. Simulation & Verification (`1_inputs/`)
- Functional RTL simulation validating state transitions and emergency sensor triggers via waveforms.

### 2. Logic Synthesis (`2_synthesis/`)
- Translating behavioral logic into technology-mapped gate-level netlists using Cadence Genus.

### 3. Floorplanning (`3_floorplan/`)
- Setting chip core boundaries, utilization aspect ratios, and peripheral I/O pad physical coordinates.

### 4. Power Planning (`4_powerplanning/`)
- Constructing VDD/VSS power rings and interleaved grid stripes to ensure stable voltage distribution.

### 5. Standard Cell Placement (`5_placement/`)
- Automating physical row slot assignments for all logic gates to optimize timing slack and wire length.

### ### 6. Clock Tree Synthesis - CTS (`6_cts/`)
- Building balanced clock tree networks and buffer trees to drastically reduce clock skew across sequential elements.

###### 7. Global & Detail Routing (`7_routing/`)
- Executing signal track routing across metal layers while ensuring zero open circuits.

### 8. Physical Signoff (`8_signoff/`)
- Final sign-off Design Rule Checking (DRC) verification confirming manufacturing rule compliance.

---

