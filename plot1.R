# Coursera - Johns Hopkinds Data Science #4, Exploratory Data Analysis
# Course Project - Plot #1
#
# 1. Have total emissions from PM2.5 decreased in the United States from 1999 to 2008?
#    Using the base plotting system, make a plot showing the total PM2.5 emission from
#    all sources for each of the years 1999, 2002, 2005, and 2008.

# libraries
library(plyr)

# set working directory
setwd("/Users/peter.nelson/Documents/Coursera/jhds-04-exdata/week3/jhds04_repo/")

# load data into memory
NEI <- readRDS("./data/summarySCC_PM25.rds")
SCC <- readRDS("./data/Source_Classification_Code.rds")

# get total PM25 emissions by year
YearlyEmissions <- ddply(NEI, .(year), summarise, TotalNationalEmissions=sum(Emissions))  # note summarise, not summarize
YearlyEmissions$year <- as.factor(YearlyEmissions$year) # factorize the year

# plot using the base plotting system
barplot(YearlyEmissions$TotalNationalEmissions,
        names=YearlyEmissions$year,
        xlab = "Year",
        ylab = "Total National Emissions",
        main = "Total National PM25 Emissions by Year")

# save plot to png file
dev.copy(png, file = "plot1.png", width = 480, height = 480, bg="white")
dev.off()
system('open plot1.png')
