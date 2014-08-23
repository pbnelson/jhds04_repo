# Coursera - Johns Hopkinds Data Science #4, Exploratory Data Analysis
# Course Project - Plot #5
#
# 5. How have emissions from motor vehicle sources changed from 1999–2008
#    in Baltimore City?

# note baltimore city fips code is 24510

# note: codebook for SCC data is here:
#   http://www.epa.gov/ttn/chief/net/2011nei/2011_nei_tsdv1_draft2_june2014.pdf

# I have defined "Motor Vehicle" sources as any pollution source
# having a NEI$type of ON-ROAD or NON-ROAD, and an SCC code containing
# the term "VEHICLE" in any of its description columns.

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

# First get any SCC code having the term VEHICLE in any name
SCC_vehicle_index <- which( grepl("VEHICLE", SCC$allnames) )
SCC_vehicle <- SCC[SCC_vehicle_index, ]

# Next, get just BaltimoreCity On-Road and Non-Road data from NEI
NEI_BaltimoreCity_OnRoad_NonRoad_index <- with(NEI, which((fips == "24510") &
                                                          (type == 'ON-ROAD' | type == "OFF-ROAD")))
NEI_BaltimoreCity_OnRoad_NonRoad <- NEI[NEI_BaltimoreCity_OnRoad_NonRoad_index, ]

# finally, join the two datasets for one handy dataframe having just
# the right SCC codes and pm25 sources for motor vehicles. note the
# 'inner' join eliminates rows from X not present in Y.
NEISCC_baltcit_onnonroad <- join(x=NEI_BaltimoreCity_OnRoad_NonRoad, y=SCC_vehicle, by="SCC", type="inner")

# get total PM25 emissions by year
YearlyBCMVEmissions <- ddply(NEISCC_baltcit_onnonroad, .(year), summarise, TotalMVEmissions=sum(Emissions))

# plot using ggplot (qplot variety)
YearlyBCMVEmissions$year <- as.factor(YearlyBCMVEmissions$year) # factorize the year, makes plot nice
qplot(x=year,
      weight=TotalMVEmissions,
      data=YearlyBCMVEmissions,
      xlab="Year",
      ylab="PM25 Emissions",
      main="Baltimore Motor Vehicle\nPM25 Emissions by Year",
      geom="bar")

# save plot to png file
dev.copy(png, file = "plot5.png", width = 480, height = 480, bg="white")
dev.off()
system('open plot5.png')
