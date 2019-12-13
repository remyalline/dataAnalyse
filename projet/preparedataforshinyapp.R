library(shiny)
library(carData)
library(ggplot2)
library(dplyr)
library(plotly)
library(dplyr)
df <- read.csv("C:/Users/remya/Desktop/gitDataAnalyse/dataAnalyse/projet/full_trains.csv",
               header = TRUE,
               sep=",", check.names = TRUE)

dfflight <- read.csv("C:/Users/remya/Desktop/gitDataAnalyse/dataAnalyse/projet/flights.csv",header = TRUE, sep=",", check.names = TRUE)
dfflight[is.na(dfflight)] <- 0
dfflight$DURATION=(dfflight$ARRIVAL_TIME -dfflight$DEPARTURE_TIME)

planesbyairavg=agg = aggregate(dfflight,
                              by = list(dfflight$AIRLINE),
                              FUN = mean)
planesbyorisavg=agg = aggregate(dfflight,
                                 by = list(dfflight$ORIGIN_AIRPORT),
                                 FUN = mean)
planesbydestavg=agg = aggregate(dfflight,
                                 by = list(dfflight$DESTINATION_AIRPORT),
                                 FUN = mean)

dfflight$DELAYED <- 0
dfflight$DELAYED[dfflight$DEPARTURE_DELAY > 0] <- 1
dfflight$TOTAL <- 1
dfused=subset(dfflight,DEPARTURE_DELAY >0)


planesbyairsum= aggregate(subset(dfflight,select=c(DISTANCE,DELAYED,TOTAL)),
                               by = list(dfflight$AIRLINE),
                               FUN = sum)
planesbyorisum= aggregate(subset(dfflight,select=c(DISTANCE,DELAYED,TOTAL)),
                          by = list(dfflight$ORIGIN_AIRPORT),
                          FUN = sum)
planesbydestsum= aggregate(subset(dfflight,select=c(DISTANCE,DELAYED,TOTAL)),
                          by = list(dfflight$DESTINATION_AIRPORT),
                          FUN = sum)

dfairports <- read.csv("C:/Users/remya/Desktop/gitDataAnalyse/dataAnalyse/projet/airports.csv",header = TRUE, sep=",", check.names = TRUE)
dfairlines <- read.csv("C:/Users/remya/Desktop/gitDataAnalyse/dataAnalyse/projet/airlines.csv",header = TRUE, sep=",", check.names = TRUE)



dfflight2=subset(dfflight, select = c(ORIGIN_AIRPORT,DESTINATION_AIRPORT) )
dfflight2=unique(dfflight2)


dftraffic=merge(x = dfairports, y = dfflight2, by.x ="IATA_CODE",by.y="ORIGIN_AIRPORT", all.y = TRUE)
names(dftraffic)[names(dftraffic) == "LATITUDE"] <- "LATITUDE_ORIGIN"
names(dftraffic)[names(dftraffic) == "LONGITUDE"] <- "LONGITUDE_ORIGIN"
dftraffic = subset(dftraffic, select = -c(COUNTRY,STATE,CITY,AIRPORT) )
dftraffic=merge(x = dfairports, y = dftraffic, by.x ="IATA_CODE",by.y="DESTINATION_AIRPORT", all.y = TRUE)
names(dftraffic)[names(dftraffic) == "LATITUDE"] <- "LATITUDE_ARRIVAL"
names(dftraffic)[names(dftraffic) == "LONGITUDE"] <- "LONGITUDE_ARRIVAL"