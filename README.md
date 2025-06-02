# AGI Profitability Simulator

## Overview

The **AGI Profitability Simulator** is a Shiny web application designed to simulate and forecast the profitability of Artificial Intelligence (AI) models over a specified time horizon. It allows users to adjust various parameters related to revenue, costs, and market dynamics, and visualizes profitability trends over time.

This tool is particularly useful for researchers, analysts, and decision-makers interested in understanding the financial implications of AGI development and deployment.

---

## Features

- **Dynamic Parameter Adjustment**: Modify simulation parameters such as time horizon, markup, growth rates, and cost assumptions.
- **Revenue and Cost Modeling**: Simulate operational costs and revenue based on compute price-performance trends and usage.
- **Profitability Visualization**: Generate interactive plots showing yearly profits and cumulative net present value (NPV).
- **Advanced Settings**: Customize training precision, compute price-performance assumptions, and firm discount rates.
- **Debugging Information**: Provides detailed intermediate calculations for transparency and analysis.

---

## Installation and Setup

### Prerequisites
Ensure the following are installed on your system:
1. **R** (version 4.0 or higher)
2. **RStudio** (optional but recommended)
3. Required R libraries:
   - `shiny`
   - `ggplot2`
   - `readxl`
   - `dplyr`
   - `scales`

### Steps
1. Clone or download the repository containing the application code.
2. Place the input data file (`DATA.xlsx`) in the same directory as the application code.
3. Open the R script in RStudio (or your preferred R environment).
4. Run the script to launch the Shiny app.

---

## Input Data

The application requires an Excel file (`DATA.xlsx`) containing historical and forecasted data. This data should include:
- **Year**: The year for each data point.
- **INF_FLOP**: Projected FLOPs for model inference.
- **Projected_FLOP**: Projected FLOPs for model training.
- **Cost Columns**: Fixed training costs (e.g., `C_FP32_Rapid`, `C_FP16_Medium`).
- **Price-Performance Columns**: Compute price-performance values (e.g., `FP32_Rapid`, `FP16_Medium`).

Ensure the column names match those referenced in the code.

---

## How to Use

1. **Launch the App**: Run the script in RStudio. The application will open in your default web browser.
2. **Set Simulation Parameters**:
   - Adjust the **Time (Years)**, **Markup**, **Annual Usage Growth Rate**, and other inputs in the sidebar.
   - Select advanced settings such as **Training Precision** and **Compute Price-Performance** assumptions.
3. **View Results**:
   - The main panel displays a plot of yearly profits.
   - Net Present Value (NPV) is annotated on the plot for quick interpretation.
4. **Debugging Information**:
   - Intermediate calculations such as revenue, operational costs, and compute values are logged for detailed analysis.

---

## Key Components

### User Interface (UI)
The UI consists of:
- **Sidebar Panel**: For inputting simulation parameters.
- **Main Panel**: For displaying the profitability plot.

### Server Logic
The server processes user inputs, performs calculations, and renders outputs:
- **Profit Calculation**: Computes yearly profits and cumulative NPV based on user-defined parameters.
- **Dynamic Plot Generation**: Visualizes profitability trends using `ggplot2`.

---

## Customization

### Modify the Input Data
To adapt the simulation for different datasets:
- Update the `DATA.xlsx` file with relevant data.
- Ensure column names align with those used in the code.

### Extend the Functionality
You can add features such as:
- Additional cost/revenue parameters.
- Support for different discounting models.
- Enhanced visualizations (e.g., interactive plots).

---

## Known Issues and Limitations

1. **Data Dependency**: The app relies heavily on the structure and quality of the input Excel file. Ensure the file is formatted correctly.
2. **Scalability**: Large time horizons or complex datasets may cause performance issues.
3. **Assumptions**: The simulation assumes certain trends (e.g., compute price-performance) which may not reflect real-world dynamics.

---

## License

This project is open-source and licensed under [MIT License](https://opensource.org/licenses/MIT).

---

## Contact

For questions, feedback, or contributions, feel free to reach out via GitHub or email.

--- 

Enjoy simulating AGI profitability!
