# Time-Series-Analysis-of-NJ-Transit-On-Time-Bus-Performance

## 📌 Project Overview

This project analyzes monthly Bus On-Time Performance (OTP) data from NJ Transit, spanning from **January 2009 to March 2025**, with the goal of **forecasting future performance** and uncovering seasonal trends. Using classical time series modeling techniques, we identified the **SARIMA model** as the best-fit approach for capturing both trend and seasonality.

---

## 📊 Dataset Description

- **Source:** [NJ Transit Performance Data](https://www.njtransit.com/performance-data-download)  
- **Time Range:** Jan 2009 – Mar 2025  
- **Columns:**
  - `OTP_YEAR`: Year of record  
  - `OTP_MONTH`: Month of record  
  - `OTP`: On-Time Performance (%)  
  - `TOTAL_TRIPS`: Total bus trips per month  
  - `TOTAL_LATES`: Number of late trips per month  

---

## 🔍 Methodology

1. **Exploratory Data Analysis**
   - Time series plots of OTP, TOTAL_TRIPS, and TOTAL_LATES
   - Identified key disruptions (e.g., COVID-19, weather patterns)

2. **Stationarity Testing**
   - ADF Test used before and after differencing
   - Differencing confirmed necessary for stationarity

3. **Model Identification**
   - ACF & PACF plots suggested ARIMA(2,1,1) and ARIMA(1,1,1) as candidates
   - Compared using AIC/BIC → ARIMA(1,1,1) selected

4. **SARIMA Modeling**
   - Introduced seasonal component → SARIMA(1,1,1)(0,1,1)[12]
   - Improved residual diagnostics and seasonality capture

5. **Model Evaluation**
   - Residual analysis, ACF of residuals, Ljung-Box test, histogram, and QQ plot

6. **Forecasting**
   - 12-month forecast through March 2026
   - Projected OTP range: **88% – 93%**

---

## ✅ Key Insights

- **Seasonal Dips:** Recurring performance drops in early months due to operational/weather challenges.
- **Pandemic Impact:** Significant dip during 2020–2021; recovery seen post-2022.
- **Business Insight:** Forecast suggests an optimistic performance trend in late 2025, aligning with financial recovery reports from NJ Transit.

---

## 📁 Files

- `MA641 Final Project 1.pdf`: Complete project report with analysis, plots, and code appendix.
- `nj_transit_otp.csv` (if included): Cleaned dataset used for modeling.
- `Project-1.R`: R script containing all code for preprocessing, modeling, and forecasting.

---

## 📚 References

[1] NJ Transit Performance Data  
🔗 https://www.njtransit.com/performance-data-download
