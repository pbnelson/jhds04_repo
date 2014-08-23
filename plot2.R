# Coursera - Johns Hopkinds Data Science #4, Exploratory Data Analysis
# Course Project - Plot #2
#
# 2. Have total emissions from PM2.5 decreased in the Baltimore City, Maryland
#    (fips == "24510") from 1999 to 2008? Use the base plotting system to make
#    a plot answering this question.

# note baltimore city fips code is 24510

# libraries
library(plyr)

# set working directory
setwd("/Users/peter.nelson/Documents/Coursera/jhds-04-exdata/week3/jhds04_repo/")

# load data into memory
NEI <- readRDS("./data/summarySCC_PM25.rds")
SCC <- readRDS("./data/Source_Classification_Code.rds")

# get total PM25 emissions by year & fips
YearlyEmissionsByFips <- ddply(NEI, .(year, fips), summarise, TotalFipsEmissions=sum(Emissions))  # note summarise, not summarize
YearlyEmissionsByFips$year <- as.factor(YearlyEmissionsByFips$year) # factorize the year

# get just Baltimore fips data...
YearlyEmissionsByBaltimoreCity <- YearlyEmissionsByFips[which(YearlyEmissionsByFips$fips == "24510"), ]

# plot using the base plotting system
barplot(YearlyEmissionsByBaltimoreCity$TotalFipsEmissions,
        names=YearlyEmissionsByBaltimoreCity$year,
        xlab = "Year",
        ylab = "PM25 Emissions",
        main = "Baltimore City\nPM25 Emissions by Year")

# save plot to png file
dev.copy(png, file = "plot2.png", width = 480, height = 480, bg="white")
dev.off()
system('open plot2.png')
