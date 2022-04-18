#Forecasting using Prophet in R
#CaseyBially
#Loading the Packages
install.packages('prophet')
library(prophet)
library(tidyverse)
#Loading the Dataset
bitcoin <- read.csv(file.choose())
head(bitcoin)
#Calling the Prophet Function to Fit the Model
Model1 <- prophet(bitcoin)
Future1 <- make_future_dataframe(Model1, periods = 365)
tail(Future1)
Forecast1 <- predict(Model1, Future1)
tail(Forecast1[c('ds','yhat','yhat_lower','yhat_upper')])
#Plotting the Model Estimates
dyplot.prophet(Model1, Forecast1)
prophet_plot_components(Model1, Forecast1)