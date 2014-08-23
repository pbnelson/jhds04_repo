# Coursera - Johns Hopkinds Data Science #4, Exploratory Data Analysis
# Course Project - Plot #3
#
# 3. Of the four types of sources indicated by the type (point, nonpoint,
#    onroad, nonroad) variable, which of these four sources have seen decreases
#    in emissions from 1999–2008 for Baltimore City? Which have seen increases
#    in emissions from 1999–2008? Use the ggplot2 plotting system to make a
#    plot answer this question.

# note baltimore city fips code is 24510

# libraries
library(plyr)
library(ggplot2)

# set working directory
setwd("/Users/peter.nelson/Documents/Coursera/jhds-04-exdata/week3/jhds04_repo/")

# load data into memory
NEI <- readRDS("./data/summarySCC_PM25.rds")
SCC <- readRDS("./data/Source_Classification_Code.rds")

# get total PM25 emissions by year & fips & point_source
YearlyEmissionsByFipsAndType <- ddply(NEI, .(year, fips, type), summarise, TotalFipsTypeEmissions=sum(Emissions))  # note summarise, not summarize
YearlyEmissionsByFipsAndType$year <- as.factor(YearlyEmissionsByFipsAndType$year) # factorize the year

# get just Baltimore fips data...
YearlyEmissionsByBaltimoreCityAndType <- YearlyEmissionsByFipsAndType[which(YearlyEmissionsByFipsAndType$fips == "24510"), ]

# plot using ggplot!
ggplot(data=YearlyEmissionsByBaltimoreCityAndType, aes(x=year, y=TotalFipsTypeEmissions, colour=type)) +
    xlab("Year") +
    ylab("PM25 Emissions") +
    labs(title="Baltimore City\nPM25 Emissions by Year and Type") +
    labs(colour="Source Type") +
    geom_line(aes(group=type))

# save plot to png file
dev.copy(png, file = "plot3.png", width = 480, height = 480, bg="white")
dev.off()
system('open plot3.png')
