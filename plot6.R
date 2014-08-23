# Coursera - Johns Hopkinds Data Science #4, Exploratory Data Analysis
# Course Project - Plot #6
#
# 6. Compare emissions from motor vehicle sources in Baltimore City with
#    emissions from motor vehicle sources in Los Angeles County, California
#    (fips == "06037"). Which city has seen greater changes over time in
#    motor vehicle emissions?

# note Baltimore City fips code is 24510, LA County fips code is 06037

# note: codebook for SCC data is here:
#   http://www.epa.gov/ttn/chief/net/2011nei/2011_nei_tsdv1_draft2_june2014.pdf


# libraries
library(plyr)
library(ggplot2)
library(scales)    # Need the scales package for: scale_y_continuous(labels=percent)
library(wq)        # needed for layOut

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

# Next, get just BaltimoreCity & LACounty On-Road and Non-Road data from NEI
NEI_BCLA_OnNonRoad_index <- with(NEI, which( (fips == "24510"   | fips == "06037"   ) &  # baltimore city, or la county
                                             (type == 'ON-ROAD' | type == "OFF-ROAD")))
NEI_BCLA_OnNonRoad <- NEI[NEI_BCLA_OnNonRoad_index, ]

# finally, join the two datasets for one handy dataframe having just
# the right SCC codes and pm25 sources for motor vehicles. note the
# 'inner' join eliminates rows from X not present in Y.
NEISCC_BCLAMV <- join(x=NEI_BCLA_OnNonRoad, y=SCC_vehicle, by="SCC", type="inner")

# get total PM25 emissions by year and fips (location)
YearlyBCLAMVEmissions <- ddply(NEISCC_BCLAMV, .(year, fips), summarise, TotalMVEmissions=sum(Emissions))

# add column for mean emissions by fips location (all years)
# example: spraySums <- ddply(InsectSprays, .(spray), summarise, sum=ave(count, FUN=sum))
YearlyBCLAMVEmissions <- ddply(YearlyBCLAMVEmissions, .(fips), mutate, TotalMVEmissionsMeanByYear=ave(TotalMVEmissions, FUN=mean))

# add column for difference from mean
YearlyBCLAMVEmissions$DiffFromMean <- with(YearlyBCLAMVEmissions, TotalMVEmissions - TotalMVEmissionsMeanByYear)

# add column for diff from mean, as percent of mean
YearlyBCLAMVEmissions$DiffFromMeanPct <- with(YearlyBCLAMVEmissions, DiffFromMean/TotalMVEmissionsMeanByYear)
YearlyBCLAMVEmissions


####################################
# plot using ggplot (qplot variety)

# clean up the data for charting (make nice factors)...
YearlyBCLAMVEmissions$year     <- factor(YearlyBCLAMVEmissions$year) # factorize the year, makes plot nice
YearlyBCLAMVEmissions$Location <- factor(YearlyBCLAMVEmissions$fips,
                                         levels=c("24510", "06037"),
                                         labels=c("Baltimore City", "LA County"))


# Question: Which city has seen greater changes over time in motor vehicle emissions?
#
# The question is vague, does "greater change" mean greater in absolute terms, or
# relative tersm. Analogously, does a senior growing from age 70 to age 80 experience
# the same 'change' as a youth growing from age 15 to age 25?
#
# To answer the question, we need two different kinds of chart...
#

# Plot #1, absolute values. From this perspective, LA County clearly exhibits greater change.
p1 <- ggplot(data=YearlyBCLAMVEmissions, aes(x=year, y=TotalMVEmissions, colour=Location)) +
       xlab("Year") +
       ylab("PM25 Emissions") +
       labs(title="Baltimore City vs. LA County\nMotor Vehicle PM25 Emissions by Year\nAbsolute Value\n(with pct. deviation from location mean by lineweight)") +
       labs(size="%Dev. from Loc. Mean") +
       geom_path(aes(group=Location, size=abs(DiffFromMeanPct)))

# Plot #2, relative values. From this perspective more change is made by Baltimore City
# p02 <- plot_with_common_adornments(  ggplot(data=consumer_continents_data_ordered_customercount, aes(x=consumer_type, y=customer_count   , fill=consumer_type)) + facet_grid(~continent)     + labs(title = "Consumer Counts by Continent\n"            ) + scale_x_discrete(limits=consumtype_list_ordered_descending_customer_count)  )
p2 <- ggplot(data=YearlyBCLAMVEmissions, aes(x=year, y=DiffFromMeanPct, fill=Location)) +
        facet_wrap(~Location) +
        ylab("PM25 Emissions Percentage Deviation from Location Mean") +
        labs(title="Baltimore City vs. LA County\nMotor Vehicle PM25 Emissions by Year\nPct. Deviation from Location Mean") +
        scale_y_continuous(labels=percent) +
        theme(legend.position="none") +
        geom_bar(stat="identity", position="dodge") # dodge forces side-by-side clustered columns, eliminating 'Stacking not well defined when ymin != 0' warnings

# plot both on the save device, with p1 half-again bigger than p2
layOut(list(p1, 1, 1:3),
       list(p2, 1, 4:5))

# save both plots to png file
dev.copy(png, file = "plot6.png", width = 960, height = 480, bg="white")
dev.off()
system('open plot6.png')
