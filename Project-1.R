#Seasonal Dataset of NJ Transit On-Time Bus Performance
#Forecasting the On-Time Performance for net 12 months

library(tidyverse)
library(lubridate)
library(ggplot2)
library(scales)
library(tseries)
library(urca)
library(forecast)

setwd("C:/Users/akank/Downloads")
data <- read.csv("BUS_OTP_DATA.csv", stringsAsFactors = FALSE)

#Cleaning the data and converting the data type
names(data) <- toupper(trimws(names(data)))
data <- data[data$OTP_YEAR != "----------", ]
data <- data %>%
  mutate(
    OTP_YEAR = as.integer(OTP_YEAR),
    OTP_MONTH = as.integer(OTP_MONTH),
    OTP = as.numeric(OTP),
    TOTAL_TRIPS = as.numeric(TOTAL_TRIPS),
    TOTAL_LATES = as.numeric(TOTAL_LATES),
    DATE = make_date(year = OTP_YEAR, month = OTP_MONTH)
  )

head(data, 10)

# GG Plot for OTP over time
ggplot(data, aes(x = DATE, y = OTP)) +
  geom_line(color = "purple", linewidth = 1) +
  labs(title = "Bus On-Time Performance Over Time", x = "Date", y = "OTP (%)") +
  scale_x_date(date_breaks = "1 year", labels = date_format("%Y")) + theme_minimal()

# GG Plot for total trips and total lates
ggplot(data, aes(x = DATE)) +
  geom_line(aes(y = TOTAL_TRIPS), color = "darkgreen") +
  geom_line(aes(y = TOTAL_LATES), color = "maroon") +
  labs(title = "Total Trips vs Total Lates Over Time", y = "Counts", x = "Date") +
  scale_x_date(date_breaks = "1 year", labels = date_format("%Y")) + theme_minimal()

# A monthly time series object for OTP
otp_ts <- ts(data$OTP, start = c(min(data$OTP_YEAR), min(data$OTP_MONTH)), frequency = 12)
otp_ts <- ts(data$OTP, start = c(2009, 1), frequency = 12)
summary(otp_ts)
plot(otp_ts, main = "Monthly Bus On-Time Performance", ylab = "OTP (%)", xlab = "Year")

# Check Stationarity

#ADF Test (Augmented Dickey-Fuller)
#H0: Series is non-stationary.(If p-value<0.05 -> Reject H0)
adf_result <- adf.test(otp_ts)
print(adf_result)

# In ADF test our OTP Time series is non-stationary.
# First-order differencing
otp_diff1 <- diff(otp_ts, differences = 1)
plot(otp_diff1, main = "Differenced OTP Series (1st Order)",
     ylab = "Differenced OTP", xlab = "Year")

# Check stationarity tests 
#H0: Series is non-stationary.(If p-value<0.05 -> Reject H0)
adf.test(otp_diff1)

# In ADF test our OTP Time series is now stationary after differencing.

# ACF and PACF plots of differenced OTP series
# AR (p): At PACF – cut-off at lag p, gradual decay in ACF.
# MA (q): At ACF – cut-off at lag q, gradual decay in PACF.
par(mfrow = c(1, 2))  # Side-by-side plots
acf(otp_diff1, main = "ACF of Differenced OTP")
pacf(otp_diff1, main = "PACF of Differenced OTP")

#MA(1) AND AR(2)
#ARIMA Models: ARIMA(2,1,1) , ARIMA(1,1,1), ARIMA(2,1,0)
model_211 <- Arima(otp_ts, order = c(2,1,1))
model_111 <- Arima(otp_ts, order = c(1,1,1))
model_210 <- Arima(otp_ts, order = c(2,1,0))

# Compare models using AIC and BIC
model_comparison <- data.frame(
  Model = c("ARIMA(2,1,1)", "ARIMA(1,1,1)", "ARIMA(2,1,0)"),
  AIC = c(AIC(model_211), AIC(model_111), AIC(model_210)),
  BIC = c(BIC(model_211), BIC(model_111), BIC(model_210))
)
print(model_comparison)

#Model ARIMA(1,1,1)

# Residual diagnostics
checkresiduals(model_111)
residuals_111 <- residuals(model_111)

# Histogram for Normality
hist(residuals_111, main = "Histogram of Residuals", xlab = "Residuals", 
     col = "skyblue", breaks = 20)

# QQ plot for Normality
qqnorm(residuals_111)
qqline(residuals_111, col = "red")

# Ljung-Box Test for White noise
Box.test(residuals_111, lag = 20, type = "Ljung-Box")

# Few Seasonal lags at 12, 24. and p-value is < 0.05 which indicates no significant autocorrelation due to seasonal effects.

# Spikes repeat at lags 12, 24, 36; indicating SARIMA may be needed.

# Fit SARIMA with seasonal differencing
sarima_model <- Arima(otp_ts, order = c(1,1,1), 
                      seasonal = list(order = c(0,1,1), period = 12))
summary(sarima_model)
checkresiduals(sarima_model)

# Ljung-Box test for SARIMA
Box.test(residuals(sarima_model), lag = 20, type = "Ljung-Box")

# Forecast for next 12 months
otp_forecast <- forecast::forecast(sarima_model, h = 12)
autoplot(otp_forecast) +
  ggtitle("Forecast of Bus On-Time Performance for Next 12 Months") +
  ylab("OTP (%)") +
  xlab("Year")
