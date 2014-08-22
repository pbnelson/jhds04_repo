# Coursera - Johns Hopkinds Data Science #4, Exploratory Data Analysis
# Course Project - Plot #1
#
# 1. Have total emissions from PM2.5 decreased in the United States from 1999 to 2008?
#    Using the base plotting system, make a plot showing the total PM2.5 emission from
#    all sources for each of the years 1999, 2002, 2005, and 2008.

# note baltimore city fips code is 24510

# libraries
library(plyr)
library(ggplot2)

# set working directory
setwd("/Users/peter.nelson/Documents/Coursera/jhds-04-exdata/week3/jhds04_repo/")

# load data into memory
NEI <- readRDS("./data/summarySCC_PM25.rds")
SCC <- readRDS("./data/Source_Classification_Code.rds")


# some exploratory exploration...
dim(NEI) # 6,497,651 x 6
str(head(NEI, 1000))

dim(SCC) # 11,717 x 15
str(SCC)

NEI_fips_uniques <- unique(NEI$fips)  # 3,263 unique values - each one a county
NEI_SCC_uniques <- unique(NEI$SCC) #  5,386 unique values, a subset.
NEI_Pollutant_uniques <- unique(NEI$Pollutant) # only value is PM25-PRI
NEI_Emissions_uniques <- unique(NEI$Emissions) # 2,648,767 values - a continuous, not categorical variable
NEI_type_uniques <- unique(NEI$type) # 4 values: POINT, NONPOINT, ON-ROAD, NON-ROAD
NEI_year_uniques <- unique(NEI$year) # 4 values: 1999, 2002, 2005, 2008

SCC_types_source <- unique(SCC$SCC) # 11,717 unique values, not surprisingly. a unique key.


# get total PM25 emissions by year
YearlyEmissions <- ddply(NEI, .(year), summarise, TotalNationalEmissions=sum(Emissions))  # note summarise, not summarize
YearlyEmissions$year <- as.factor(YearlyEmissions$year) # make this a factor


# plot using the base plotting system
barplot(YearlyEmissions$TotalNationalEmissions,
        names=YearlyEmissions$year,
        xlab = "Year",
        ylab = "Total National Emissions",
        main = "Total National Emissions by Year")
