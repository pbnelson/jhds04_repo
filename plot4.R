# Coursera - Johns Hopkinds Data Science #4, Exploratory Data Analysis
# Course Project - Plot #4
#
# 4. Across the United States, how have emissions from coal combustion-related
#    sources changed from 1999–2008?

# note: source “10100101” is known as “Ext Comb /Electric Gen /Anthracite Coal /Pulverized Coal”.


# libraries
library(plyr)
library(ggplot2)

# set working directory
setwd("/Users/peter.nelson/Documents/Coursera/jhds-04-exdata/week3/jhds04_repo/")

# load data into memory
NEI <- readRDS("./data/summarySCC_PM25.rds")
SCC <- readRDS("./data/Source_Classification_Code.rds")


# get SCC subset for 'coal related sources', which I define as basically any SCC code
# where a name contains the word "coal". Note that this includes some codes for
# the 'charcoal' industry, but I decided to leave those in. Specifically, the
# SCC codes for charcoal are: 2810025000 30100601 30100603 30100604 30100605 30100606 30100607 30100608 30100699
SCC_coal_index <- with(SCC, which(grepl("COAL", toupper(paste(Short.Name, EI.Sector, Option.Group, SCC.Level.One, SCC.Level.Two, SCC.Level.Three, SCC.Level.Four)))))
SCC_coal <- SCC[SCC_coal_index, ]   # creates 251x15 dataframe


# make an NEI subset of only coal related sources, by 'inner joining' to SCC_coal
NEI_coal <- join(x=NEI, y=SCC_coal, by="SCC", type="inner")  # creates 53435x20 dataframe
#View(NEI_coal) #


# get total coal PM25 emissions by year
YearlyCoalEmissions <- ddply(NEI_coal, .(year), summarise, TotalCoalEmissions=sum(Emissions))  # note summarise, not summarize
YearlyCoalEmissions$year <- as.factor(YearlyCoalEmissions$year) # factorize the year


# plot using the base plotting system
barplot(YearlyCoalEmissions$TotalCoalEmissions,
        names=YearlyCoalEmissions$year,
        xlab = "Year",
        ylab = "Total Coal Emissions",
        main = "Total Coal PM25 Emissions by Year")


# save plot to png file
dev.copy(png, file = "plot4.png", width = 480, height = 480, bg="white")
dev.off()
system('open plot4.png')
