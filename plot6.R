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
library(sqldf)     # needed for sqldf

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
# note that summarise replaces the sum() column with the new column
YearlyBCLAMVEmissions <- ddply(NEISCC_BCLAMV, .(year, fips), summarise, TotalMVEmissions=sum(Emissions))

# add column for mean emissions by fips location (all years)
# example: spraySums <- ddply(InsectSprays, .(spray), summarise, sum=ave(count, FUN=sum))
# note that mutate adds a new column to the dataframe, as opposed to summarise which replaces a column.
YearlyBCLAMVEmissions <- ddply(YearlyBCLAMVEmissions, .(fips), mutate, TotalMVEmissionsMeanByFips=ave(TotalMVEmissions, FUN=mean))

# add column for difference from mean
YearlyBCLAMVEmissions$DiffFromMean <- with(YearlyBCLAMVEmissions, TotalMVEmissions - TotalMVEmissionsMeanByFips)

# add column for diff from mean, as percent of mean
YearlyBCLAMVEmissions$DiffFromMeanPct <- with(YearlyBCLAMVEmissions, DiffFromMean/TotalMVEmissionsMeanByFips)

# Similarly, add a column for initial value (i.e. value in 1999) for each location.
# There's probably a better 'R' way to do this, but I'm not sure and I'm in a bit of a hurry.
# My way in 'R' not using SQL would have been some pretty ugly ddply/which/join operations,
# which would not be any easier to read.
InitialTotalMvEmissions <- sqldf("select fips, TotalMVEmissions as InitialTotalMVEmissionsByFips
                                 from YearlyBCLAMVEmissions as e1
                                 where year = ( select min(year)
                                                from YearlyBCLAMVEmissions as e2
                                                where e1.fips = e2.fips
                                               )
                                 ")

# add the initial value to the YearlyBCLAMVEmissions dataset
YearlyBCLAMVEmissions <- join(x=YearlyBCLAMVEmissions, y=InitialTotalMvEmissions, by="fips", type="right")

# add a column for difference from initial value
YearlyBCLAMVEmissions$DiffFromInitial <- with(YearlyBCLAMVEmissions, TotalMVEmissions - InitialTotalMVEmissionsByFips)

# add a column for percent change from initial value
YearlyBCLAMVEmissions$DiffFromInitialPct <- with(YearlyBCLAMVEmissions, DiffFromInitial/InitialTotalMVEmissionsByFips)

# add a column for percentage of initial value. note that this is different than percent
# change from initial value. The former is measuring the difference divided by the initial value,
# and therefore 0 represents no change, with a scale of -1.0 to infinity to +infinity. the latter is measuring each
# subsequent value as a percentage of the initial value, with 1.0 representing no change, and a scale
# of 0 to +infinity.

# add a column for percentage of initial value.
YearlyBCLAMVEmissions$PctInitialValue <- with(YearlyBCLAMVEmissions, TotalMVEmissions / InitialTotalMVEmissionsByFips)

####################################
# plot using ggplot (qplot variety)


# Question: Which city has seen greater changes over time in motor vehicle emissions?
#
# The question is vague, does "greater change" mean greater in absolute terms, or
# relative tersm. Analogously, does a senior growing from age 70 to age 80 experience
# 'greater change' than a youth growing from age 10 to age 18? Well, it depends...
#
# To answer the question, we need two different kinds of chart...
#

# clean up the data for charting (make nice factors)...
YearlyBCLAMVEmissions$year     <- factor(YearlyBCLAMVEmissions$year) # factorize the year, makes plot nice
YearlyBCLAMVEmissions$Location <- factor(YearlyBCLAMVEmissions$fips,
                                         levels=c("24510", "06037"),
                                         labels=c("Baltimore City", "LA County"))

# Plot #1, absolute values. From this perspective, LA County clearly exhibits greater change.
# Note that I have added an indication of percentage deviation from starting value, by the dot thickness.
p1 <- ggplot(data=YearlyBCLAMVEmissions, aes(x=year, y=TotalMVEmissions, colour=Location)) +
       xlab("Year") +
       ylab("PM25 Emissions") +
       labs(title="Baltimore City vs. LA County\nMotor Vehicle PM25 Emissions by Year\nAbsolute Value\n(with %initial value by point size)") +
       labs(size="% of Initial Value") +
       geom_point(aes(group=Location, size=PctInitialValue), show_guide=TRUE )  +
       geom_path (aes(group=Location), show_guide=FALSE, alpha=0.25, size=5)

# Plot #2, relative values. From this perspective more change is made by Baltimore City
p2 <- ggplot(data=YearlyBCLAMVEmissions, aes(x=year, y=PctInitialValue, fill=Location)) +
        facet_wrap(~Location) +
        xlab("Year") +
        ylab("PM25 Emissions Percentage of Initial Value") +
        labs(title="Baltimore City vs. LA County\nMotor Vehicle PM25 Emissions by Year\nPercent Relative to Initial Value") +
        scale_y_continuous(labels=percent, limits=c(0, 1.25), breaks=seq(0,1.25,0.25)) +
        theme(legend.position="none") +
        geom_bar(stat="identity", position="dodge", alpha=0.60) # dodge forces side-by-side clustered columns, eliminating 'Stacking not well defined when ymin != 0' warnings

# plot both together, with p1 half-again bigger than p2
layOut(list(p1, 1, 1:3),
       list(p2, 1, 4:5))

# save both plots to png file
dev.copy(png, file = "plot6.png", width = 960, height = 480, bg="white")
dev.off()
system('open plot6.png')
