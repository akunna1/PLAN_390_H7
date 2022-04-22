# Homework 7: Raster Analysis

library(tidyverse)
library(tidycensus)
library(sf)
library(dplyr)
library(tidyr)
library(data.table)
library(ggplot2)

# Retrieving some information from the 2019 5-year ACS
acs_vars = load_variables(2019, "acs5")

# The data is huge, so I am saving it to a file and view it in Excel.
write_csv(acs_vars, "acsvars.csv")

# Retrieve ACS data on the income levels of the households in Sacramento county in California
household_income = get_acs(
  geography="county",  # could be tract, block group, etc.
  variables=c(
    "total_income"="B19001_001",
    "lessthan_10k"="B19001_002",
    "10k_to_14.9k"="B19001_003",
    "15k_to_19.9k"="B19001_004",
    "20k_to_24.9k"="B19001_005",
    "25k_to_29.9k"="B19001_006",
    "30k_to_34.9k"="B19001_007",
    "35k_to_39.9k"="B19001_008",
    "40k_to_44.9k"="B19001_009",
    "45k_to_49.9k"="B19001_010",
    "50k_to_59.9k"="B19001_011",
    "60k_to_74.9k"="B19001_012",
    "75k_to_99.9k"="B19001_013",
    "100k_to_124.9k"="B19001_014",
    "125k_to_149.9k"="B19001_015",
    "150k_to_199.9k"="B19001_016",
    "200k_or_more"="B19001_017"
  ),
  year=2019,
  state="CA",
  survey="acs5",
  output="wide"
)

View(household_income)

# To do any spatial analysis, I have to join the household_income data to spatial information
# Spatial information was obtained from: https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html

# Download 2010 US County shapefile from the site, and load it into R.
counties = read_sf("tl_2010_us_county10.shp")

# Filtering just CA counties using the state FIPS (STATEFP10) code to do that
ca_counties = filter(counties, STATEFP10=="06")

# renaming column GEOID column in household_income dataset to GEOID10
household_income$GEOID10 <- household_income$GEOID

# Join the datasets together
ca_counties = left_join(ca_counties, household_income, by="GEOID10")