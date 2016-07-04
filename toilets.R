###Setup===========================================================================================
  
  ## Install Packages
    # install_packages <- c("magrittr", "dplyr", "maptools", "maps","leaflet", "ggmap")
    # install.packages(install_packages)
     
  ## Load Package
    
    required_packages <- list("magrittr", "dplyr", "maptools", "maps","leaflet", "ggmap")
    
    load_packages <- function(x) {
      lapply(x, FUN = function(x) {
        do.call("require", 
                list(x)
                )
      })
    }
    
    load_packages(required_packages)

###Import the data (Basic Data)====================================================================

# This code is my initial attempt, before grouping the toilets together by suburb.

  ## Run this first to copy all the data from data.gov.au
    
      data_url <-  "http://data.gov.au/dataset/553b3049-2b8b-46a2-95e6-640d7986a8c1/resource/bb22debd-95a6-4984-882c-12b58c92e16c/download/Latest-CSV-Export.csv"
      toilet_df_import <- read.csv(data_url)

  ## If you want, you can run these to save a copy to your local wd.
    

      wd <- getwd()  
      
      write.csv(toilet_df_import, 
                  file = paste(wd,"/Data/toilet_data.csv", sep = "")
                  )
      
      toilet_df <- read.csv(paste(wd,"/Data/toilet_data.csv", sep = ""))

    # Choose how you want to fileter the data. If you're running it for Melbourne only
    # you can filter additionally by postcodes, if you know what they are.
      
      State <- "Victoria"
      
      toilet_df <- as.data.frame(
        toilet_df[toilet_df$State == as.character(State)
                  #&toilet_df$Postcode %in% 2280:2300 
                  , ])
### INCOMPLETE!!!: Import the Data (Group by Suburb)==============================================================
#       
# # This is my next attempt, where I pipe the suburb into another function that returns an approximate lat/lng for that suburb.
#     
#   ## First, create the data frame.
#         
#         write.csv(toilet_df_import,
#                    file = "toilet_suburb_data.csv"
#                    )
#          toilet_suburb_df <- read.csv('toilet_suburb_data.csv')
#          
#       # Choose how you want to fileter the data. If you're running it for Melbourne
#       # I suggest that you remove the postoce part.
#          
#          State <- "New South Wales"
#          
#          toilet_suburb_df <- as.data.frame(
#            toilet_suburb_df[toilet_suburb_df$State == State &
#                             toilet_suburb_df$Postcode %in% 2280:2300,
#              ])
#   
#   ## Next, the function for returning lat/lng for each suburb.
#         
#            toilet_suburb_df %>%
#              
#              group_by(.$Postcode)
#            
#            suburb = toilet_suburb_df$Town %>%
#            mutate(toilet_suburb_df, 
#                   suburb_lat = as.data.frame(
#                     geocode(
#                       paste(toilet_suburb_df$Town,
#                             ", Australia")
#                       )$lat
#                     )
#                   ) %>%
#             mutatate(suburb_lon = geocode(
#               paste(suburb,
#                     ", Australia")
#               )$lon
#               )
#  
### Create the labels==============================================================================

  ## Regardless of which method you choose, run this to create the labels that will appear when you click on a marker.    
     
      toilet_df$hover <- paste(toilet_df$Name, ", ", toilet_df$Town)

###Make the map====================================================================================
  centre_map_on <- geocode("Melbourne, Australia")
           
  map <- leaflet(toilet_df) %>% # Call leaflet() using our data
    
    addTiles() %>%  # Add default OpenStreetMap map tiles
    
    setView(centre_map_on$lon, centre_map_on$lat, zoom = 12) %>%
    
    addMarkers(popup=as.character(toilet_df$hover), # Tell it where to get the labels.
               clusterOptions = markerClusterOptions() # clusterOptions tells the map to group markers.
               )
    
    map # Call the map.    
    
## I'm behind a proxy, so I needed to save the map as a html and then open it in my browser. You might not have to.
    
    htmlwidgets::saveWidget(map, file='map.html')

### Done
