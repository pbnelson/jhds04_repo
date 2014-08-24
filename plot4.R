# Coursera - Johns Hopkinds Data Science #4, Exploratory Data Analysis
# Course Project - Plot #4
#
# 4. Across the United States, how have emissions from coal combustion-related
#    sources changed from 1999–2008?

# note: source “10100101” is known as “Ext Comb /Electric Gen /Anthracite Coal /Pulverized Coal”.

# note: codebook for SCC data is here:
#   http://www.epa.gov/ttn/chief/net/2011nei/2011_nei_tsdv1_draft2_june2014.pdf

# libraries
library(plyr)
library(ggplot2)

# set working directory
setwd("/Users/peter.nelson/Documents/Coursera/jhds-04-exdata/week3/jhds04_repo/")

# load data into memory
NEI <- readRDS("./data/summarySCC_PM25.rds")
SCC <- readRDS("./data/Source_Classification_Code.rds")

# add a handy column to SCC having all names contactenated into a single string, all UPPERCASE
SCC$allnames <- with(SCC, toupper(paste(Short.Name,
                                        EI.Sector,
                                        Option.Group,
                                        SCC.Level.One,
                                        SCC.Level.Two,
                                        SCC.Level.Three,
                                        SCC.Level.Four )))

# get SCC subset for 'coal combustion-related sources', which I define as any SCC code having
# any name containing the word "COAL", and any name containing the word "COMB" (the abbreviation
# for "combustion"), and no name containing the word "CHARCOAL", which reduced the list by 1.
# Note that I force all matches to uppercase to cope with different up/lowcase spelling.

SCC_coalcomb_index <- which(  grepl("COAL"    , SCC$allnames) &
                              grepl("COMB"    , SCC$allnames) &
                             !grepl("CHARCOAL", SCC$allnames)      # this exclusion makes for 103 instead of 104 rows
                           )

SCC_coalcomb <- SCC[SCC_coalcomb_index, ]   # creates 103x16 dataframe

# make an NEI subset of only coal related sources, by 'inner joining' to SCC_coal
NEI_coalcomb <- join(x=NEI, y=SCC_coalcomb, by="SCC", type="inner")  # creates 53435x20 dataframe

# get total coal combustion PM25 emissions by year
YearlyCoalCombEmissions <- ddply(NEI_coalcomb, .(year), summarise, TotalCoalCombEmissions=sum(Emissions))
YearlyCoalCombEmissions$year <- as.factor(YearlyCoalCombEmissions$year) # factorize the year

# plot using the base plotting system
barplot(YearlyCoalCombEmissions$TotalCoalCombEmissions,
        names=YearlyCoalCombEmissions$year,
        xlab = "Year",
        ylab = "PM25 Emissions",
        main = "Coal Combustion\nPM25 Emissions by Year")

# save plot to png file
dev.copy(png, file = "plot4.png", width = 480, height = 480, bg="white")
dev.off()
system('open plot4.png')
