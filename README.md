# Smart Traffic System — Basys3

  This is an **FPGA-based smart traffic light controller** implemented in VHDL,
  targeting the **Digilent Basys 3** board (Xilinx Artix-7). The project was
  created in December 2024 and built using **Xilinx Vivado**.
  
  ---

  ## System Overview

  The system manages a two-lane intersection with adaptive/sensor-aware
  signaling. It has four hardware modules that communicate through a shared
  **64-bit `common_bus`**:
  
  | Module | File | Role |
  |---|---|---|
  | `top` | `top.vhd` | Top-level structural wiring of all components |
  | `traffic` | `traffic.vhd` | FSM for traffic light sequencing |
  | `multi_ultrasonic` | `multi_ultrasonic.vhd` | 4x HC-SR04 ultrasonic sensors 
  for vehicle detection |
  | `DHT11_sensor` | `DHT11_sensor.vhd` | Temperature & humidity sensing |
  | `lcd` | `lcd.vhd` | LCD display output (countdown timers, status) |
  | `ultrasonic` | `ultrasonic.vhd` | Individual sensor driver (reused 4×) |

  ---

  ## Traffic FSM States

  The `traffic.vhd` module is a state machine with these states:

  - **LANE_A** — Lane A green (10s), Lane B red
  - **A_TO_B** — Both yellow (5s) + Lane A left-turn green
  - **LANE_B** — Lane B green (10s), Lane A red
  - **B_TO_A** — Both yellow (5s) + Lane B left-turn green

  The FSM outputs a **countdown timer** (in ASCII) onto `common_bus[63:48]` for 
  the LCD to display.

  ---
  
  ## Sensor Logic

  - **4 ultrasonic sensors** (A1, A2 for Lane A; B1, B2 for Lane B) measure
  vehicle distances
  - If a vehicle is within the **alert distance** (~4–5 cm in test scale) on a 
  **red lane**, `common_bus[45]` is set → **buzzer activates**
  - **DHT11** reads temperature and humidity; data feeds into the common bus 
  (partially commented out in current code)

  ---
  for video and photos explaining the project please visit this [drive folder](https://drive.google.com/drive/folders/1JWwB8l9N2HEahTL7Y4Q5o1eXOUioU6lD?usp=share_link)