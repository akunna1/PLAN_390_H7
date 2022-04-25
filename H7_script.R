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

# Retrieve ACS data on the income levels of the households in Sacramento county tract in California
household_income = get_acs(
  geography="tract",  # could be tract, block group, etc.
  variables=c(
    "total_income"="B19001_001",
    "lessthan_10k"="B19001_002",
    "i10k_to_14.9k"="B19001_003",
    "i15k_to_19.9k"="B19001_004",
    "i20k_to_24.9k"="B19001_005",
    "i25k_to_29.9k"="B19001_006",
    "i30k_to_34.9k"="B19001_007",
    "i35k_to_39.9k"="B19001_008",
    "i40k_to_44.9k"="B19001_009",
    "i45k_to_49.9k"="B19001_010",
    "i50k_to_59.9k"="B19001_011",
    "i60k_to_74.9k"="B19001_012",
    "i75k_to_99.9k"="B19001_013",
    "i100k_to_124.9k"="B19001_014",
    "i125k_to_149.9k"="B19001_015",
    "i150k_to_199.9k"="B19001_016",
    "i200k_or_more"="B19001_017"
  ),
  year=2019,
  state="CA",
  survey="acs5",
  output="wide"
)

View(household_income)

# To do any spatial analysis, I have to join the household_income data to spatial information
# Spatial information was obtained from: https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html

# Download 2010 Sacramento county tract shapefile from the site, and load it into R.
sacramento_county = read_sf("tl_2010_06067_tract10.shp")

# renaming column GEOID column in household_income dataset to GEOID10
household_income$GEOID10 <- household_income$GEOID
household_income

# Join the datasets together
sacramento_county = left_join(sacramento_county, household_income, by="GEOID10")
sacramento_county

#Calculating the percentage of all households that make <$35,000/year in each tract
sacramento_county$percent_under_35k = ((sacramento_county$lessthan_10kE + sacramento_county$i10k_to_14.9kE + sacramento_county$i15k_to_19.9kE + sacramento_county$i20k_to_24.9kE + sacramento_county$i25k_to_29.9kE + sacramento_county$i30k_to_34.9kE)/ sacramento_county$total_incomeE)*100
sacramento_county$percent_under_35k

# project the data to California State Plane
sacramento_county = st_transform(sacramento_county,26943)

# And map income poverty percent
ggplot() +
  geom_sf(data=sacramento_county, aes(fill=percent_under_35k)) +
  scale_fill_viridis_c(option = "C")

view(sacramento_county)

# Importing zonal stats table created in ArcGIS Pro
zonal_stats = read_csv("ZS.csv")

# Join the datasets together (zonal_stats + sacramento_county) 
sacramento_county_ZS = right_join(sacramento_county, zonal_stats, by="GEOID10")

data.table(sacramento_county_ZS)
view(sacramento_county_ZS)

write_csv(sacramento_county_ZS, "sacramento_county_ZS.csv") # made scatter plot in excel

# *******************
# Extra Credit
# Retrieve ACS data on the amount of rent asked for households in Sacramento county tract in California
rent_asked = get_acs(
  geography="tract",  # could be tract, block group, etc.
  variables=c(
    "total_rent"="B25061_001",
    "lessthan_100"="B25061_002",
    "r100_to_149"="B25061_003",
    "r150_to_199"="B25061_004",
    "r200_to_249"="B25061_005",
    "r250_to_299"="B25061_006",
    "r300_to_349"="B25061_007",
    "r350_to_399"="B25061_008",
    "r400_to_449"="B25061_009",
    "r450_to_499"="B25061_010",
    "r500_to_549"="B25061_011",
    "r550_to_599"="B25061_012",
    "r600_to_649"="B25061_013",
    "r650_to_699"="B25061_014",
    "r700_to_749"="B25061_015",
    "r750_to_799"="B25061_016",
    "r800_to_899"="B25061_017",
    "r900_to_999"="B25061_018"
  ),
  year=2019,
  state="CA",
  survey="acs5",
  output="wide"
)

View(rent_asked)

# renaming column GEOID column in rent_asked dataset to GEOID10
rent_asked$GEOID10 <- rent_asked$GEOID
view(rent_asked)

# Use Sacramento county tract shapefile again
sacramento_county_2 = read_sf("tl_2010_06067_tract10.shp")

# Join rent_asked + sacramento_county_2
sacramento_county_2 = left_join(sacramento_county_2, rent_asked, by="GEOID10")
sacramento_county_2

#Calculating the percentage of all households that pay <$1,000 for rent in each tract
sacramento_county_2$percent_under_1k = ((sacramento_county_2$lessthan_100E + sacramento_county_2$r100_to_149E + sacramento_county_2$r150_to_199E + sacramento_county_2$r200_to_249E + sacramento_county_2$r250_to_299E + sacramento_county_2$r300_to_349E + sacramento_county_2$r350_to_399E + sacramento_county_2$r400_to_449E + sacramento_county_2$r450_to_499E + sacramento_county_2$r500_to_549E + sacramento_county_2$r550_to_599E + sacramento_county_2$r600_to_649E + sacramento_county_2$r650_to_699E + sacramento_county_2$r700_to_749E + sacramento_county_2$r750_to_799E + sacramento_county_2$r800_to_899E + sacramento_county_2$r900_to_999E)/ sacramento_county_2$total_rentE)*100
sacramento_county_2$percent_under_1k

# project the data to California State Plane
sacramento_county_2 = st_transform(sacramento_county_2,26943)

# And map rent_asked percent
ggplot() +
  geom_sf(data=sacramento_county_2, aes(fill=percent_under_1k)) +
  scale_fill_viridis_c(option = "G")

view(sacramento_county_2)

# Join the datasets together (zonal_stats + sacramento_county_2) 
sacramento_county_2_ZS = right_join(sacramento_county_2, zonal_stats, by="GEOID10")

data.table(sacramento_county_2_ZS)
view(sacramento_county_2_ZS)

write_csv(sacramento_county_2_ZS, "sacramento_county_2_ZS.csv") # made scatter plot in excel
