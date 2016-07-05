###Setup=====

#     install_packages <- c("magrittr", "dplyr", "maptools", "maps","leaflet")
     required_packages <- list("magrittr", "dplyr", "maptools", "maps","leaflet")
#   
#   install.packages(install_packages)
# 
    lapply(required_packages, FUN = function(required_packages) {
      do.call("library", list(required_packages)) 
    })

###Import the data=====

    # Run this first to copy all the data.
    
      # toilet_df_import <- read.csv("http://data.gov.au/dataset/553b3049-2b8b-46a2-95e6-640d7986a8c1/resource/bb22debd-95a6-4984-882c-12b58c92e16c/download/Latest-CSV-Export.csv")

    # If you want, you can run these to save a copy to your local wd.
    
     write.csv(toilet_df_import, file = "toilet_data.csv")
     toilet_df <- read.csv('toilet_data.csv')
    
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
=======
###Setup===========================================================================================
get_os <- function(){
  sysinf <- Sys.info()
  if (!is.null(sysinf)){
    os <- sysinf['sysname']
    if (os == 'Darwin')
      os <- "osx"
  } else { ## mystery machine
    os <- .Platform.type
    if (grepl("^darwin", R.version))
      os <- "osx"
    if (grepl("linux-gnu", R.version))
      os <- "linux"
  }
  tolower(os)
}

install_packages <- c("magrittr", "dplyr", "maptools", "maps","leaflet", "ggmap")
required_packages <- list("magrittr", "dplyr", "maptools", "maps","leaflet", "ggmap")
new_packages <- install_packages[!(install_packages %in% installed.packages()[,"Package"])]
load_packages <- function(x) {
  lapply(x, FUN = function(x) {
    do.call("require", 
            list(x)
    )
  })
}

if (length(new_packages)) {
  install.packages(new_packages)
  load_packages(required_packages)
} else {
  load_packages(required_packages)
}


data_url <- ("http://data.gov.au/dataset/553b3049-2b8b-46a2-95e6-640d7986a8c1/
              resource/bb22debd-95a6-4984-882c-12b58c92e16c/download/Latest-CSV-Export.csv")

###Import the data (Basic Data)====================================================================

  ## This code is my initial attempt, before grouping the toilets together by suburb.
    
    wd <- getwd() # Declare the working directory as wd.
    
    # Set the location that I would like to save the file/the file is already located. (OSX)
    
      osx_data_path <- paste(
        wd,
        "/Data/toilet_data.csv",
        sep = ""
      )
      
    # Set the location that I would like to save the file/the file is already located. (Windows)  
      
      windows_data_path <- paste(
        wd,
        "\\Data\\toilet_data.csv",
        sep = ""
      )
    
    
    # This will run get_os() to determine the OS, then it will copy the data from data_url
    # IFF the data does not already exist (as specified by either osx_data_path/windows_data_path)

       if(get_os() == "osx") {
         if (file.exists(osx_data_path)) {
           toilet_df <- read.csv(osx_data_path)
           break
           } else {
             toilet_df_import <- read.csv(data_url)
             write.csv(
               toilet_df_import,
               file = osx_data_path
             )
           }
       } else {
         if (file.exists(windows_data_path)) {
           toilet_df <- read.csv(windows_data_path)
           break
         } else {
           toilet_df_import <- read.csv(data_url)
           write.csv(
             toilet_df_import,
             file = windows_data_path
           )
         }
       }
    
### Filter the Data================================================================================

## Choose how you want to fileter the data. If you're running it for Melbourne only
## you can filter additionally by postcodes, if you know what they are.
      
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
  
  # Declare where you want to centre the map. geocode() can handle text inputs but remember to 
  # specify the country - as I have - to avoid any confusion.
      
      centre_map_on <- geocode("Melbourne, Australia")

  # Call leaflet using our data  
      
    map <- leaflet( 
      toilet_df
      ) %>%
      
      # Add default OpenStreetMap map tiles
      
      addTiles() %>%  
      
      # Centre the map on the location specified by centre_map_on.
      
      setView(
        lng = centre_map_on$lon,
        lat = centre_map_on$lat,
        
        # change zoom value to set starting zoom: 1 == whole globe; 14 ≈ suburb level. 
        zoom = 12
        ) %>%
      
      # Tell it where to get the labels.      
      
      addMarkers(
        popup=as.character(
          toilet_df$hover
          ),
        
        # clusterOptions tells the map to group markers at different zoom levels; comment this 
        # line out if you wish to see all markers at every zoom level.
        clusterOptions = markerClusterOptions()
        )
    
      map # Call the map.    
    
## I'm behind a proxy at work, so I needed to save the map as a html and then open it in my browser. 
## You probably won't have to, in which case just run the Make the Map chunk above.

###Export to html==================================================================================          
    
      htmlwidgets::saveWidget(map, file='map.html')

### Done
>>>>>>> ed28c02a8f62f75f317fb2463796695bbfae8ab3
