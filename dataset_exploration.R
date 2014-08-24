
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

