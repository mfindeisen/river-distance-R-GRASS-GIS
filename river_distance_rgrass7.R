library(rgrass7)
use_sf()
library(sf)
library(XML)

initGRASS("C:/Program Files/GRASS GIS 7.6", #! Use GRASS GIS 7.6.1 (old stable) <https://grass.osgeo.org/grass76/binary/mswindows/native/x86_64/WinGRASS-7.6.1-1-Setup-x86_64.exe>
          home=tempdir(), 
          gisDbase= "newLocation",
          location = "WGS84",
          mapset = "PERMANENT",
          override=TRUE)

execGRASS("g.proj", flags = "c", epsg = 4326) # set epsg

# check mapset
execGRASS("g.mapset", flags = "p")

# check region
execGRASS("g.region", flags = "p")

# check initGRASS
G <- gmeta()

# load rivers
execGRASS(cmd = 'v.in.ogr', parameters = list(input='path_to_shapefile.shp', layer= 'river', output='river'),flags = c('overwrite'))

# load sites
execGRASS(cmd = 'v.in.ogr', parameters = list(input='path_to_sites.shp', layer= "sites", output="sites"),flags = c('overwrite'))

# calculate network (change threshold if necessary <https://grass.osgeo.org/grass79/manuals/v.net.html>)
execGRASS(cmd = 'v.net', parameters = list(input='river', points='sites', output='network', operation='connect', threshold = 10000), flags = c('overwrite'))

# add length column to sites (column type = int), use db.execute with sql statement instead of v.db.addcolumn because v.db.addcolumn will throw an error
execGRASS(cmd = 'db.execute', parameters = list(sql='ALTER TABLE sites ADD COLUMN length int'))

# select lines between sites and rivers
execGRASS(cmd = 'v.select', parameters = list(ainput='network', binput='sites', output='network_select', operator='intersects'), flags = c("overwrite"))

# write network_length to shapefile (!workaround) 
execGRASS(cmd = "v.out.ogr", parameters = list(input='network_select', output='network_select.shp', format='ESRI_Shapefile'), flags = c("overwrite"))

# load network_length from shapefile (!workaround)
execGRASS(cmd = "v.in.ogr", parameters=list(input='network_select.shp', layer= "network_select", output="network_select"), flags = c("overwrite"))

# calculate length in network and add as column 'length'
execGRASS(cmd = 'v.to.db', parameters = list(map='network_select', option='length', columns='length', units='meters'))

# check if it worked
network_select_length <- readVECT('network_select')

# copy length values from network to sites
execGRASS(cmd = 'v.what.vect', parameters = list(map='sites', column='length', query_map='network_select', query_column='length'))

# load sites with length
sites <- readVECT('sites') # voilà
