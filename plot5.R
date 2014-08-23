# Coursera - Johns Hopkinds Data Science #4, Exploratory Data Analysis
# Course Project - Plot #5
#
# 5. How have emissions from motor vehicle sources changed from 1999–2008
#    in Baltimore City?

# note baltimore city fips code is 24510

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
dev.copy(png, file = "plot5.png", width = 480, height = 480, bg="white")
dev.off()
system('open plot5.png')
