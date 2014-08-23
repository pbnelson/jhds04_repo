# Coursera - Johns Hopkinds Data Science #4, Exploratory Data Analysis
# Course Project - Plot #6
#
# 6. Compare emissions from motor vehicle sources in Baltimore City with
#    emissions from motor vehicle sources in Los Angeles County, California
#    (fips == "06037"). Which city has seen greater changes over time in
#    motor vehicle emissions?

# note Baltimore City fips code is 24510, LA County fips code is 06037



# libraries
library(plyr)
library(ggplot2)

# set working directory
setwd("/Users/peter.nelson/Documents/Coursera/jhds-04-exdata/week3/jhds04_repo/")

# load data into memory
NEI <- readRDS("./data/summarySCC_PM25.rds")
SCC <- readRDS("./data/Source_Classification_Code.rds")




# get total PM25 emissions by year, fips and 'motor vehicle sources'



# save plot to png file
dev.copy(png, file = "plot6.png", width = 480, height = 480, bg="white")
dev.off()
system('open plot6.png')
