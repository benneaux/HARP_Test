###Setup=====

#     install_packages <- c("magrittr", "dplyr", "maptools", "maps","leaflet", "ggmap")
     required_packages <- list("magrittr", "dplyr", "maptools", "maps","leaflet", "ggmap")
#   
#   install.packages(install_packages)
# 

load_packages <- function(x){
  lapply(x, FUN = function(x) {
    do.call("library", 
            list(x)
            )
    })
}

load_packages(required_packages)

###Import the data=====

    # Run this first to copy all the data.
    
      # toilet_df_import <- read.csv("http://data.gov.au/dataset/553b3049-2b8b-46a2-95e6-640d7986a8c1/resource/bb22debd-95a6-4984-882c-12b58c92e16c/download/Latest-CSV-Export.csv")

    # If you want, you can run these to save a copy to your local wd.
    
    # This code is my initial attempt, before grouping the toilets together by suburb.
#        write.csv(toilet_df_import, 
#                  file = "toilet_data.csv"
#                  )
#        toilet_df <- read.csv('toilet_data.csv')
     
     # This is my next attempt, where I pipe the suburb into another function that returns an approximate lat/lng for that suburb.
    
      # First, create the data frame.
    
        write.csv(toilet_df_import,
                   file = "toilet_suburb_data.csv"
                   )
         toilet_suburb_df <- read.csv('toilet_suburb_data.csv')
         
      # Next, the function for returning lat/lng for each suburb.
        
         map_suburb_to_latlng <- toilet_suburb_df %>%
           suburb <- toilet_suburb_df$Town %>%
           mutate(suburb_lat <- geocode(paste(suburb, ", Australia"))$lat) %>%
           mutatate(suburb_lon <- geocode(paste(suburb, ", Australia"))$lon)
         
          
         
    # Create the labels
    
     toilet_df$hover <- paste(toilet_df$Name, ", ", toilet_df$Town)


  ## You can filter the data using an expression like the one below.
  ## This example returns toilets in New South Wales in areas with a Postcode in
  ## the range of 2260 to 2300. (and yes I know that the post code alone would do
  ## the same thing.

    toilet_df <- toilet_df[toilet_df$State == "New South Wales" & toilet_df$Postcode %in% 2280:2300,]

###Make the map====
    
  map <- leaflet(toilet_df) %>% # Call leaflet() using our data
    addTiles() %>%  # Add default OpenStreetMap map tiles
    addMarkers(popup=as.character(toilet_df$hover),
               clusterOptions = markerClusterOptions()) # Tell it where to get the labels.
    
    
    map    
    
    
     ## I'm behind a proxy, so I needed to save the map as a html and then
  ## open it in my browser. You might not have to.
    
    
    htmlwidgets::saveWidget(map, file='map.html')

### Done
