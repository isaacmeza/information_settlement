# Geocoding a csv column of "addresses" in R

#load ggmap
library(httr)
library(ggmap)
library(ggplot2)
library(tidyverse)
library(devtools)
library(osrm)
# PACKAGES
library(tidyverse) # data wrangling
library(stringr)   # work with strings
library(sf)        # geospatial
library(geosphere) # calculate distances
library(haven)     # read/write .dta (Stata)
library(here)      # use relative filepaths
library(osrm)      # calculate road distances
library(assertthat)


# old spatial packages since osrm works with those
library(sp) #spatial objects; used by rgdal

#ENV['AUTH_TOKEN']
key<-"ENV['AUTH_TOKEN']"
register_google(key = key)

setwd('C:/Users/xps-seira/Dropbox/Apps/ShareLaTeX/information_settlement/Paper/RScripts')

# Read in the CSV data and store it in a variable

origAddress <- read.csv('../DB/direcciones_p2.csv', stringsAsFactors = FALSE)

# Initialize the data frame

geocoded <- data.frame(stringsAsFactors = FALSE)

# Loop through the addresses to get the latitude and longitude of each address and add it to the

# origAddress data frame in new columns lat and lon

for(i in 1:nrow(origAddress)) {
  
  tryCatch({
  # Print("Working...")
  result <- geocode(origAddress$addresses[i], output = "latlona", source = "google")
  
  origAddress$lon[i] <- as.numeric(result[1])
  
  origAddress$lat[i] <- as.numeric(result[2])
  
  origAddress$geoAddress[i] <- as.character(result[3])
}, error=function(e){})
}

# Write a CSV file containing origAddress to the working directory

write.csv(origAddress, "../DB/geocoded_p2.csv", row.names=FALSE)




geocoded <- read.csv('../DB/geocoded_p2.csv', stringsAsFactors = FALSE) %>% 
  drop_na()

# Map to check points make sense
# getting the map
mapsue <- get_map(location = c(lon = mean(geocoded$lon), lat = mean(geocoded$lat)), zoom = 4,
                      maptype = "roadmap", scale = 2, source = "google")

# plotting the map with some points on it
ggmap(mapsue) +
  geom_point(data = geocoded, aes(x = lon, y = lat, fill = "red", alpha = 0.8), size = 1, shape = 21) +
  guides(fill=FALSE, alpha=FALSE, size=FALSE)



geocoded_sp <- st_as_sf(geocoded ,coords = c("lon","lat"),crs=4326, sf_column_name="geometry") %>%
  as('Spatial')


# Manually get it using address on Google Maps:
jlca <- st_sf(
    folio = "0000-0000" ,
    demandado = 0,
    addresses = "Av. Dr. Río de la Loza 68, Doctores, 06720 Ciudad de México, CDMX, Mexico",
    geoAddress= "Av. Dr. Río de la Loza 68, Doctores, 06720 Ciudad de México, CDMX, Mexico",
    geometry = st_sfc(st_point(c(-99.14541650000001, 19.4245109)))
  ) %>% 
  st_set_crs(4326) %>% # because the point was taken from Google Maps coordinates
  mutate(folio = as.character(folio),
         addresses = as.character(addresses),
         geoAddress = as.character(geoAddress)
         ) %>%
  as('Spatial')

# Use OSRM's server
options(osrm.server = "http://router.project-osrm.org/")

for(i in 1:nrow(geocoded)) {
  
  tryCatch({
  result <- osrmRoute(src = geocoded[i,c("folio","lon","lat")], dst = jlca, overview= FALSE)
  
  geocoded$duration[i] <- as.numeric(result[1])
  
  geocoded$distance[i] <- as.numeric(result[2])
  }, error=function(e){})
  }

write.csv(geocoded, "../DB/geocoded_distances_p2.csv", row.names=FALSE)


