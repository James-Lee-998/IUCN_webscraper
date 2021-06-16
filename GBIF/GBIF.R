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

List_of_Species = read.csv('D:/TEST.csv')

X = List_of_Species %>%
  set_names(c("Taxon", "Author")) %>%
  mutate(keys = map(Taxon, function(x) name_backbone(name = x)$speciesKey)) %>%
  mutate(rgbif_pull  = map(keys, occ_search, limit = 200)) %>%
  mutate(Latitude = map(rgbif_pull, pluck, 'data', 'decimalLatitude')) %>%
  mutate(Longitude = map(rgbif_pull, pluck, 'data', 'decimalLongitude')) %>%
  mutate(Year = map(rgbif_pull, pluck, 'data', 'year')) %>%
  mutate(Source = map(rgbif_pull, pluck, 'data', 'datasetName')) %>%
  select(Taxon, Latitude, Longitude, Year, Source) %>% # obtain latitude and longitude occurrence data
  filter(Longitude != 'NULL') %>%
  filter(Source != 'NULL') %>%
  filter(Year != 'NULL')

P = c()

for (i in 1:nrow(X)) {
  Y = cbind(X$Latitude[[i]],X$Longitude[[i]])
  Z = cbind(X$Year[[i]],X$Source[[i]])
  O = rep(X$Taxon[i], each = nrow(Y))
  Q = cbind(O,Y,Z)
  P = rbind(P,Q)
}

ALL_DATA = P %>%
  as_tibble %>%
  na.omit() %>%
  rename(., c(Species = O, Lat = V2, Lon = V3, Year = V4, Source = V5)) %>%
  mutate(Lat = as.double(Lat)) %>%
  mutate(Lon = as.double(Lon)) %>%
  mutate(Species = as.factor(Species)) 

world = ne_countries(scale = 'medium', returnclass = 'sf') %>%
  st_as_sf()

test_plot = ggplot() +
  geom_sf(data = world) +
  geom_point(data = ALL_DATA, 
             aes(x = Lon, y = Lat, fill = Species, color = Year, label = Source),
             size = 0.5) +
  theme(legend.position = 'none')
  

ggplotly(test_plot)
