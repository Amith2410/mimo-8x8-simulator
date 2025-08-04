# MIMO 8x8 System Simulator

A MATLAB-based simulation of an 8x8 MIMO wireless communication system supporting different decoding techniques:

- MMSE (Minimum Mean Square Error)
- ZF (Zero Forcing)
- ZF-SIC (Zero Forcing with Successive Interference Cancellation)
- MLD (Maximum Likelihood Detection)

## 📁 Structure

mimo-8x8-simulator/
├── src/
│ └── mimo_simulation.m # Main MATLAB script
├── .gitignore
├── LICENSE
├── README.md
└── requirements.txt


## 🚀 Features

- Fully customizable number of antennas
- Configurable SNR ranges
- Visualization of BER vs. SNR performance for different decoders

## 🛠️ Requirements

- MATLAB R2019+ recommended
- Communications System Toolbox (for some decoding functions)

Install dependencies (if needed):


## 📊 Output

- Plots for BER comparison between MMSE, ZF, ZF-SIC, and MLD
- Performance metrics at varying SNR values

![WhatsApp Image 2025-08-04 at 16 37 06_a2bd30e9](https://github.com/user-attachments/assets/ed2d422e-a508-411b-8185-d544cf7c0a22)


## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
