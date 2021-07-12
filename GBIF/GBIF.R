library(rgbif)
library(openssl)
library(spocc)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(plotly)
library(ggspatial)
library(rnaturalearth)
library(tidygeocoder)
library(ggrepel)
library(sf)
library(rgeos)

List_of_Species = read.csv('D:/MexTMF_trees.csv') # Read in csv file with list of species

X = List_of_Species %>% # Pipeline which initates our ability to manipulate our list
  set_names(c("Taxon", "Author")) %>% # Reset the names of the list so we can call them
  mutate(keys = map(Taxon, function(x) name_backbone(name = x)$speciesKey)) %>% # Make a new column which gets all species ids from list
  mutate(rgbif_pull  = map(keys, occ_search, limit = 200)) %>% # Uses list of ids to return information on occurence data, limit set to 200 
  mutate(Latitude = map(rgbif_pull, pluck, 'data', 'decimalLatitude')) %>% # Plucks Latitude data
  mutate(Longitude = map(rgbif_pull, pluck, 'data', 'decimalLongitude')) %>% # Plucks Longitude data
  mutate(Year = map(rgbif_pull, pluck, 'data', 'year')) %>% # Plucks time data
  mutate(Source = map(rgbif_pull, pluck, 'data', 'datasetName')) %>% # Plucks Source
  select(Taxon, Latitude, Longitude, Year, Source) %>% # Obtain latitude and longitude occurrence data
  filter(Longitude != 'NULL') %>% # Removes NULLs
  filter(Source != 'NULL') %>%
  filter(Year != 'NULL')

##Extract non-GBIF species
y = c(List_of_Species$Taxon, X$Taxon) # Extracts all Species which are not found on the RGBIF database

n = as_tibble(y[ave(seq_along(y),y, FUN = length) == 1]) # Produces a dataframe of non RGBIF species

write.csv(n, file = "D:/GBIF_EXCLUDED.csv", row.names = FALSE) # Writes a csv file of all these non GBIF species

##Sort data into repeats of species names
P = c()

##For loop which converts dataframe into repeats
for (i in 1:nrow(X)) {
  Y = cbind(X$Latitude[[i]],X$Longitude[[i]])
  Z = cbind(X$Year[[i]],X$Source[[i]])
  O = rep(X$Taxon[i], each = nrow(Y))
  Q = cbind(O,Y,Z)
  P = rbind(P,Q)
}

##Tibble creation, sets all variables as particular factors
ALL_DATA = P %>%
  as_tibble() %>%
  na.omit() %>%
  rename(., c(Species = O, Lat = V2, Lon = V3, Year = V4, Source = V5)) %>%
  mutate(Lat = as.double(Lat)) %>% 
  mutate(Lon = as.double(Lon)) %>%
  mutate(Species = as.factor(Species)) 

##Produce a world map
world = ne_countries(scale = 'medium', returnclass = 'sf') %>%
  st_as_sf()

##Use world map as a template for production of a occurence data heatmap
test_plot = ggplot() +
  geom_sf(data = world) +
  geom_point(data = ALL_DATA, 
             aes(x = Lon, y = Lat, fill = Species, color = Year, label = Source),
             size = 0.5) +
  theme(legend.position = 'none')
  
##Create an interactive plot
ggplotly(test_plot)
