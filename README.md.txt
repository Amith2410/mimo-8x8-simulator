# 📡 8x8 MIMO System Simulator

This project simulates an **8x8 MIMO wireless communication system** using MATLAB. It evaluates the **Bit Error Rate (BER)** performance under different decoders:

- MMSE (Minimum Mean Square Error)
- ZF (Zero Forcing)
- ZF-SIC (Successive Interference Cancellation)
- MLD (Maximum Likelihood Detection)

---

## 🔍 Features

- Simulates 8x8 MIMO channel with complex Gaussian coefficients
- Supports 4-QAM modulation
- Implements MMSE, ZF, ZF-SIC, and MLD decoders
- Evaluates BER performance over varying SNR values (0–20 dB)
- Plots BER vs SNR for all decoders

---

## 📂 File Structure

| File/Folder         | Description                                      |
|---------------------|--------------------------------------------------|
| `src/mimo_simulation.m` | Main MATLAB simulation code                  |
| `plots/example_ber_plot.png` | Sample output plot (add manually)       |
| `requirements.txt`  | System requirements (MATLAB/Octave)              |
| `README.md`         | Project documentation                           |
| `LICENSE`           | MIT License (recommended)                        |

---

## ▶️ How to Run

1. Open `src/mimo_simulation.m` in **MATLAB** or **GNU Octave**
2. Run the script
3. Check the generated **BER vs SNR** plot and outputs in the console

---

## 📊 Sample Output

![BER Comparison](plots/example_ber_plot.png)

---

## 📦 Requirements

- MATLAB R2020a+ or GNU Octave
- Toolboxes:
  - Communications Toolbox (for `qammod`, `qamdemod`)

If using Octave, install `communications` package via:
```octave
pkg install -forge communications
pkg load communications
